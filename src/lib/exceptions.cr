module Dk
  class ResponseError < Exception
    getter response : HTTP::Client::Response
    getter docker_message : String

    def initialize(@response, @docker_message)
      super "Docker API Error: #{@docker_message}"
    end
  end
end
