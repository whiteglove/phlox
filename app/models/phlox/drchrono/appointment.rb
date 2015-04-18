class Phlox::Drchrono::Appointment < Phlox::Drchrono::Base

  attr_accessor :attributes

  def initialize(attribs = {})
    @attributes = attribs
  end

  class << self

    def where(params)
      valid_params?(params)
      results = JSON.parse(HTTParty.get(url_with_query(params), headers: auth_header).response.body)["results"]
      return nil if results.empty?
      results.map do |result|
        new(result)
      end
    end

    def url
      "#{Phlox.drchrono_site}/api/appointments"
    end

    def valid_params?(params)
      invalid_params = []
      params = Hash[params.map{ |k, v| [k.to_s, v] }]
      params.each do |k,v|
        invalid_params << k unless ["date","date_range","doctor","office","patient"].include?("#{k}")
      end
      raise "Invalid params: #{invalid_params.join(", ")}" unless invalid_params.empty?
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