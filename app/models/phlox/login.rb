module Phlox
  class Login < Base

    def self.authorize(username, password)
      response = post(:login, { username: username, password: password })
      obj = new(decode_body_from_response(response))
    end

    def save
      raise NotImplemented, "OpenEMR API does not support creation/update of #{self.class.class_name}."
    end

  end
end
