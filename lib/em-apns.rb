require 'eventmachine'
require 'socket'
require 'logger'
require 'json'
require 'yaml'
require 'em-apns/notification'
require 'em-apns/error'
require 'em-apns/connection'
require 'em-apns/connection_pool'
require 'em-apns/server'
require "em-apns/version"

module EM::APNS
  class << self
    attr_writer :sock, :logger
    attr_accessor :key, :cert, :pool, :env, :host
        
    def sock
      @sock ||= (defined?(Rails) && Rails.respond_to?(:root) ? File.join(Rails.root, 'tmp/sockets', "em-apns-#{Rails.env}.sock") : nil)
    end    
        
    def logger
      @logger ||= Logger.new(STDOUT)
    end
    
    def send_notification(*args)
      send_notifications([Notification.new(*args)])
    end
    
    def send_notifications(notifications)
      UNIXSocket.open(sock) do |socket|
        notifications.each do |n|
          socket.puts(n.data)
        end
      end
    rescue => e
      logger.error(e)
    end
      
    def config options
      raise 'App root folder are not defined' unless options[:root]
      if options[:config]
        configurations = YAML.load_file options['config']
      else
        config_file = File.join(options[:root],"config/em-apns.yml")
        configurations = YAML.load_file(config_file)
      end
      @env = options[:environment] || 'development'
      @sock = File.join(options[:root], "tmp/sockets/em-apns-#{@env}.sock")
      @pool = configurations['pool']
      @key = configurations['key']
      @cert = configurations['cert']
      raise 'No key or certficate file' unless @key && @cert
      @host = case @env
      when 'development'
        "gateway.sandbox.push.apple.com"
      when 'production'
        "gateway.push.apple.com"
      else
        "localhost"
      end
    end
  
  end
  
end

