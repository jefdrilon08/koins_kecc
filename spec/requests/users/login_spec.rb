require 'rails_helper'

RSpec.describe 'Login' do
  include ApiHelpers

  let(:user) { FactoryBot.create(:user) }
  let(:valid_username) { user.username }
  let(:valid_password) { user.password }

  describe 'POST /authenticate', type: :request do
    context 'invalid calls' do
      it 'returns error on no parameters passed' do
        post '/authenticate'

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expected_payload = { 'username': ['username required'], 'password': ['password required'] }
        expect(payload).to eq(expected_payload)
      end

      it 'returns error on invalid username / password' do
        invalid_username = 'test'
        invalid_password = 'test'

        post '/authenticate', params: { username: invalid_username, password: invalid_password }

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expected_payload = { 'username': ['invalid username'], 'password': ['invalid password'] }
        expect(payload).to eq(expected_payload)
      end
    end

    context 'valid calls' do
    end
  end
end
