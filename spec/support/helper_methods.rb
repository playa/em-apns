require File.expand_path('../mock_server.rb',__FILE__)

module HelperMethods
  def run_em_apns(opts = {})
    sock = EM::APNS.sock = File.expand_path('../tmp/sockets/em-apns-test.sock',__FILE__)
    EM::APNS.key = File.expand_path('../certs/key.pem',__FILE__)
    EM::APNS.cert = File.expand_path('../certs/cert.pem',__FILE__)
    EM::APNS.host = 'localhost' 
    EM::APNS.logger.level = Logger::WARN
    File.unlink(sock) if File.exists?(sock)
    EM.run {
      EM.start_server("localhost", 2195, EM::APNS::MockServer, opts)
      EM.start_unix_domain_server(sock, EM::APNS::Server)
      yield
    }
  end
end