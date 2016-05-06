class Phlox::Drchrono::Patient < Phlox::Drchrono::Base

  PATIENT_ATTRIBS = [:id, :chart_id, :first_name, :last_name, :date_of_birth, :gender, :address, :city, :state, :zip_code, :email, :home_phone, :doctor]

  include ActiveModel::Validations

  validates_presence_of :first_name, :last_name, :date_of_birth, :gender, :doctor
  validates_numericality_of :doctor
  validates_inclusion_of :gender, in: %w( Male Female Other )

  attr_accessor *PATIENT_ATTRIBS

  def attributes
    {
      :id => id,
      :chart_id => chart_id,
      :first_name => first_name,
      :last_name => last_name,
      :date_of_birth => date_of_birth,
      :gender => gender,
      :address => address,
      :city => city,
      :state => state,
      :zip_code => zip_code,
      :email => email,
      :home_phone => home_phone,
      :doctor => doctor
    }
  end

  def initialize(attribs)
    PATIENT_ATTRIBS.each do |attrib|
      instance_variable_set("@#{attrib}", attribs[attrib])
    end
  end

  class << self
    def find(id)
      response = JSON.parse(HTTParty.get(URI.encode("#{url}/#{id}"), headers: auth_header).response.body)
      patient = new(response.symbolize_keys)
      raise response.inspect unless response["id"].present?
      patient
    end

    def where(params)
      response = JSON.parse(HTTParty.get(URI.encode(url_with_query(params)), headers: auth_header).response.body)
      if response.is_a?(Hash)
        results = gather_paginated_results(response) 
        results.flatten.map do |result|
          new(result.symbolize_keys)
        end
      else
        raise response.join(", ")
      end
    end

    def create(params)
      params[:chart_id] = SecureRandom.uuid
      body = {:doctor => Phlox.drchrono_default_doctor}
      params.each {|k,v| body[k] = v}
      patient = new(body.symbolize_keys)
      if patient.valid?
        response = JSON.parse(HTTParty.post(URI.encode(url), body: body, headers: auth_header).response.body) 
        response["id"].present? ? patient.id = response["id"] : patient.add_drchrono_errors(response)
      end
      patient
    end

    def url
      "#{Phlox.drchrono_site}/api/patients"
    end

    def url_with_query(params)
      query_url = url
      params.each do |k,v|
        if query_url == url
          query_url += "?#{k}=#{v}"
        else
          query_url += "&#{k}=#{v}"
        end
      end
      query_url
    end

    def gather_paginated_results(response)
      results = []
      results << response["results"]
      while response["next"].present?
        results << response["results"]
        response = JSON.parse(HTTParty.get(URI.encode(response["next"]), headers: auth_header).response.body)
      end 
      results
    end
  end

  # Instance methods

  def update_attributes(attribs)
    response = JSON.parse(HTTParty.patch(URI.encode("#{self.class.url}/#{self.id}"), body: attribs, headers: self.class.auth_header).response.body)
    if response["id"].present?
      attribs.each {|k,v| instance_variable_set("@#{k}", v)} 
    else 
      add_drchrono_errors(response)
    end
    self
  end

  def delete
    response = HTTParty.delete(URI.encode("#{self.class.url}/#{self.id}"), headers: self.class.auth_header).try(:response).try(:body)
    if response.nil? 
      return self.id
    end
    JSON.parse(response)
  end

  def add_drchrono_errors(response)
    response.each do |k,v|
      errors.add(k.to_sym, v)
    end
  end
end
