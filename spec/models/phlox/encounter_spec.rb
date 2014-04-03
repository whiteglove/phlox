require 'spec_helper'

module Phlox
  describe Encounter do

    shared_examples "a persisted Encounter" do
      it "returns an Encounter object when successful" do
        expect(subject).to be_a(Phlox::Encounter)
      end

      it "returns a persisted objected when successful" do
        expect(subject.persisted?).to be_true
      end
    end

    # context "when validating" do

    #   it "allows valid attributes" do
    #     subject.attributes.merge!({:sex => 'Male', :country_code => 'USA', :state => 'TX',
    #                                :ethnicity => 'not_hisp_or_latin', :title => 'Mr.'})
    #     expect(subject).to be_valid
    #   end

    #   it "doesn't allow invalid sex" do
    #     subject.sex = 'Bad'
    #     expect(subject).to_not be_valid
    #   end

    #   it "doesn't allow invalid country codes" do
    #     subject.country_code = 'United States'
    #     expect(subject).to_not be_valid
    #   end

    #   it "doesn't allow invalid state" do
    #     subject.state = 'Texas'
    #     expect(subject).to_not be_valid
    #   end

    #   it "doesn't allow invalid ethnicity" do
    #     subject.ethnicity = 'white'
    #     expect(subject).to_not be_valid
    #   end

    #   it "doesn't allow invalid titles (honorific)" do
    #     subject.title = 'Mister'
    #     expect(subject).to_not be_valid
    #   end

    # end

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
            visits.first.should be_a(Phlox::Encounter)
          end
        end

        context "Find by visit" do
          let(:visit) { Encounter.find_by_id(16, 1, '12345') }

          it "should return the visit with id 9" do
            visit.encounter.should == "16"
          end
        end

      end


      # context "for non-exisiting Encounter" do
      #   before(:all) do
      #     ar_response = "<EncounterList><status>0</status><reason>Success Encounter processing record</reason><Encounter><Encounterdata><status>1</status></Encounterdata></Encounter></EncounterList>"
      #     ActiveResource::HttpMock.respond_to do |mock|
      #       mock.post "/openemr/api/getEncounterrecord", {}, ar_response, 200
      #     end
      #   end

      #   it "raises an error when unsuccessful" do
      #     expect{ Encounter.find_by_id(2, '12345') }.to raise_error(ActiveResource::ClientError)
      #   end
      # end

    end


    context "with valid attributes" do
      before(:all) do
        add_response = "<PatientVisit><status>0</status><reason>The Patient visit has been added</reason><visit_id>999</visit_id></PatientVisit>"
        # update_response = ""
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/openemr/api/addvisit", {}, add_response, 200
          #mock.post "/openemr/api/updateEncounter", {}, update_response, 200
        end
      end

      context "creating" do
        let(:new_visit){ Encounter.create(
          :token => '12345',
          :pid => 1,
          :oemr_facility_id => 10,
          :scheduled_at => Time.now.to_s(:db),
          :patient_type => "Established Patient"
          )}

        it "should respond with the OpenEMR visit id" do
          new_visit.should == "999"
        end

      end

      # context "updating" do
      #   let(:Encounter){ Encounter.find_by_id(1, '12345') }
      #   subject{ Encounter.update_attributes(:firstname => 'Testme') }
      #
      #   it "returns true" do
      #     expect(Encounter.update_attributes(:firstname => 'Testme')).to be_true
      #   end
      # end
      #
      # context "saving" do
      #   let(:Encounter){ Encounter.new({:firstname => 'Test', :lastname => 'Meout'}, '12345') }
      #   subject{ Encounter.save }
      #   it_behaves_like "a persisted Encounter"
      # end

    end


    # context "with invalid attributes" do

    #   context "creating" do
    #     subject{ Encounter.create({:firstname => 'Badsex', :sex => 'G'}, '12345') }
    #     it "returns object with errors added" do
    #       expect(subject.errors).to include(:sex)
    #     end

    #     it "returns unpersisted object" do
    #       expect(subject.persisted?).to be_false
    #     end
    #   end

    #   context "updating" do
    #     before(:all) do
    #       ar_response = "<EncounterList><status>0</status><reason>Success Encounter processing record</reason><Encounter><demographics><id>1</id><pid>2</pid></demographics></Encounter></EncounterList>"
    #       ActiveResource::HttpMock.respond_to do |mock|
    #         mock.post "/openemr/api/getEncounterrecord", {}, ar_response, 200
    #       end
    #     end
    #     let(:Encounter){ Encounter.find_by_id(1, '12345') }
    #     subject{ Encounter.update_attributes(:sex => 'G') }

    #     it "returns false" do
    #       expect(subject).to be_false
    #     end
    #   end

    #   context "saving" do
    #     let(:Encounter){ Encounter.new({ :firstname => 'Badsex', :sex => 'G'}, '12345') }
    #     subject{ Encounter.save }

    #     it "returns object with errors added" do
    #       expect(subject.errors).to include(:sex)
    #     end

    #     it "returns unpersisted object" do
    #       expect(subject.persisted?).to be_false
    #     end
    #   end

    # end

  end
end
