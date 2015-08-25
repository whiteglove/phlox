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

    def where(params)
      results = []
      params = Hash[params.map{ |k, v| [k.to_s, v] }]
      request = JSON.parse(HTTParty.get(url_with_query(params), headers: auth_header).response.body)
      return nil if request["results"].empty?
      results << request["results"]
      while request["next"].present?
        puts "Executing #{request["next"]}"
        results << request["results"]
        request = JSON.parse(HTTParty.get(request["next"], headers: auth_header).response.body)
      end
      %w{last_name first_name email}.each do |param|
        if params["#{param}"].present?
          results = results.flatten.select{|patient| patient["#{param}"].downcase.include? params["#{param}"].downcase}
        end
      end
      results.map do |result|
        new(result.symbolize_keys)
      end
    end

    def create(params)
      valid_params?(params)
      params = Hash[params.map{ |k, v| [k.to_sym, v] }] # Convert all keys to symbols
      params[:chart_id] = SecureRandom.uuid
      body = {}
      params.each {|k,v| body[k.to_s] = v}
      patient = new(body.symbolize_keys)
      if patient.valid?
        response = JSON.parse(HTTParty.post(url, body: body, headers: auth_header).response.body) 
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
        key = translate_search_param(k)
        if query_url == url
          query_url += "?#{key}=#{v}"
        else
          query_url += "&#{key}=#{v}"
        end
      end
      query_url
    end

    def translate_search_param(key)
      ["first_name","last_name","email"].include?(key.to_s) ? "search" : key
    end

    def valid_params?(params)
      invalid_params = []
      params.each {|k,v| invalid_params << k unless PATIENT_ATTRIBS.include?(k)}
      raise "Invalid params: #{invalid_params.join(", ")}" unless invalid_params.empty?
      true
    end
  end

  # Instance methods

  def update_attributes(attribs)
    Phlox::Drchrono::Patient.valid_params?(attribs)
    response = JSON.parse(HTTParty.patch("#{self.class.url}/#{self.id}", body: attribs, headers: self.class.auth_header).response.body)
    if response["id"].present?
      attribs.each {|k,v| instance_variable_set("@#{k}", v)} 
    else 
      return response
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
