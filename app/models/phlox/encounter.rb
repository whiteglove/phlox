module Phlox
  class Encounter < Base
    include Phlox::Authenticated
    include Phlox::Validators

    # validates :facility_id, facility_id: true, if: ->(object){ object.attribute_present?('facility_id') }
    # validates :facility, facility: true, if: ->(object){ object.attribute_present?('facility') }
    # validates :reason, reason: true, if: ->(object){ object.attribute_present?('reason') }
    # validates :dateService, dateService: true, if: ->(object){ object.attribute_present?('dateService') }
    # validates :provider_id, provider_id: true, if: ->(object){ object.attribute_present?('provider_id') }
    # validates :list, list: true, if: ->(object){ object.attribute_present?('list') }

    def self.find_by_patient_id(id, token)
      get_visits(id, token).map do |visit|
        new(visit, token, true)
      end
    end

    def self.find_by_id(id, token, visit_id)
      new(get_visits(id, token).detect{ |visit| visit["encounter"] == visit_id.to_s }, token, true)
    end

    private

    def self.get_visits(id, token)
      response = post(:getvisits, {:patientID => id, :token => token_from_obj(token)} )
      decoded_body = decode_body_from_response(response).fetch('Visit')
      decoded_body = [decoded_body] if decoded_body.is_a?(Hash)
      return decoded_body
    end

  end
end
