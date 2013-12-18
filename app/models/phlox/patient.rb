module Phlox
  class Patient < Base
    include Phlox::Authenticated
    include Phlox::Validators

    # Because OpenEMR API is not consistent with attribute names
    ATTRIBUTE_MAP = {
        'fname' => 'firstname',
        'lname' => 'lastname',
        'mname' => 'middlename',
        'postalcode' => 'postal_code',
        'countrycode' => 'country_code',
        'driverslicense' => 'drivers_license',
        'phonehome' => 'phone_home',
        'phonebiz' => 'phone_biz',
        'phonecell' => 'phone_cell',
        'contactrelationship' => 'contact_relationship'
    }

    validates :sex, sex: true, if: ->(object){ object.attribute_present?('sex') }
    validates :country_code, country: true, if: ->(object){ object.attribute_present?('country_code') }
    validates :state, state: true, if: ->(object){ object.attribute_present?('state') }
    validates :ethnicity, ethnicity: true, if: ->(object){ object.attribute_present?('ethnicity') }
    validates :title, honorific: true, if: ->(object){ object.attribute_present?('title') }

    def self.find_by_id(id, token)
      response = post(:getpatientrecord, {:patientID => id, :token => token_from_obj(token)} )
      decoded_body = decode_body_from_response(response).fetch('Patient')

      # This call will sometimes return a status of 0 even though it failed. Checking for 'demographics' is more reliable.
      if decoded_body.fetch('demographics', false)
        hash = decoded_body.delete('demographics')
        hash = Hash[hash.map {|k,v| [ATTRIBUTE_MAP[k] || k, v] }]
        new(hash.merge(decoded_body), token, true)
      else
        raise_client_error(decoded_body)
      end
    end

    protected

    def update(token=auth_token)
      return false unless valid?
      response = self.class.post(:updatepatient, self.attributes.merge(:token => token, :patientId => self.id))
      self.class.decode_body_from_response(response, true)
    end

    def self.create(attributes={}, token=auth_token)
      obj = new(attributes, token)
      obj.save
    end

    private

    def create(token=auth_token)
      return self unless valid?
      attributes.merge!(:token => token_from_obj(token))
      response = self.class.post(:addpatient, attributes)
      decoded_body = self.class.decode_body_from_response(response)

      # it might be better to just set the ID, but fields might not really be their we think are (since OpenEMR API
      # will silently drop them) so we reload the full resource to be paranoid
      if patient_id = decoded_body.fetch('patientId')
        self.class.find_by_id(patient_id, token)
      else
        raise_client_error(decoded_body)
      end
    end


  end
end
