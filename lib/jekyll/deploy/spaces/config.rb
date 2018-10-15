module Jekyll
  module Deploy
    module Spaces
      class Config
        attr_reader :space, :key, :secret, :endpoint, :region

        def initialize(space:, key:, secret:, endpoint: 'https://nyc3.digitaloceanspaces.com', region: 'nyc3')
          @space = space
          @key = key
          @secret = secret
          @endpoint = endpoint
          @region = region
        end
      end
    end
  end
end
