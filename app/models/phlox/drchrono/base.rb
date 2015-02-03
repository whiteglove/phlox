require 'httparty'

module Phlox
  module Drchrono
    class Base

      # This method is used for every request. Base seemed like the natural place for it.
      def self.auth_header
        { 'Authorization' => Phlox::Drchrono::Login.get_access_token }
      end
    end
  end
end
