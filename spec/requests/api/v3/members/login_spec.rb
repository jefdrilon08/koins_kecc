require 'rails_helper'

RSpec.describe 'Members Login' do
  let(:member) { FactoryBot.create(:member) }
  let(:api_url) { '/api/members/login' }

  describe "POST /api/members/login", type: :request do
    context 'invalid calls' do
      it 'returns error on no parameters passed' do
        post api_url

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['username']).to eq(['username required'])
        expect(payload['password']).to eq(['password required'])
      end

      it 'returns error on no user found' do
        invalid_username = 'test'
        invalid_password = 'test'

        post api_url, params: { username: invalid_username, password: invalid_password }

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['username']).to eq(['user not found'])
      end

      it 'returns error on invalid status' do
        post api_url, params: { username: member.username, password: 'password' }

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['username']).to eq(['invalid status'])
      end

      it 'returns error on invalid password' do
        invalid_password = 'test'

        post api_url, params: { username: member.username, password: invalid_password }

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['password']).to eq(['invalid password'])
      end
    end

    context 'valid calls' do
      valid_usernamme = 'test_member'
      valid_password = 'test_password'

      valid_member = FactoryBot.create(
        :member,
        username: valid_username,
        password: test_password,
        password_confirmation: test_password
      )

      post api_url, params: { username: valid_username, password: valid_password }

      expect(response).to have_http_status(:ok)
    end
  end
end
