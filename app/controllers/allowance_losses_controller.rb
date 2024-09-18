class AllowanceLossesController < ApplicationController
  before_action :authenticate_user!

  def generate
    @datastore_as_of = DataStore.where("meta ->> 'data_store_type' = ?", 'ALLOWANCE_COMPUTATION').all
    payload = {
      date_as_of: @datastore_as_of.map { |record| record.meta['as_of'] },
      token: current_user.generate_jwt
    }
  end
end
