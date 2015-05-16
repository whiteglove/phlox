require 'spec_helper'

module Phlox
  module Openemr
    describe Patient do

      shared_examples "a persisted Patient" do
        it "returns a patient object when successful" do
          expect(subject).to be_a(Phlox::Openemr::Patient)
        end

        it "returns a persisted objected when successful" do
          subject.persisted?.should == true
        end
      end

      context "when validating" do

        it "allows valid attributes" do
          subject.attributes.merge!({:sex => 'Male', :country_code => 'USA', :state => 'TX',
                                     :ethnicity => 'not_hisp_or_latin', :title => 'Mr.'})
          expect(subject).to be_valid
        end

        it "doesn't allow invalid sex" do
          subject.sex = 'Bad'
          expect(subject).to_not be_valid
        end

        it "doesn't allow invalid country codes" do
          subject.country_code = 'United States'
          expect(subject).to_not be_valid
        end

        it "doesn't allow invalid state" do
          subject.state = 'Texas'
          expect(subject).to_not be_valid
        end

        it "doesn't allow invalid ethnicity" do
          subject.ethnicity = 'white'
          expect(subject).to_not be_valid
        end

        it "doesn't allow invalid titles (honorific)" do
          subject.title = 'Mister'
          expect(subject).to_not be_valid
        end

      end

      context "#find_by_id" do

        context "for exisiting patient" do
          before(:all) do
            ar_response = "<PatientList><status>0</status><reason>Success patient processing record</reason><Patient><demographics><id>1</id><pid>2</pid></demographics></Patient></PatientList>"
            ActiveResource::HttpMock.respond_to do |mock|
              mock.post "/openemr/api/getpatientrecord", {}, ar_response, 200
            end
          end

          subject { Patient.find_by_id(2, '12345') }
          it_behaves_like "a persisted Patient"

        end


        context "for non-exisiting patient" do
          before(:all) do
            ar_response = "<PatientList><status>0</status><reason>Success patient processing record</reason><Patient><patientdata><status>1</status></patientdata></Patient></PatientList>"
            ActiveResource::HttpMock.respond_to do |mock|
              mock.post "/openemr/api/getpatientrecord", {}, ar_response, 200
            end
          end

          it "raises an error when unsuccessful" do
            expect{ Patient.find_by_id(2, '12345') }.to raise_error(ActiveResource::ClientError)
          end
        end

      end


      context "with valid attributes" do
        before(:all) do
          add_response = "<Patient><status>0</status><patientId>2</patientId><reason>The Patient has been added</reason></Patient>\n"
          update_response = "<Patient><status>0</status><patientId>2</patientId><reason>The Patient has been updated</reason></Patient>\n"
          ar_response = "<PatientList><status>0</status><reason>Success patient processing record</reason><Patient><demographics><id>1</id><pid>2</pid></demographics></Patient></PatientList>"
          ActiveResource::HttpMock.respond_to do |mock|
            mock.post "/openemr/api/getpatientrecord", {}, ar_response, 200
            mock.post "/openemr/api/addpatient", {}, add_response, 200
            mock.post "/openemr/api/updatepatient", {}, update_response, 200
          end
        end

        context "creating" do
          subject{ Patient.create({:firstname => 'Test'}, '12345') }
          it_behaves_like "a persisted Patient"
        end

        context "updating" do
          let(:patient){ Patient.find_by_id(1, '12345') }
          subject{ patient.update_attributes(:firstname => 'Testme') }

          it "returns true" do
            patient.update_attributes(:firstname => 'Testme').should == true
          end
        end

        context "saving" do
          let(:patient){ Patient.new({:firstname => 'Test', :lastname => 'Meout'}, '12345') }
          subject{ patient.save }
          it_behaves_like "a persisted Patient"
        end

      end


      context "with invalid attributes" do

        context "creating" do
          subject{ Patient.create({:firstname => 'Badsex', :sex => 'G'}, '12345') }
          it "returns object with errors added" do
            expect(subject.errors).to include(:sex)
          end

          it "returns unpersisted object" do
            subject.persisted?.should == false
          end
        end

        context "updating" do
          before(:all) do
            ar_response = "<PatientList><status>0</status><reason>Success patient processing record</reason><Patient><demographics><id>1</id><pid>2</pid></demographics></Patient></PatientList>"
            ActiveResource::HttpMock.respond_to do |mock|
              mock.post "/openemr/api/getpatientrecord", {}, ar_response, 200
            end
          end
          let(:patient){ Patient.find_by_id(1, '12345') }
          subject{ patient.update_attributes(:sex => 'G') }

          it "returns false" do
            subject.should == false
          end
        end

        context "saving" do
          let(:patient){ Patient.new({ :firstname => 'Badsex', :sex => 'G'}, '12345') }
          subject{ patient.save }

          it "returns object with errors added" do
            expect(subject.errors).to include(:sex)
          end

          it "returns unpersisted object" do
            subject.persisted?.should == false
          end
        end

      end

    end
  end
end
