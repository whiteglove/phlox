require 'spec_helper'

module Phlox
  describe Facility do

    context "#find_by_id" do

      context "for exisiting Facility" do
        before(:all) do
          get_response = "
            <facilities>
              <status>0</status>
              <reason>The Facilities Record has been fetched</reason>
              <facility>
                  <id>3</id>
                  <name>Your Clinic Name Here</name>
              </facility>
              <facility>
                  <id>4</id>
                  <name>WhiteGlove Health, Inc.</name>
              </facility>
            </facilities>"

          update_response = "<facility><status>0</status><reason>The Facility has been updated</reason></facility>"

          ActiveResource::HttpMock.respond_to do |mock|
            mock.post "/openemr/api/getfacility", {}, get_response, 200
            mock.post "/openemr/api/updatefacility", {}, update_response, 200
          end
        end

        context "Find by facility id" do
          let(:find_facility) { Facility.find_by_id(
            :oemr_facility_id => 4,
            :token => '12345'
          )}

          it "should return the facility with id 4" do
            find_facility.id.should == "4"
          end
        end

        context "update" do
          let(:update_facility) { Facility.update(
            :oemr_facility_id => 4,
            :token => '12345',
            :name => 'Facility 1',
            :phone => '(512) 555-1212',
            :fax => '(512) 555-2121',
            :street => '123 Main Street',
            :city => 'Austin',
            :state => 'TX',
            :postal_code => '78704',
            :country_code => 'USA',
            :pos_code => 11,
            :facility_npi => 'ABC12345'
          )}

          it "should update the facility and return true" do
            update_facility.should be_true
          end
        end
      end

      context "for new Facility" do
        before(:all) do
          create_response = "
            <facility>
              <status>0</status>
              <reason>The Facility has been added</reason>
            </facility>"

            get_response = "
              <facilities>
                <status>0</status>
                <reason>The Facilities Record has been fetched</reason>
                <facility>
                    <id>3</id>
                    <name>Your Clinic Name Here</name>
                </facility>
                <facility>
                    <id>4</id>
                    <name>WhiteGlove Health, Inc.</name>
                </facility>
                <facility>
                    <id>100</id>
                    <name>Facility 1</name>
                </facility>
              </facilities>"

          ActiveResource::HttpMock.respond_to do |mock|
            mock.post "/openemr/api/addfacility", {}, create_response, 200
            mock.post "/openemr/api/getfacility", {}, get_response, 200
          end
        end

        context "create" do
          let(:create_facility) { Facility.create(
            :token => '12345',
            :name => 'Facility 1',
            :phone => '(512) 555-1212',
            :fax => '(512) 555-2121',
            :street => '123 Main Street',
            :city => 'Austin',
            :state => 'TX',
            :postal_code => '78704',
            :country_code => 'USA',
            :pos_code => 11,
            :facility_npi => 'ABC12345'
          )}

          it "should create a facility with id 100" do
            create_facility.should == "100"
          end
        end
      end
    end
  end
end
