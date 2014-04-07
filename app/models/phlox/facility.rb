# Expected CREATE params
# $name = $_POST['name'];
# $phone = $_POST['phone'];
# $fax = $_POST['fax'];
# $street = $_POST['street'];
# $city = $_POST['city'];
# $state = $_POST['state'];
# $postal_code = $_POST['postal_code'];
# $country_code = $_POST['country_code'];
# $pos_code = $_POST['pos_code'];
# $facility_npi = $_POST['facility_npi'];

# Expected UPDATE params
# $facilityId = $_POST['id'];
# $name = $_POST['name'];
# $phone = $_POST['phone'];
# $fax = $_POST['fax'];
# $street = $_POST['street'];
# $city = $_POST['city'];
# $state = $_POST['state'];
# $postal_code = $_POST['postal_code'];
# $country_code = $_POST['country_code'];
# $pos_code = $_POST['pos_code'];
# $facility_npi = $_POST['facility_npi'];

module Phlox
  class Facility < Base
    include Phlox::Authenticated

    def self.find_by_id(options = {})
      new(get_facility(options), options[:token], true)
    end

    def self.create(options = {})
      response = post(:addfacility, create_params(options))
      decoded_body = decode_body_from_response(response)
      if decoded_body.fetch('status') == "0"
        return get_facility(options).fetch('id')
      else
        return decoded_body.fetch('reason')
      end
    end

    def self.update(options = {})
      update_params = create_params(options).merge!(:facilityId => options[:oemr_facility_id])
      response = post(:updatefacility, update_params)
      decoded_body = decode_body_from_response(response)
      if decoded_body.fetch('status') == "0"
        return true
      else
        return decoded_body.fetch('reason')
      end
    end

    # There is no DELETE method for Phlox::Facility

    private

    def self.get_facility(options)
      get_facilities(options).select do |facility|
        if options[:oemr_facility_id]
          facility["id"] == options[:oemr_facility_id].to_s
        else
          facility["name"] == options[:name]
        end
      end.last # OpenEMR allows more than one facility with the same name
    end

    def self.get_facilities(options)
      response = post(:getfacility, {:token => token_from_obj(options[:token])})
      decoded_body = decode_body_from_response(response).fetch('facility')
      decoded_body = [decoded_body] if decoded_body.is_a?(Hash)
      return decoded_body
    end

    def self.create_params(options)
      {
        :name => options[:name],
        :phone => options[:phone],
        :fax => options[:fax],
        :street => options[:street],
        :city => options[:city],
        :state => options[:state],
        :postal_code => options[:postal_code],
        :country_code => options[:country_code],
        :federal_ein => nil,
        :service_location => 1,
        :billing_location => 0,
        :accepts_assignment => 0,
        :pos_code => options[:pos_code],
        :x12_sender_id => nil,
        :attn => nil,
        :domain_identifier => nil,
        :facility_npi => options[:facility_npi],
        :tax_id_type => nil,
        :color => nil,
        :primary_business_entity => 0
      }
    end
  end
end
