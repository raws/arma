module Arma
  class Server
    HEADER = "\xfe\xfd\x00"
    PING = "\xaa\xaa\xaa\xab"
    REQUEST = "\xff\xff\xff"
    
    include Comparable
    include Arma::ServerAttributes
    include Socket::Constants
    
    attr_reader :host, :port, :updated_at, :mission, :players
    
    def initialize(host, port = 2302)
      @host, @port = host, port.to_i
    end
    
    def update!
      send!
    end
    
    def method_missing(method_name, *args, &block)
      attributes ? attributes[method_name] : nil
    end
    
    def [](key)
      attributes[key]
    end
    
    def <=>(other)
      name <=> other.name
    end
    
    private
      attr_reader :attributes, :data, :sock
      
      def connect!
        return if connected?
        @sock = UDPSocket.new
        sock.connect(host, port)
      end
      
      def disconnect!
        sock.close unless sock.nil? || sock.closed?
      end
      
      def connected?
        !(sock.nil? || sock.closed?)
      end
      
      def send!
        connect!
        sock.send("#{HEADER}#{PING}#{REQUEST}", 0)
        receive
      end
      
      def receive
        timeout = 5
        @data, = ArmaTimeout.timeout(timeout) do
          sock.recvfrom(4096)
        end
        @updated_at = Time.now
        parse
      rescue Timeout::Error
        raise ServerUnreachableError, "connection to #{host}:#{port} timed out after #{timeout} seconds"
      rescue Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        raise ServerUnreachableError, "could not connect to #{host}:#{port}"
      ensure
        disconnect!
      end
      
      def parse
        raise NoDataError unless data && !data.empty?
        
        scanner = StringScanner.new(data)
        raise InvalidDataError if scanner.skip_until(/#{Regexp.escape(PING)}/).nil?
        
        # Extract server attributes
        @attributes = extract_hash!(scanner)
        
        # Extract players
        player_count = scanner.scan(/../m).unpack("n").first
        player_fields = [].tap do |fields|
          while field = scanner.scan(/[^\0]+/m)
            fields << field.chomp("_").to_sym
            scanner.skip(/\0/)
          end
          scanner.skip(/\0/)
        end
        
        @players = [].tap do |players|
          player_count.times do
            data = {}.tap do |data|
              player_fields.each do |field|
                data[field] = scanner.scan(/[^\0]+/m)
                scanner.skip(/\0/)
              end
            end
            players << Player.new(data)
          end
        end
        
        if status == :playing
          @mission = Mission.new(attributes, players)
        else
          @mission = nil
        end
        
        true
      end
      
      def extract_hash!(scanner)
        hash = {}
        while key = scanner.scan(/[^\0]+/m)
          scanner.skip(/\0/)
          hash[key] = scanner.scan(/[^\0]+/m)
          scanner.skip(/\0/)
        end
        scanner.skip(/\0/)
        hash
      end
  end
end
