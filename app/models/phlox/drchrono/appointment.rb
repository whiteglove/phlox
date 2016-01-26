class Phlox::Drchrono::Appointment < Phlox::Drchrono::Base

  include ActiveModel::Validations

  APPOINTMENT_ATTRIBS = [:id, :doctor, :patient, :reason, :office, :scheduled_time, :duration, 
                         :profile, :status, :notes, :blood_pressure, :icd9_codes, 
                         :billing_status, :exam_room]
 
  validates_presence_of :doctor, :exam_room, :office, :scheduled_time, :patient, :notes
  validates_numericality_of :doctor, :patient, :office, :exam_room
  validates :duration, presence: { unless: Proc.new { |appt| appt.profile.present? }, 
        message: "must be included unless appointment profile is present" }
  
  attr_accessor *APPOINTMENT_ATTRIBS

  def attributes
    {
      :id => id,
      :doctor => doctor,
      :patient => patient,
      :reason => reason,
      :office => office,
      :scheduled_time => scheduled_time,
      :duration => duration,
      :profile => profile,
      :status => status, 
      :notes => notes, 
      :blood_pressure => blood_pressure, 
      :icd9_codes => icd9_codes, 
      :billing_status => billing_status,
      :exam_room => exam_room
    }
  end

  def initialize(attribs)
    APPOINTMENT_ATTRIBS.each do |attrib|
      instance_variable_set("@#{attrib}", attribs[attrib])
    end
  end

  class << self

    def find(id)
      response = JSON.parse(HTTParty.get("#{url}/#{id}", headers: auth_header).response.body)
      appt = new(response.symbolize_keys)
      return nil unless response["id"].present?
      appt
    end

    def where(params)
      response = JSON.parse(HTTParty.get(url_with_query(params), headers: auth_header).response.body)
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
      body = {}
      params.each {|k,v| body[k] = v}
      appt = new(body.symbolize_keys)
      if appt.valid?
        response = JSON.parse(HTTParty.post(url, body: body, headers: auth_header).response.body)
        response["id"].present? ? appt.id = response["id"] : appt.add_drchrono_errors(response)
      end
      appt
    end

    def url
      "#{Phlox.drchrono_site}/api/appointments"
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
        response = JSON.parse(HTTParty.get(response["next"], headers: auth_header).response.body)
      end 
      results
    end
  end

  # Instance Methods

  def update_attributes(attribs)
    response = JSON.parse(HTTParty.patch("#{self.class.url}/#{self.id}", body: attribs, headers: self.class.auth_header).response.body)
    if response["id"].present?
      attribs.each {|k,v| instance_variable_set("@#{k}", v)} 
    else
      add_drchrono_errors(response)
    end
    self
  end

  def delete
    response = HTTParty.delete("#{self.class.url}/#{self.id}", headers: self.class.auth_header).try(:response).try(:body)
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