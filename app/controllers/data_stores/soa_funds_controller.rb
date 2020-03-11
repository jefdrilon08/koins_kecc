module DataStores
  class SoaFundsController < DataStoreController
    def show
      @record = DataStore.soa_funds.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/soa_funds"
      end

      @meta   = @record.meta.with_indifferent_access
      @data   = @record.data.with_indifferent_access
    end

    def turkey
      @command = Turkey::ComputeSoaFunds.new(
        branch: Branch.find_by(id: params[:branch_id]) || Branch.first,
        from: Date.parse(params[:from].presence || "2019-11-07"),
        to: Date.parse(params[:to].presence || "2020-02-15"),
      )
      @result = @command.run
    end
  end
end
