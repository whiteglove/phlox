require 'httparty'

class Phlox::Drchrono::Patient < Phlox::Drchrono::Base

  include HTTParty

  class << self

    def all
      JSON.parse(get(url, headers: auth_header).response.body)["results"]
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
      JSON.parse(post(url, body: body, headers: auth_header).response.body)
    end

    private

    def url
      "#{Phlox.drchrono_site}/api/patients"
    end

  end

end
