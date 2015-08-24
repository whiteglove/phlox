class Phlox::Drchrono::Doctor < Phlox::Drchrono::Base

  DOCTOR_ATTRIBS = [:id, :first_name, :last_name, :email, :home_phone, :office_phone, :cell_phone, :npi_number, :group_npi_number]

  include ActiveModel

  attr_accessor *DOCTOR_ATTRIBS

  def attributes
    {
      :id => id,
      :first_name => first_name,
      :last_name => last_name,
      :email => email,
      :home_phone => home_phone,
      :office_phone => office_phone,
      :cell_phone => cell_phone,
      :npi_number => npi_number,
      :group_npi_number => group_npi_number
    }
  end

  def initialize(attribs)
    DOCTOR_ATTRIBS.each do |attrib|
      instance_variable_set("@#{attrib}", attribs[attrib]) 
    end
  end

  class << self

    def all
      JSON.parse(HTTParty.get(url, headers: auth_header).response.body)["results"].map do |result|
        new(result.symbolize_keys)
      end     
    end

    def find_by_npi(npi)
      results = JSON.parse(HTTParty.get(url, headers: auth_header).response.body)["results"]
      results.select{|result| result["npi_number"] == npi}.map do |result|
        new(result.symbolize_keys)
      end
    end

    def find_by_last_name(last_name)
      results = JSON.parse(HTTParty.get(url, headers: auth_header).response.body)["results"]
      results.select{|result| result["last_name"] == last_name}.map do |result|
        new(result.symbolize_keys)
      end
    end

    private

    def url
      "#{Phlox.drchrono_site}/api/doctors"
    end

  end

end
