module EM::APNS
  module Server
    def post_init
      @@queue ||= ConnectionPool.new.queue 
      @buf ||= ""
    end
  
    def receive_data(data)
      @buf << data
      while line = @buf.slice!(/.+\r?\n/) do
        @@queue.push(line.gsub(/\r?\n/, '')) 
      end
    end
  end
end