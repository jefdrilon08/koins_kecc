module DataStores
  class GenerateWrittenOffReport
    attr_reader :data_record

    def initialize(config:)
      @config = config
      @branch_id = @config[:branch_id]
      @branch_name = @config[:branch_name]
      @data_store_id = @config[:data_store_id]
      @data_record = []
    end

    def generate_report
      Loan.where(branch: @branch_id, status: 'writeoff').includes(:center, :loan_product).find_each do |loan|
        center_name = loan.center&.name
        loan_product_name = loan.loan_product&.name
        balances = fetch_account_balances(loan.member_id)

        @data_record << {
          members: {
            full_name: loan.data['member_full_name'],
            member_id: loan.member_id
          },
          center: {
            center_id: loan.center_id,
            center_name: center_name
          },
          loan_product_id: loan.loan_product_id,
          loan_product_name: loan_product_name,
          principal_balance: loan.principal_balance.to_f,
          interest_balance: loan.interest_balance.to_f,
          total_balance: loan.total_balance.to_f,
          maturity_date: loan.maturity_date,
          **balances
        }
      end
    end

    def fetch_account_balances(member_id)
      account_types = {
        rsa: 'K-IMPOK',
        gk: 'Golden K',
        mbs: 'Maintaining Balance Savings',
        rf: 'Retirement Fund',
        cbu: 'CBU',
        sc: 'Share Capital',
        equity_value: 'Equity Value'
      }

      account_types.transform_values do |subtype|
        MemberAccount.find_by(member_id: member_id, account_subtype: subtype)&.balance.to_f || 0.0
      end
    end

    def execute!
      generate_report
      DataStore.find_by!(id: @data_store_id).update!(data: { records: @data_record })
    end
  end
end
