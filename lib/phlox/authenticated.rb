module Phlox
  module Authenticated
    attr_accessor :auth_token

    def initialize(attributes = {}, auth=nil, persisted = false)
      @auth_token = auth.respond_to?(:token) ? auth.token : auth
      super(attributes, persisted)
    end
  end
end
