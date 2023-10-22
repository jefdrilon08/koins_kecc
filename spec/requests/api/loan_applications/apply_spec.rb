require 'rails_helper'

RSpec.describe 'Apply for Loan Online' do
  include ApiHelpers

  let (:member) { FactoryBot.create(:member, status: 'active') }
  let (:invalid_member) { FactoryBot.create(:member) }
  let (:api_url) { "/api/members/loans" }
  let (:valid_member_headers) { build_jwt_header(member.generate_jwt) }
  let (:invalid_member_headers) { build_jwt_header(invalid_member.generate_jwt) }
  let (:loan_product) { FactoryBot.create(:loan_product) }

  describe "POST /api/members/loans", type: :request do
    context 'invalid calls' do
      it 'fails if member is not logged in' do
        post "#{api_url}"

        expect(response).to have_http_status(:forbidden)
      end

      it 'fails if member is not active' do
        post "#{api_url}", headers: invalid_member_headers

        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails if parameters are missing' do
        post "#{api_url}", headers: valid_member_headers

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['amount']).to eq(['required'])
        expect(payload['term']).to eq(['required'])
        expect(payload['num_installments']).to eq(['required'])
        expect(payload['date_applied']).to eq(['required'])
      end

      it 'fails if member has an existing pending loan application' do
        existing_loan_application = FactoryBot.create(
          :loan_application,
          member: member
        )

        post "#{api_url}", params: {}, headers: valid_member_headers

        expect(response).to have_http_status(:unprocessable_entity)

        payload = JSON.parse(response.body)

        expect(payload['loan_application']).to eq(['pending application'])
      end
    end

    context 'valid calls' do
      it 'succeeds to submit a loan application' do
        initial_count = LoanApplication.count
        expected_count = initial_count + 1

        valid_params = {
          loan_product_id:  loan_product.id,
          num_installments: 25,
          term:             'weekly',
          date_applied:     Date.today.strftime("%Y-%m-%d")
        }

        post "#{api_url}", params: valid_params, headers: valid_member_headers

        expect(response).to have_http_status(:ok)

        current_count = LoanApplication.count

        expect(current_count).to eq(expected_count)
      end
    end
  end
end
