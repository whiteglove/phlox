module Phlox
  class Login < Base

    def self.authorize(username, password)
      response = post(:login, { username: username, password: password })
      obj = new(decode_body_from_response(response))
    end

    # This authorizes with the configured system_user
    def self.system_authorize
      authorize(Phlox.system_user, Phlox.system_password)
    end

    def save
      raise NotImplemented, "OpenEMR API does not support creation/update of #{self.class.class_name}."
    end

  end
end
