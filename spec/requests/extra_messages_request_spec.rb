require 'rails_helper'

RSpec.describe ExtraMessagesController, type: :request do
  login_company
  let(:extra_message) { create(:extra_message, company: company, extra_message: "自由追加されたメッセージです") }

  describe 'GET #new' do
    before do
      get new_extra_message_url, params: {}
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a extra_message instance' do
      expect(response.body).to include '購入確認メッセージ設定'
    end
  end

  describe 'GET #edit' do
    before do
      get edit_extra_message_url extra_message.to_param
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a edit_extra_message' do
      expect(response.body).to include extra_message.extra_message
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        company: company,
        extra_message: "自由追加メッセージ"
      }
    end
    it 'creates a new extra_message' do
      expect {
        post extra_message_url, params: { extra_message: valid_attributes }
      }.to change(ExtraMessage, :count).by(1)
    end

    it 'redirects to the created extra_message' do
      post extra_message_url, params: { extra_message: valid_attributes }
      expect(response).to \
        redirect_to(edit_extra_message_url ExtraMessage.last)
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) do
      {
        id: extra_message.id,
        extra_message: '自由追加されたメッセージです。更新しました。'
      }
    end
    it 'is success to request' do
      put extra_message_url, params: { extra_message: new_attributes }
      expect(response.status).to eq 302
      expect(response).to \
        redirect_to(edit_extra_message_url extra_message)
    end
    it 'updates the requested extra_message' do
      put extra_message_url, params: { extra_message: new_attributes }
      expect(extra_message.reload.extra_message).to eq('自由追加されたメッセージです。更新しました。')
    end
  end
end
