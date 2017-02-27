require "./lib"

module Dk
  extend GlobalConfig::Store

  global_config :socket
  global_config :host
  global_config :port
  global_config :cert
  global_config :key
  global_config :passphrase
  global_config_context :connect, :socket, :host, :port, :cert, :key, :passphrase
end
