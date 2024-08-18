require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:user) { create(:user) }
  let(:document) { create(:document, user: user) }

  before do
    sign_in user
    allow(controller).to receive(:render).and_return(nil)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all documents as @documents" do
      get :index
      expect(assigns(:documents)).to eq([document])
    end
  end

  describe "GET #index with search" do
    it "filters documents by filename" do
        matching_document = create(:document, user: user, file: fixture_file_upload('files/matching_file.xml', 'application/xml'))
        non_matching_document = create(:document, user: user, file: fixture_file_upload('files/other_file.xml', 'application/xml'))

        get :index, params: { query: 'matching_file.xml' }
        expect(assigns(:documents)).to eq([matching_document])
        expect(assigns(:documents)).not_to include(non_matching_document)
    end
  end
end