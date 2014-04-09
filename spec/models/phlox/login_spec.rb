require 'spec_helper'

module Phlox
  describe Login do
    context "when authorizing a user" do
      subject { Login.authorize('test', 'me') }

      context "that is valid" do
        before(:all) do
          ar_response = "<MedMasterUser><status>0</status><reason>Ok.</reason><token>12345</token></MedMasterUser>\n"
          ActiveResource::HttpMock.respond_to do |mock|
            mock.post "/openemr/api/login", {}, ar_response, 200
          end
        end

        it "return a new Login" do
          subject.should be_a(Phlox::Login)
        end

        it "the token returned set as #token" do
          expect(subject.token).to eq('12345')
        end

        it "object is not persisted" do
          expect(subject.persisted?).to be_false
        end

      end

      context "that is invalid" do
        before(:all) do
          ar_response = "<MedMasterUser><status>-1</status><reason>Username/Password incorrect.</reason></MedMasterUser>\n"
          ActiveResource::HttpMock.respond_to do |mock|
            mock.post "/openemr/api/login", {}, ar_response, 200
          end
        end

        it "should raise an ActiveResource::ClientError" do
          expect{subject}.to raise_error(ActiveResource::ClientError)
        end
      end

    end

    context "when authorizing a system user" do
      subject { Login.system_authorize }

      before do
        ar_response = "<MedMasterUser><status>0</status><reason>Ok.</reason><token>12345</token></MedMasterUser>\n"
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/openemr/api/login", {}, ar_response, 200
        end
        Phlox.stub(:system_user).and_return('admin')
        Phlox.stub(:system_password).and_return('test')
        mock_login = Login.authorize('admin', 'test')
        Phlox::Login.should_receive(:authorize).with('admin','test').and_return(mock_login)
      end

      it "return a new Login" do
        subject.should be_a(Phlox::Login)
      end

      it "the token returned set as #token" do
        expect(subject.token).to eq('12345')
      end
    end
  end
end
