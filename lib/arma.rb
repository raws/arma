require "pp"
require "socket"
require "strscan"

begin
  require "system_timer"
  ArmaTimeout = SystemTimer
rescue LoadError
  require "timeout"
  ArmaTimeout = Timeout
end

$:.unshift File.dirname(__FILE__)

require "arma/errors"
require "arma/mission"
require "arma/player"
require "arma/server_attributes"
require "arma/server"
