module DataStores
  class PersonalFundsController < DataStoreController
    def turkey
      @command = Turkey::ComputePersonalFunds.new(
        branch: Branch.find_by(id: params[:branch_id]) || Branch.first,
        as_of: Date.parse(params[:as_of].presence || "2019-11-07"),
      )
      @result = @command.run
    end
  end
end
