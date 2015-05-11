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
        new(result)
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
      new(response)
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
