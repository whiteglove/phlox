module Phlox
  class Base < ActiveResource::Base
    include ActiveResource::Extend::StaticPath

    # self.site configured by parent in lib/phlox/engine.rb
    self.format  = :xml

    # Normally ActiveResource posts using the format (json/xml), but OpenEMR doesn't accept XML
    # on a post, it has to be raw form params - although it returns XML as a response (so we still format XML)
    def self.post(custom_method_name, body)
      self.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      super(custom_method_name, nil, body.to_query)
    end

    # their is an id for a patient demographic, but everything in the API wants the 'external id' (pid, patient_id)
    # the original can be acquired using attributes['id']
    def id
      attributes['pid'].try(:to_i)
    end

    def save
      new? ? create(auth_token) : update(auth_token)
    end

    def record
      self
    end

    def reload
      self.class.find_by_id(self.pid, auth_token)
    end

    protected

    def attribute_present?(attr)
      self.attributes.include?(attr) && self.attributes[attr].present?
    end

    private

    def self.decode_body_from_response(response, return_object=nil)
      decoded_body = format.decode(response.body)
      if decoded_body.fetch('status', false).to_i == 0
        return_object || decoded_body
      else
        raise_client_error(decoded_body)
      end
    end

    def self.raise_client_error(decoded_body)
      raise ActiveResource::ClientError.new(OpenStruct.new(:code => decoded_body.fetch('status', 'Unknown'),
                                                           :message => decoded_body.fetch('reason', 'An unknown error occured')))
    end
    delegate :raise_client_error, to: "self.class"

    def self.token_from_obj(obj)
      obj.respond_to?(:token) ? obj.token : obj
    end
    delegate :token_from_obj, to: "self.class"

  end

  class NotImplemented < Exception; end
end
