module DataStores
  class PersonalFundsController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.personal_funds.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'as_of' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.personal_funds.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/personal_funds"
      end
    end

    def destroy
      @record = DataStore.personal_funds.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/personal_funds"
    end

    def turkey
      @command = Turkey::ComputePersonalFunds.new(
        branch: Branch.find_by(id: params[:branch_id]) || Branch.first,
        as_of: Date.parse(params[:as_of].presence || "2019-11-07"),
      )
      @result = @command.run
    end
  end
end
