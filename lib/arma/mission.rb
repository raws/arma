module Arma
  class Mission
    DIFFICULTIES = [:recruit, :regular, :veteran, :expert]
    
    def initialize(attributes, players)
      @attributes, @players = attributes, players
    end
    
    def name
      attributes["mission"]
    end
    
    def difficulty
      DIFFICULTIES[attributes["difficulty"].to_i]
    end
    
    def map
      attributes["mapname"]
    end
    
    def teams
      players.map do |player|
        player.team
      end.uniq.compact
    end
    
    def game_type
      attributes["gametype"]
    end
    
    private
      attr_reader :attributes, :players
  end
end
