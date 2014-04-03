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

    def self.find_by_patient_id(pid, token)
      get_visits(pid, token).map do |visit|
        new(visit, token, true)
      end
    end

    def self.find_by_id(visit_id, pid, token)
      new(get_visits(pid, token).detect{ |visit| visit["encounter"] == visit_id.to_s }, token, true)
    end


    # $token = $_POST['token'];
    # $patientId = $_POST['patientId'];
    # $reason = $_POST['reason'];
    # $facility = $_POST['facility'];
    # $facility_id = $_POST['facility_id'];
    # $dateService = $_POST['dateService'];
    # $onset_date =$_POST['onset_date'];
    # $sensitivity = $_POST['sensitivity'];
    # $pc_catid = $_POST['pc_catid'];
    # $billing_facility = $_POST['billing_facility'];
    # $list = $_POST['list'];

    def self.create(options = {})
      params = {
        :token => token_from_obj(options[:token]),
        :patientId => options[:pid],
        :reason => nil,
        :facility => options[:oemr_facility_id].to_s, # Phlox::Facility.find(options[:oemr_facility_id]).name,
        :facility_id => options[:oemr_facility_id], # Phlox::Facility.find(options[:oemr_facility_id]).id,
        :dateService => options[:scheduled_at],
        :onset_date => nil,
        :sensitivity => nil,
        :pc_catid => pc_catid[options[:patient_type]],
        :billing_facility => nil,
        :list => []
      }
      response = post(:addvisit, params)
      decoded_body = decode_body_from_response(response).fetch('visit_id')
      return decoded_body
    end

    private

    def self.get_visits(pid, token)
      response = post(:getvisits, {:patientId => pid, :token => token_from_obj(token)} )
      decoded_body = decode_body_from_response(response).fetch('Visit')
      decoded_body = [decoded_body] if decoded_body.is_a?(Hash)
      return decoded_body
    end

    # pc_catid: 9 = Established patient, 10 = New patient
    def self.pc_catid
      {"New Patient" => 10, "Established Patient" => 9}
    end

  end
end
