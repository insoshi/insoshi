require "socket"


class MockHTTPServer

  def initialize
  end

  def start(port, &block)
      dts = TCPServer.new('localhost', port)
      
      
      
      t = Thread.start do
        loop do
          begin
            s = dts.accept
            block.call(s)
          rescue
          ensure
            s.close
          end
        end
        
      end
    t
  end
end


server = MockHTTPServer.new

t = server.start(3000) do |s|
  
  loop do
    p s.readline
  end
end

t.join