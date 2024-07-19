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
      branch = @branch_id

      Loan.where(branch: branch, status: 'writeoff').find_each do |loan|
        center_name = Center.find_by(id: loan.center_id)&.name
        loan_product_name = LoanProduct.find_by(id: loan.loan_product_id)&.name
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

      @data_record
    end

    def fetch_account_balances(member_id)
      account_types = {
        rsa: 'K-IMPOK',
        gk: 'Golden K',
        mbs: 'Maintaining Balance Savings',
        rf: 'Retirement Fund',
        cbu: 'CBU',
        sc: 'Share Capital'
      }

      balances = {}
      account_types.each do |key, subtype|
        balances[key] = MemberAccount.find_by(member_id: member_id, account_subtype: subtype)&.balance.to_f || 0.0
      end

      balances
    end

    def execute!
      records = generate_report
      data_store = DataStore.find_by!(id: @data_store_id)
      data_store.update!(data: { records: records })
    end
  end
end
