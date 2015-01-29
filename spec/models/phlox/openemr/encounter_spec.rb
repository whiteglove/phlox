require 'spec_helper'

module Phlox
  module Openemr
    describe Encounter do

      context "#find_by_id" do

        context "for exisiting Encounter" do
          before(:all) do
            ar_response = "
            <PatientVisit>
              <status>0</status>
              <reason>The Patient visit Record has been fetched</reason>
              <Visit>
                  <id>7</id>
                  <date>2014-03-11 00:00:00</date>
                  <reason></reason>
                  <facility>WhiteGlove Health, Inc.</facility>
                  <facility_id>4</facility_id>
                  <pid>1</pid>
                  <encounter>16</encounter>
                  <onset_date>0000-00-00 00:00:00</onset_date>
                  <sensitivity>normal</sensitivity>
                  <billing_note></billing_note>
                  <pc_catid>9</pc_catid>
                  <last_level_billed>0</last_level_billed>
                  <last_level_closed>0</last_level_closed>
                  <last_stmt_date></last_stmt_date>
                  <stmt_count>0</stmt_count>
                  <provider_id>1</provider_id>
                  <supervisor_id>0</supervisor_id>
                  <invoice_refno></invoice_refno>
                  <referral_source></referral_source>
                  <billing_facility>0</billing_facility>
                  <pc_catname>Established Patient</pc_catname>
                  <billing_facility_name></billing_facility_name>
                  <Issues>
                      <Issue>
                          <type>medical_problem</type>
                          <title>asthma</title>
                          <begdate></begdate>
                          <diagnosis></diagnosis>
                      </Issue>
                  </Issues>
                  <subjective></subjective>
                  <objective></objective>
                  <assessment></assessment>
                  <plan></plan>
              </Visit>
              <Visit>
                  <id>9</id>
                  <date>2014-03-11 00:00:00</date>
                  <reason></reason>
                  <facility>WhiteGlove Health, Inc.</facility>
                  <facility_id>4</facility_id>
                  <pid>1</pid>
                  <encounter>16</encounter>
                  <onset_date>0000-00-00 00:00:00</onset_date>
                  <sensitivity>normal</sensitivity>
                  <billing_note></billing_note>
                  <pc_catid>9</pc_catid>
                  <last_level_billed>0</last_level_billed>
                  <last_level_closed>0</last_level_closed>
                  <last_stmt_date></last_stmt_date>
                  <stmt_count>0</stmt_count>
                  <provider_id>1</provider_id>
                  <supervisor_id>0</supervisor_id>
                  <invoice_refno></invoice_refno>
                  <referral_source></referral_source>
                  <billing_facility>0</billing_facility>
                  <pc_catname>Established Patient</pc_catname>
                  <billing_facility_name></billing_facility_name>
                  <Issues>
                      <Issue>
                          <type>medical_problem</type>
                          <title>asthma</title>
                          <begdate></begdate>
                          <diagnosis></diagnosis>
                      </Issue>
                  </Issues>
                  <subjective></subjective>
                  <objective></objective>
                  <assessment></assessment>
                  <plan></plan>
              </Visit>
            </PatientVisit>"
            ActiveResource::HttpMock.respond_to do |mock|
              mock.post "/openemr/api/getvisits", {}, ar_response, 200
            end
          end

          context "Find by patient" do
            let(:visits) { Encounter.find_by_patient_id(1, '12345') }

            it "should return an array of visits" do
              visits.should be_a(Array)
            end

            it "should return an array of Phlox encounters" do
              visits.first.should be_a(Phlox::Openemr::Encounter)
            end
          end

          context "Find by visit" do
            let(:visit) { Encounter.find_by_id(16, 1, '12345') }

            it "should return the visit with encounter 16" do
              visit.encounter.should == "16"
            end
          end
        end
      end


      context "with valid attributes" do
        let(:created_visit){ Encounter.create(
          :token => '12345',
          :pid => 1,
          :oemr_facility_id => 11,
          :scheduled_at => Time.now.to_s(:db),
          :patient_type => "Established Patient"
          )}

        let(:updated_visit){ Encounter.update(
          :oemr_encounter_id => created_visit["visit_id"],
          :token => '12345',
          :pid => 1,
          :oemr_facility_id => 11,
          :scheduled_at => Time.now.to_s(:db),
          :patient_type => "New Patient"
          )}

        let(:deleted_visit){ Encounter.delete(created_visit["visit_id"], '12345')}

        before(:all) do
          add_response = "<PatientVisit><status>0</status><reason>The Patient visit has been added</reason><visit_id>999</visit_id></PatientVisit>"
          update_response = "<PatientVisit><status>0</status><reason>Patient visit updated successfully</reason><visit_id>999</visit_id></PatientVisit>"
          delete_response = "<visit><status>0</status><reason>The Visit has been deleted</reason></visit>"
          get_facility_response = "<facilities><status>0</status><reason>The Facilities Record has been fetched</reason><facility><id>11</id><name>Your Clinic Name Here</name></facility></facilities>"
          ActiveResource::HttpMock.respond_to do |mock|
            mock.post "/openemr/api/addvisit", {}, add_response, 200
            mock.post "/openemr/api/updatevisit", {}, update_response, 200
            mock.post "/openemr/api/deletevisit", {}, delete_response, 200
            mock.post "/openemr/api/getfacility", {}, get_facility_response, 200
          end
        end

        it "should create successfully and respond with the OpenEMR visit id" do
          created_visit["visit_id"].should == "999"
        end

        it "should update selected encounter and respond true" do
          updated_visit.should be_true
        end

        it "should delete the selected encounter" do
          deleted_visit.should be_true
        end

      end
    end
  end
end
