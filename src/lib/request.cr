module Dk
  class Request
    @q : Hash(String, JSON::Type)

    def initialize(@method : Symbol, @endpoint : String, q : Hash(String, JSON::Type)? = nil, @version : String = "v1.24")
      @q = q.dup || {} of String => JSON::Type
    end

    @params : HTTP::Params?
    def params
      @params ||= begin
        params = HTTP::Params.parse("")
        @q.each do |k, v|
          params.add k, v.to_s
        end
        params
      end
    end

    @json_path : String?
    def json_path
      @json_path ||= case @method
      when :get
        "/#{@version}#{@endpoint}/json?#{params.to_s}"
      else
        ""
      end
    end

    def new_curl(path)
      curl = Crul::Easy.init
      if socket = Dk.socket?
        curl.url = "http:#{path}"
        curl.unix_socket_path = socket
      elsif host = Dk.host?
        if port = Dk.port?
          host = "#{host}:#{port}"
        end
        if cert = Dk.cert?
          curl.sslcert = cert
        end
        if key = Dk.key?
          curl.sslkey = key
        end
        if pass = Dk.passphrase?
          curl.keypasswd = pass
        end
        curl.url = "https://#{host}#{path}"
        curl.ssl_verifypeer = false
      end
      curl.header = true
      curl
    end

    CHUNKED_HEADER = /^Transfer-Encoding: chunked/i

    def json
      r, w = IO.pipe
      r2, w2 = IO.pipe
      f = future do
        begin
          HTTP::Client::Response.from_io(r2)
        ensure
          r2.close
        end
      end
      future do
        begin
          while line = r.gets
            unless CHUNKED_HEADER =~ line
              w2.puts line
            else
            end
          end
        ensure
          r.close
          w2.close
        end
      end
      begin
        new_curl(json_path).perform w
      ensure
        w.close
      end
      res = f.get
      json = JSON.parse(res.body)
      raise ResponseError.new(res, json["message"].as_s?.to_s) unless res.success?
      yield res, json
    end

    def self.get(endpoint : String, q : Hash(String, JSON::Type)? = nil)
      new(:get, endpoint, q)
    end
  end
end
