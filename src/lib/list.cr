module Dk
  class List(K, V)
    @all = {} of K => V
    @endpoint : String
    @q : Hash(String, JSON::Type)?
    @got = false

    def initialize(@endpoint, @q = nil)
    end

    def each(&block : V ->)
      unless @got
        @got = true
        Request.get(@endpoint, @q).json do |res, json|
          json.each do |data|
            item = V.new(data)
            @all[item.listing_key] = item
            yield item
          end
        end
      else
        @all.each do |k, v|
          yield v
        end
      end
    end

    def all
      each do |*args|
      end
      @all
    end
  end
end
