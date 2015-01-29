# Expected CREATE params
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

# Expected UPDATE params
# $patientId = $_POST['patientId'];
# $reason = $_POST['reason'];
# $facility = $_POST['facility'];
# $facility_id = $_POST['facility_id'];
# $encounter = $_POST['encounter'];
# $dateService = $_POST['dateService'];
# $sensitivity = $_POST['sensitivity'];
# $pc_catid = $_POST['pc_catid'];
# $billing_facility = $_POST['billing_facility'];
# $list = $_POST['list'];


class Phlox::Openemr::Encounter < Phlox::Openemr::Base
  include Phlox::Authenticated

  def self.find_by_patient_id(pid, token)
    get_visits(pid, token).map do |visit|
      new(visit, token, true)
    end
  end

  def self.find_by_id(oemr_encounter_id, pid, token)
    new(get_visits(pid, token).detect{ |encounter| encounter["encounter"] == oemr_encounter_id.to_s }, token, true)
  end

  def self.create(options = {})
    response = post(:addvisit, create_params(options))
    decoded_body = decode_body_from_response(response)
    if decoded_body.fetch('status') == "0"
      return decoded_body
    else
      return raise_client_error(decoded_body)
    end
  end

  def self.update(options = {})
    update_params = create_params(options).merge!(:encounter => options[:oemr_encounter_id])
    response = post(:updatevisit, update_params)
    decoded_body = decode_body_from_response(response)
    if decoded_body.fetch('status') == "0"
      return true
    else
      return raise_client_error(decoded_body)
    end
  end

  def self.delete(oemr_encounter_id, token)
    response = post(:deletevisit, {:visit_id => oemr_encounter_id, :token => token_from_obj(token)})
    decoded_body = decode_body_from_response(response)
    if decoded_body.fetch('status') == "0"
      return true
    else
      return raise_client_error(decoded_body)
    end
  end

  private

  def self.get_visits(pid, token)
    response = post(:getvisits, {:patientId => pid, :token => token_from_obj(token)})
    decoded_body = decode_body_from_response(response).fetch('Visit')
    decoded_body = [decoded_body] if decoded_body.is_a?(Hash)
    return decoded_body
  end

  # pc_catid: 9 = Established patient, 10 = New patient
  def self.pc_catid
    {"New Patient" => 10, "Established Patient" => 9}
  end

  def self.create_params(options)
    {
      :token => token_from_obj(options[:token]),
      :patientId => options[:pid],
      :reason => nil,
      :facility => Phlox::Openemr::Facility.find_by_id(:oemr_facility_id => options[:oemr_facility_id], :token => options[:token]).name,
      :facility_id => Phlox::Openemr::Facility.find_by_id(:oemr_facility_id => options[:oemr_facility_id], :token => options[:token]).id,
      :dateService => options[:scheduled_at],
      :onset_date => nil,
      :sensitivity => nil,
      :pc_catid => pc_catid[options[:patient_type]],
      :billing_facility => nil,
      :list => []
    }
  end
end
