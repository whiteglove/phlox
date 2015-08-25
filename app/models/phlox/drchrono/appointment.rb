class Phlox::Drchrono::Appointment < Phlox::Drchrono::Base

  include ActiveModel::Validations

  APPOINTMENT_ATTRIBS = [:id, :doctor, :patient, :reason, :office, :scheduled_time, :duration, 
                         :profile, :status, :notes, :blood_pressure, :icd9_codes, 
                         :billing_status]
  VALID_WHERE_PARAMS = ["date","date_range","doctor","office","patient","since"]
  
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
      :billing_status => billing_status
    }
  end

  def initialize(attribs)
    APPOINTMENT_ATTRIBS.each do |attrib|
      instance_variable_set("@#{attrib}", attribs[attrib])
    end
  end

  class << self

    def find(id)
      result = JSON.parse(HTTParty.get("#{url}/#{id}", headers: auth_header).response.body)
      new(result.symbolize_keys)

    end

    def where(params)
      valid_params?(params)
      results = JSON.parse(HTTParty.get(url_with_query(params), headers: auth_header).response.body)["results"]
      results.map do |result|
        new(result.symbolize_keys)
      end
    end

    def url
      "#{Phlox.drchrono_site}/api/appointments"
    end

    def valid_params?(params)
      invalid_params = []
      params = Hash[params.map{ |k, v| [k.to_s, v] }]
      params.each do |k,v|
        invalid_params << k unless VALID_WHERE_PARAMS.include?("#{k}")
      end
      raise "Invalid params: #{invalid_params.join(", ")}" unless invalid_params.empty?
      raise "Required params: date or date_range must be passed" unless (["date","date_range"] & params.keys).present?
      true
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
  end
end