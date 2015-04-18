class Phlox::Drchrono::Patient < Phlox::Drchrono::Base

  attr_accessor :attributes

  def initialize(attribs = {})
    @attributes = attribs
  end

  # DrChrono doesn't support PUTs... Have to find a workaround.
  # def update_attributes(attribs = {})
  #   results = JSON.parse(HTTParty.put(self.class.url, body: attribs.merge!('id' => @attributes['id']), headers: self.class.auth_header).response.body)
  # end

  class << self

    # Assuming id is a unique identifier, this method replicates the ActiveRecord find method
    def find(id)
      results = JSON.parse(HTTParty.get(url, headers: auth_header).response.body)["results"]
      new(results.select{ |patient| patient["id"] == id }.first)
    end

    def where(params)
      valid_params?(params)
      results = JSON.parse(HTTParty.get(url_with_query(params), headers: auth_header).response.body)["results"]
      return nil if results.empty?
      results.map do |result|
        new(result)
      end
    end

    def create(params = {})
      params = Hash[params.map{ |k, v| [k.to_sym, v] }] # Convert all keys to symbols
      params[:chart_id] = SecureRandom.uuid
      params[:doctor] = Phlox::Drchrono::Doctor.default_doctor
      body = {
        'chart_id' => params[:chart_id],
        'first_name' => params[:firstname],
        'last_name' => params[:lastname],
        'gender' => params[:gender],
        'date_of_birth' => params[:dob],
        'address' => "#{params[:street]} #{params[:apt_number]}",
        'city' => params[:city],
        'state' => params[:state],
        'zip_code' => params[:zip],
        'email' => params[:email],
        'doctor' => params[:doctor],
        'employer' => params[:employer],
        'home_phone' => params[:phone]
      }
      JSON.parse(HTTParty.post(url, body: body, headers: auth_header).response.body)
    end

    def url
      "#{Phlox.drchrono_site}/api/patients"
    end

    def valid_params?(params)
      invalid_params = []
      params = Hash[params.map{ |k, v| [k.to_s, v] }]
      params.each do |k,v|
        invalid_params << k unless ["doctor","since","first_name","last_name","email","date_of_birth","gender"].include?("#{k}")
      end
      raise "Invalid params: #{invalid_params.join(", ")}" unless invalid_params.empty?
      true
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
