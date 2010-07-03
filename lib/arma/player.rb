module Arma
  class Player
    include Comparable
    
    attr_reader :data
    
    def initialize(data)
      @data = data
    end
    
    def name
      data[:player]
    end
    
    def score
      data[:score].to_i
    end
    
    def deaths
      data[:deaths].to_i
    end
    
    def method_missing(method_name, *args, &block)
      data ? data[method_name] : nil
    end
    
    def <=>(other)
      name <=> other.name
    end
  end
end
