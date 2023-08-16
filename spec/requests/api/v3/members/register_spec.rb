require 'rails_helper'

RSpec.describe 'Allow a Member to Register in the System' do
  include ApiHelpers

  let(:api_url) { '/api/v3/members/register' }

  describe "POST /api/v3/members/register", type: :request do
    context 'invalid calls' do
      it 'fails when no parameters passed' do
      end

      it 'fails on duplicate values' do
      end
    end

    context 'valid calls' do
      it 'succeeds to register a member' do
      end
    end
  end
end
