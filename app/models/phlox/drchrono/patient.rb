class Phlox::Drchrono::Patient < Phlox::Drchrono::Base

  PATIENT_URL = "#{Phlox.drchrono_site}/api/patients"

  attr_accessor :attributes

  def initialize(attribs = {})
    @attributes = attribs
  end

  # Assuming id is a unique identifier, this method replicates the ActiveRecord find method
  def self.find(id)
    results = JSON.parse(HTTParty.get(PATIENT_URL, headers: auth_header).response.body)["results"]
    patient = results.select{ |patient| patient["id"] == id }.first
    new(patient)
  end

  def self.all
    JSON.parse(HTTParty.get(PATIENT_URL, headers: auth_header).response.body)["results"]
  end

  def self.create(params = {})
    body = {
      'chart_id' => params[:chart_id],
      'first_name' => params[:first_name],
      'last_name' => params[:last_name],
      'gender' => params[:gender],
      'date_of_birth' => params[:dob],
      'address' => params[:address],
      'city' => params[:city],
      'state' => params[:state],
      'zip_code' => params[:zip],
      'email' => params[:email],
      'doctor' => params[:doctor],
      'employer' => params[:employer],
      'home_phone' => params[:phone]
    }
    patient = JSON.parse(HTTParty.post(PATIENT_URL, body: body, headers: auth_header).response.body)
  end
end
