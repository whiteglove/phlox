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

    def find(id)
      response = JSON.parse(HTTParty.get("#{url}/#{id}", headers: auth_header).response.body)
      office = new(response.symbolize_keys)
      return nil unless response["id"].present?
      office
    end

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

  # Instance methods

  def add_exam_room(name)
    current_exam_rooms = JSON.parse(HTTParty.get("#{self.class.url}/#{self.id}", headers: self.class.auth_header).response.body)["exam_rooms"]
    raise "An exam room by that name already exists" if current_exam_rooms.select{|room| room["name"] == name}.present?
    response = JSON.parse(HTTParty.post("#{self.class.url}/#{self.id}/add_exam_room", body: {:name => name}, headers: self.class.auth_header).response.body)
    exam_rooms = response["exam_rooms"]
    new_exam_room = exam_rooms.select{|room| room["name"] == name}.last
    new_exam_room
  end

  def add_drchrono_errors(response)
    response.each do |k,v|
      errors.add(k.to_sym, v)
    end
  end
end