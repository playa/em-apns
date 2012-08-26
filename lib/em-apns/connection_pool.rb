module EM::APNS
  
  #simple connection pool using EM queue, default size 4
  class ConnectionPool
    attr_reader :queue
   
    def initialize
      @pool_size = EM::APNS.pool || 4
      @connections = []
      @queue = EM::Queue.new
      @pool_size.times { add_connection }
    end
    
    def queue_worker_loop
      proc{ |connection|
        @queue.pop do |notification|
          connection.send_data(notification)
          EM.next_tick { queue_worker_loop.call connection }
        end
      }
    end
    
    def add_connection
      connection = EM.connect(EM::APNS.host, 2195, Connection)
      connection.on_unbind do |conn|
        @connections.delete(conn)
        EM.next_tick{ add_connection }
      end
      @connections << connection
      queue_worker_loop.call connection
    end
    
  end
end