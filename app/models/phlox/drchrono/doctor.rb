require 'httparty'

class Phlox::Drchrono::Doctor < Phlox::Drchrono::Base

  include HTTParty

  class << self

    def all
      JSON.parse(get(url, headers: auth_header).response.body)["results"]
    end

    def find_by_npi(npi)
      results = JSON.parse(get(url, headers: auth_header).response.body)["results"]
      results.select{|result| result["npi_number"] == npi}
    end

    def find_by_last_name(last_name)
      results = JSON.parse(get(url, headers: auth_header).response.body)["results"]
      results.select{|result| result["last_name"] == last_name}
    end

    private

    def url
      "#{Phlox.drchrono_site}/api/doctors"
    end

  end

end
