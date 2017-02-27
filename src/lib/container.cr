module Dk
  class Container
    getter json : JSON::Any

    def initialize(@json)
    end

    def listing_key
      @json["Id"].as_s
    end

    class List < Params
      params({
        all: Bool,
        limit: Int64,
        size: Bool,
        filters: String,
      })

      def list!
        Container.list(self)
      end
    end

    def self.list(params = List.new)
      Dk::List(String, Container).new("/containers", params.to_h)
    end

    def self.get?(owner : String, repo : String, number : Int::Primitive)
      get(owner, repo, number)
    rescue ex : HttpError
      raise ex unless ex.not_found?
      nil
    end

    def self.get(owner : String, repo : String, number : Int::Primitive)
      Request.get("/repos/#{owner}/#{repo}/pulls/#{number}") do |req, res, json|
        Pull.new(json)
      end.not_nil!
    end
  end
end
