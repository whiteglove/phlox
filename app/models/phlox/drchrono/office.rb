class Phlox::Drchrono::Office < Phlox::Drchrono::Base

  include ActiveModel::Validations

  OFFICE_ATTRIBS = [:id, :name, :doctor, :address, :city, :state, :zip_code, :phone_number]
 
  validates_presence_of :name
  
  attr_accessor *OFFICE_ATTRIBS

  def attributes
    {
      :id => id,
      :name => name,
      :doctor => doctor,
      :address => address,
      :city => city,
      :state => state,
      :zip_code => zip_code,
      :phone_number => phone_number
    }
  end

  def initialize(attribs)
    OFFICE_ATTRIBS.each do |attrib|
      instance_variable_set("@#{attrib}", attribs[attrib])
    end
  end

  class << self

    def all
      JSON.parse(HTTParty.get(url, headers: auth_header).response.body)["results"].map do |result|
        new(result.symbolize_keys)
      end 
    end

    def find_by_name(name)
      results = JSON.parse(HTTParty.get(url, headers: auth_header).response.body)["results"]
      result = results.select{|office| office["name"] == name}.first
      return nil unless result.present?
      new(result.symbolize_keys)
    end

    def url
      "#{Phlox.drchrono_site}/api/offices"
    end
  end
end