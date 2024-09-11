module InsuranceFundTransferCollections
  class Approve
    def initialize(config:)
      @config                              = config
      @insurance_fund_transfer_collection  = @config[:insurance_fund_transfer_collection]
      @user                                = @config[:user]

      @data                                = @insurance_fund_transfer_collection.try(:data).try(:with_indifferent_access)
      @data_fund_transfers                 = @insurance_fund_transfer_collection.deposits

      @branch                              = @insurance_fund_transfer_collection.branch
      @branch_id                           = @insurance_fund_transfer_collection[:branch_id]
      if Settings.activate_microinsurance
        @date_approved                     = @insurance_fund_transfer_collection.collection_date
      else
        @date_approved                     = ::Utils::GetCurrentDate.new(
                                              config: {
                                                branch: @branch
                                              }
                                            ).execute!
      end
    end

    def execute!
      process_fund_transfers!
      update_insurance_status_per_branch!
      @data[:approved_by] = @user.full_name

      @insurance_fund_transfer_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @insurance_fund_transfer_collection
    end

    private

    def process_fund_transfers!
      @data_fund_transfers.each do |o|
        config  = {
          date_paid: @date_approved,
          insurance_fund_transfer: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data[:particular]
        }

        ::InsuranceFundTransferCollections::ApproveInsuranceFundTransferHash.new(
          config: config
        ).execute!
      end
    end

    def update_insurance_status_per_branch!
      begin
        ProcessUpdateInsuranceStatusPerBranch.perform_later('adjust:update_insurance_status_per_branch', @branch_id)
      rescue => e
        # Handle the exception or log it
        Rails.logger.error("Failed to update insurance status: #{e.message}")
      end
    end

  end
end
