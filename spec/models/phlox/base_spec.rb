require 'spec_helper'

module Phlox
  describe Base do

    it "has a format of xml" do
      expect(subject.class.format).to be(ActiveResource::Formats::XmlFormat)
    end

    context "when posting" do
      before(:all) do
        ar_response = "<MedMasterUser><status>0</status><reason>Ok.</reason><token>12345</token></MedMasterUser>\n"
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/openemr/api/login", {}, ar_response, 200
        end
      end

      it "uses x-www-form-urlencoded headers" do
        subject.class.post(:login, {})
        expect(subject.class.headers['Content-Type']).to eq('application/x-www-form-urlencoded')
      end

      it "encodes the body as raw URL params" do
        Hash.any_instance.should_receive(:to_query).at_least(:once)
        subject.class.post(:login, {username: 'tim009', password: '34!345QR#'})
      end

    end
  end
end
