require_relative 'spaces/version'

module Jekyll
  module Deploy
    module Spaces
    end
  end
end

require_relative 'spaces/config'
require_relative 'spaces/syncer'
require_relative '../commands/deploy'
