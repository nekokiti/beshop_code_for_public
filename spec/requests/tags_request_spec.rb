require 'rails_helper'

RSpec.describe TagsController, type: :request do
  login_company
  let!(:tags) {
    tags = []
    10.times do
      tags << create(:tag, company: company)
    end
    tags
  }

  describe "GET #index" do
    before do
      get tags_url
    end
    it "returns a success response" do
      expect(response).to be_success
    end
    it "gets tags related sign in compnay" do
      tags.each do | tag |
        expect(response.body).to include tag.tag_name
      end
    end
  end

  # Tag doesn't have show page
  # describe "GET #show" do
  # end

  describe "GET #new" do
    before do
      get new_tag_url, params: {}
    end
    it "returns a success response" do
      expect(response).to be_success
    end
    it "assigns a tag instance" do
      expect(response.body).to include "New Tag"
    end
  end

  describe "GET #edit" do
    before do
      get edit_tag_url tags.first.to_param
    end
    it "returns a success response" do
      expect(response).to be_success
    end
    it "assigns a tag" do
      expect(response.body).to include tags.first.tag_name
    end
  end

  describe "GET #csv_export" do
    it "returns a success response" do
      get csv_export_tags_url
      expect(response).to be_success
    end
  end

  describe "POST #csv_import" do
    it "creates a new Tag by csv" do
      file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec/support/tags_sample.csv'), 'file/csv'
      )
      post csv_import_tags_url, params: {file: file}
      expect(response).to redirect_to tags_url
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_attributes) do {
        company: company,
        tag_name: Faker::Commerce.product_name + "_unique",
        image_path: Rack::Test::UploadedFile.new(
          Rails.root.join('spec/support/sample.jpg'), 'image/jpeg'
        ),
      } end
      it "creates a new Tag" do
        expect {
          post tags_url, params: {tag: valid_attributes}
        }.to change(Tag, :count).by(1)
      end

      it "redirects to the created tag" do
        post tags_url, params: {tag: valid_attributes}
        expect(response).to redirect_to(edit_tag_url Tag.last)
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) do {
      tag_name: Faker::Commerce.product_name + "_new"
    }
    end

    it "is success to request" do
      put tag_url tags.first, params: { tag: new_attributes }
      expect(response.status).to eq 302
    end

    it "redirect to the updated product" do
      put tag_url tags.first, params: { tag: new_attributes }
      expect(response).to redirect_to(edit_tag_url tags.first)
    end

    it "updates the requested tag" do
      old_name = tags.first.tag_name
      new_name = new_attributes[:tag_name]
      expect do
        put tag_url tags.first, params: { tag: new_attributes }
      end.to change { Tag.find(tags.first.id).tag_name }.from(old_name).to(new_name)
      expect(flash[:notice]).to eq 'Tag was successfully updated.'
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested tag" do
      expect {
        delete tag_url tags.first
      }.to change(Tag, :count).by(-1)
    end

    it "redirects to the tags list" do
      delete tag_url tags.first
      expect(response).to redirect_to(tags_url)
    end
  end

end
