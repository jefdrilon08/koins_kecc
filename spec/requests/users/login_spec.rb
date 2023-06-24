require 'rails_helper'

RSpec.describe 'Login' do
  include ApiHelpers

  let(:user) { FactoryBot.create(:user) }
  let(:valid_username) { user.username }
  let(:valid_password) { user.password }
  let(:api_url) { '/api/authenticate' }

  describe "POST /api/authenticate", type: :request do
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

      it 'returns error on invalid username / password' do
        invalid_password = 'test'

        post api_url, params: { username: user.username, password: invalid_password }

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['password']).to eq(['invalid password'])
      end
    end

    context 'valid calls' do
    end
  end
end
