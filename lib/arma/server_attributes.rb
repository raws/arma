module Arma
  module ServerAttributes
    STATUSES = { "openplaying" => :playing, "openwaiting" => :lobby }
    PLATFORMS = { "win" => :windows, "linux" => :linux }
    
    def name
      attributes["hostname"]
    end
    
    def battleye?
      attributes["sv_battleye"].to_i > 0
    end
    
    def dedicated?
      attributes["dedicated"].to_i > 0
    end
    
    def max_players
      attributes["maxplayers"].to_i
    end
    
    def password?
      attributes["password"].to_i > 0
    end
    
    def platform
      PLATFORMS[attributes["platform"]]
    end
    
    def signatures
      (attributes["signatures"] || "").split(";")
    end
    
    def signed?
      attributes["verifySignatures"].to_i > 0
    end
    
    def state
      attributes["gameState"].to_i
    end
    
    def status
      STATUSES[attributes["gamemode"]] || attributes["gamemode"]
    end
    
    def verify_mods?
      attributes["equalModRequired"].to_i > 0
    end
    
    def version
      attributes["gamever"]
    end
  end
end
