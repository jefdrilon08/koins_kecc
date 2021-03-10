module Dashboard
  class GenerateAccountingReport
    attr_accessor :branch, :start_date, :end_date

    def initialize(config:)
      @config = config

      @branch           = @config[:branch]
      @start_date       = @config[:start_date]
      @end_date         = @config[:end_date]
      @core_user        = @config[:user]
      @accounting_fund  = @config[:accounting_fund]
    end

    def execute!
      generate_trial_balance!
      generate_general_ledger!
    end

    private

    def generate_trial_balance!
      data_store_type = "TRIAL_BALANCE"

      record  = DataStore.create!(
                  status: "processing",
                  meta: {
                    branch_id: @branch.id,
                    branch_name: @branch.name,
                    start_date: @start_date,
                    end_date: @end_date,
                    data_store_type: data_store_type,
                    accounting_fund_id: @accounting_fund.try(:id),
                    accounting_fund_name: @accounting_fund.try(:name),
                    user: {
                      id: @core_user.id,
                      first_name: @core_user.first_name,
                      last_name: @core_user.last_name
                    }
                  },
                  data: {
                    status: "processing"
                  }
                )

      args = {
        id: record.id,
        data_store_type: data_store_type
      }

      ProcessTrialBalance.perform_later(args)
    end

    def generate_general_ledger!
      data_store_type = "GENERAL_LEDGER"

      record  = DataStore.create!(
                  status: "processing",
                  meta: {
                    branch_id: @branch.id,
                    branch_name: @branch.name,
                    start_date: @start_date,
                    end_date: @end_date,
                    data_store_type: data_store_type,
                    accounting_fund_id: @accounting_fund.try(:id),
                    accounting_fund_name: @accounting_fund.try(:name),
                    user: {
                      id: @core_user.id,
                      first_name: @core_user.first_name,
                      last_name: @core_user.last_name
                    }
                  },
                  data: {
                    status: "processing"
                  }
                )

      args = {
        id: record.id,
        data_store_type: data_store_type
      }

      ProcessGeneralLedger.perform_later(args)
    end
  end
end
