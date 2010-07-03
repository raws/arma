module Arma
  class Error < ::StandardError; end
  class ServerUnreachableError < Error; end
  class NoDataError < Error; end
  class InvalidDataError < Error; end
end
