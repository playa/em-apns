module EM::APNS
  class Connection < EM::Connection
    attr_accessor :num
    
    def post_init
      start_tls(
        :private_key_file => EM::APNS.key,
        :cert_chain_file  => EM::APNS.cert,
        :verify_peer      => false
      )
    end

    def connection_completed
      EM::APNS.logger.info("Connection established")
    end

    def receive_data(data)
      data_array = data.unpack("ccN")
      error_response = Error.new(*data_array)
      EM::APNS.logger.info("#{error_response}")
    end
    
    def unbind
      EM::APNS.logger.info("Connection terminated")
      @unbind.call(self) if @unbind
    end
    
    def on_unbind &block
      @unbind = block
    end
    
  end
end