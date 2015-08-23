class Phlox::Drchrono::Patient < Phlox::Drchrono::Base

  PATIENT_ATTRIBS = [:id, :first_name, :last_name, :date_of_birth, :gender, :address, :city, :state, :zip_code, :email, :home_phone]

  include ActiveModel::Validations

  validates_presence_of :first_name, :last_name, :date_of_birth, :gender

  attr_accessor *PATIENT_ATTRIBS

  def attributes
    {
      :id => id,
      :first_name => first_name,
      :last_name => last_name,
      :date_of_birth => date_of_birth,
      :gender => gender,
      :address => address,
      :city => city,
      :state => state,
      :zip_code => zip_code,
      :email => email,
      :home_phone => home_phone
    }
  end

  def initialize(attribs)
    PATIENT_ATTRIBS.each do |attrib|
      instance_variable_set("@#{attrib}", attribs[attrib])
    end
    valid?
  end

  # DrChrono doesn't support PUTs... Have to find a workaround.
  # def update_attributes(attribs = {})
  #   results = JSON.parse(HTTParty.put(self.class.url, body: attribs.merge!('id' => @attributes['id']), headers: self.class.auth_header).response.body)
  # end

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

    def create(params = {})
      params = Hash[params.map{ |k, v| [k.to_sym, v] }] # Convert all keys to symbols
      params[:chart_id] = SecureRandom.uuid
      params[:doctor] = Phlox::Drchrono::Doctor.default_doctor
      body = {
        'chart_id' => params[:chart_id],
        'first_name' => params[:first_name],
        'last_name' => params[:last_name],
        'gender' => params[:gender],
        'date_of_birth' => params[:date_of_birth],
        'address' => params[:address],
        'city' => params[:city],
        'state' => params[:state],
        'zip_code' => params[:zip_code],
        'email' => params[:email],
        'doctor' => params[:doctor],
        'employer' => params[:employer],
        'home_phone' => params[:home_phone]
      }
      response = JSON.parse(HTTParty.post(url, body: body, headers: auth_header).response.body)
      new(response.symbolize_keys)
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
  end
end
