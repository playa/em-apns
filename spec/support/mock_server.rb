# encoding: UTF-8
# Mock Apple push server
module EM
  module APNS
    module MockServer
      
      def initialize opts
        @on_ssl_handshake = opts[:ssl]
        @on_request = opts[:request]
      end
      
      def post_init
        @data = ""
        start_tls(
          :cert_chain_file => EM::APNS.cert,
          :private_key_file => EM::APNS.key,
          :verify_peer => false
        )
      end

      def ssl_handshake_completed
        @on_ssl_handshake.call if @on_ssl_handshake
      end

      def receive_data(data)
        @data << data
        # Try to extract the payload header
        headers = @data.unpack("cNNnH64n")
        return if headers.last.nil?

        # Try to grab the payload
        payload_size = headers.last
        payload = @data[45, payload_size]
        return if payload.length != payload_size

        @data = @data[45 + payload_size, -1] || ""

        process(headers, payload)
      end

      def process(headers, payload)
        message = "APN RECV #{headers[4]} #{payload}"
        EM::APNS.logger.info(message)

        args = JSON.parse(payload)
        # If the alert is 'DISCONNECT', then we fake a bad payload by replying
        # with an error and disconnecting.
        if args["aps"]["alert"] == "DISCONNECT"
          EM::APNS.logger.info("Disconnecting")
          send_data([8, 1, 0].pack("ccN"))
          close_connection_after_writing
        end
        
        @on_request.call(args) if @on_request
      end
 
    end
  end
end