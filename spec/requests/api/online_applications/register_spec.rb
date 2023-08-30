require 'rails_helper'

RSpec.describe 'Register' do
  include ApiHelpers

  let (:api_url) { '/api/register' }
  let (:online_application) { FactoryBot.create(:online_application) }

  describe "POST /register" do
    context 'invalid calls' do
      it 'returns error on no parameters passed' do
        post api_url

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['first_name']).to eq(['required'])
        expect(payload['last_name']).to eq(['required'])
        expect(payload['gender']).to eq(['required'])
        expect(payload['date_of_birth']).to eq(['required'])
        expect(payload['email']).to eq(['required'])
        expect(payload['mobile_number']).to eq(['required'])
        expect(payload['address_region']).to eq(['required'])
        expect(payload['address_province']).to eq(['required'])
        expect(payload['address_city']).to eq(['required'])
        expect(payload['address_district']).to eq(['required'])
        expect(payload['address_street']).to eq(['required'])
        expect(payload['files']).to eq(['required'])
        expect(payload['profile_picture']).to eq(['required'])
        expect(payload['reason_for_joining']).to eq(['required'])
        expect(payload['sss_number']).to eq(['required'])
        expect(payload['tin_number']).to eq(['required'])
        expect(payload['pag_ibig_number']).to eq(['required'])
        expect(payload['phil_health_number']).to eq(['required'])
      end

      it 'returns error on duplicate application' do
        online_application

        invalid_params = {
          email: online_application.email,
          mobile_number: online_application.mobile_number
        }

        post api_url, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['email']).to eq(['duplicate value'])
        expect(payload['mobile_number']).to eq(['duplicate value'])
      end

      it 'returns error on invalid values' do
        invalid_params = {
          email: 'invalid-value',
          gender: 'invalid-value',
          date_of_birth: 'invalid-value',
          mobile_number: 'invalid-value',
          sss_number: 'invalid-value',
          tin_number: 'invalid-value',
          pag_ibig_number: 'invalid-value',
          phil_health_number: 'invalid-value'
        }

        post api_url, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['email']).to eq(['invalid value'])
        expect(payload['gender']).to eq(['invalid value'])
        expect(payload['date_of_birth']).to eq(['invalid value'])
        expect(payload['mobile_number']).to eq(['invalid value'])
        expect(payload['sss_number']).to eq(['invalid value'])
        expect(payload['tin_number']).to eq(['invalid value'])
        expect(payload['pag_ibig_number']).to eq(['invalid value'])
        expect(payload['phil_health_number']).to eq(['invalid value'])
      end
    end

    context 'valid calls' do
    end
  end
end
