class Phlox::Drchrono::AppointmentProfile < Phlox::Drchrono::Base

  include ActiveModel::Validations

  APPOINTMENT_PROFILE_ATTRIBS = [:id, :name, :duration, :reason, :archived]
  
  attr_accessor *APPOINTMENT_PROFILE_ATTRIBS

  def attributes
    {
      :id => id,
      :name => name,
      :duration => duration,
      :reason => reason,
      :archived => archived
    }
  end

  def initialize(attribs)
    APPOINTMENT_PROFILE_ATTRIBS.each do |attrib|
      instance_variable_set("@#{attrib}", attribs[attrib])
    end
  end

  class << self

    def all
      response = JSON.parse(HTTParty.get(url, headers: auth_header).response.body)
      if response.is_a?(Hash)
        results = gather_paginated_results(response) 
        results.flatten.map do |result|
          new(result.symbolize_keys)
        end
      else
        raise response.join(", ")
      end
    end

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

    def url
      "#{Phlox.drchrono_site}/api/appointment_profiles"
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

  def add_drchrono_errors(response)
    response.each do |k,v|
      errors.add(k.to_sym, v)
    end
  end
end