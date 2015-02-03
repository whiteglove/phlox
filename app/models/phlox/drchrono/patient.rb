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

    def all
      JSON.parse(HTTParty.get(url, headers: auth_header).response.body)["results"]
    end

    def create(params = {})
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
      JSON.parse(HTTParty.post(url, body: body, headers: auth_header).response.body)
    end

    def url
      "#{Phlox.drchrono_site}/api/patients"
    end
  end
end
