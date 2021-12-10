module SavingsInsuranceTransferCollections
  class AddMember
    def initialize(config:)
      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @member                                 = @config[:member]
      @amount                                 = @config[:amount]
      @user                                   = @config[:user]

      if @savings_insurance_transfer_collection.clip
        @loan_product_id                        = @config[:loan_product_id]
        @principal                              = @config[:principal]
        @term                                   = @config[:term]
        @num_installments                       = @config[:num_installments]
        @maturity_date                          = @config[:maturity_date]
        @effective_date                         = @config[:effective_date]
        @clip_number                            = @config[:clip_number]
        @beneficiary                            = @config[:beneficiary]

        if @loan_product_id.present?
          @loan_product_name = LoanProduct.find(@loan_product_id).to_s
        end
      end

      @data   = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)
      @branch = @savings_insurance_transfer_collection.branch

      @savings_subtype    = @data[:savings_subtype]
      @insurance_subtype  = @data[:insurance_subtype]
    end

    def execute!
      @savings_account    = MemberAccount.where(member_id: @member.id, account_subtype: @savings_subtype).first
      @insurance_account  = MemberAccount.where(member_id: @member.id, account_subtype: @insurance_subtype).first

      if @savings_insurance_transfer_collection.clip
        @data[:records] << {
          member: {
            id: @member.id,
            first_name: @member.first_name,
            middle_name: @member.middle_name,
            last_name: @member.last_name
          },
          clip_data: {
            loan_product_id: @loan_product_id,
            loan_product_name: @loan_product_name,
            principal: @principal,
            term: @term,
            num_installments: @num_installments,
            maturity_date: @maturity_date,
            effective_date: @effective_date,
            clip_number: @clip_number,
            beneficiary: @beneficiary
          },
          savings_account_id: @savings_account.id,
          insurance_account_id: @insurance_account.id,
          amount: @amount,
          savings_account_balance: @savings_account.balance,
          insurance_account_balance: @insurance_account.balance
        }
      else  
        @data[:records] << {
          member: {
            id: @member.id,
            first_name: @member.first_name,
            middle_name: @member.middle_name,
            last_name: @member.last_name
          },
          savings_account_id: @savings_account.id,
          insurance_account_id: @insurance_account.id,
          amount: @amount,
          savings_account_balance: @savings_account.balance,
          insurance_account_balance: @insurance_account.balance
        }
      end

      total_amount  = @data[:records].inject(0){ |sum, hash| sum + hash[:amount] }.round(2)

      @data[:accounting_entry]  = ::SavingsInsuranceTransferCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @savings_insurance_transfer_collection.update!(data: @data, total_amount: total_amount)

      @savings_insurance_transfer_collection
    end
  end
end
