module EM::APNS
  class ServerRunner

    def initialize(args)
      require 'rubygems'
      require 'optparse'
      require 'logger'
      
      @options = { environment: 'development', root: File.expand_path('.') }
      
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: em-apns [options] start|stop"

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit 1
        end
        
        opts.on('-e', '--environment=NAME', 'Specifies the environment to run this apn sender under ([development]/production/test).') do |e|
          @options[:environment] = e
        end

        opts.on('-p', '--pid_file=NAME', 'Specifies the pid file path.') do |path|
          @pid_file = path
        end

        opts.on('-d', '--daemonize', 'Daemonize em-apnsender') do
          @daemonize = true
        end

        opts.on('-c', '--config=CONFIG', 'Full path to configuration file.') do |path|
          @options[:config] = path
        end

      end
      
      # If no arguments, give help screen
      @args = optparse.parse!(args.empty? ? ['-h'] : args)
      
      case args[0]
      when 'start'
        start
      when 'stop'
        stop
      end
    end
  
    def start
      if @daemonize
        require 'daemons'
        Daemons.run_proc("em-apns-#{@options[:environment]}", :dir => "#{@options[:root]}/tmp/pids", :dir_mode => :normal, :ARGV => @args) do |*args|
          EM::APNS.logger = Logger.new(File.join(@options[:root], 'log', "em-apns-#{@options[:environment]}.log"))
          run
        end
      else
        run
      end
    end
    
    def stop
      @pid_file ||= "#{@options[:root]}/tmp/pids/em-apns-#{@options[:environment]}.pid"
      pid = File.open(@pid_file) {|h| h.read}.to_i
      Process.kill('TERM', pid) 
    rescue Errno => e
      require 'fileutils'
      puts "#{e} #{pid}"
      puts "deleting pid-file..."
      FileUtils.rm( f ) 
    end
    
    def run
      EM::APNS.config(@options)
      file = EM::APNS.sock
      File.unlink(file) if File.exists?(file)
      EventMachine::run {
        Signal.trap("INT") { EM::APNS.logger.fatal("Terminated"); EM.stop }
        Signal.trap("TERM") { EM::APNS.logger.fatal("Terminated"); EM.stop }
        EM::APNS.logger.info "Started"
        EventMachine::start_unix_domain_server(file, EM::APNS::Server )
      }
    rescue => e
      STDERR.puts e.message
      EM::APNS.logger.fatal(e) if EM::APNS.logger.respond_to?(:fatal)
      exit 1
    end
    
  end
end
