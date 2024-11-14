module KpfLoanClips
  class AddMember
    def initialize(config:)
      @config               = config
      @kpf_loan_clip        = @config[:kpf_loan_clip]
      @kpf_loan_clip_data   = @kpf_loan_clip.data.with_indifferent_access
      @kpf_loan_clip_count  = @kpf_loan_clip_data[:records].count
      @user                 = @config[:user]
      @member               = @config[:member]
      @principal            = @config[:principal].to_i
      @term                 = @config[:term]
      @maturity_date        = @config[:maturity_date]
      @effective_date       = @config[:effective_date]
      @clip_number          = @config[:clip_number]
      @beneficiary          = @config[:beneficiary]
      @num_installments     = @config[:num_installments]

      @data                 = @kpf_loan_clip.try(:data).try(:with_indifferent_access)
      @branch               = @kpf_loan_clip.branch
      
      # raise @config.inspect
      
    end

    def execute!
      # @insurance_account  = MemberAccount.where(member_id: @member.id, account_subtype: @insurance_subtype).first
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
            # insurance_account_id: @insurance_account.id,
            # amount: @amount,
            # insurance_account_balance: @insurance_account.balance
          }
        

      # total_amount  = @data[:records].inject(0){ |sum, hash| sum + hash[:amount] }.round(2)
      # @savings_insurance_transfer_collection.update!(data: @data, total_amount: total_amount)
      @kpf_loan_clip.update!(data: @data)
      @kpf_loan_clip


      
    end
  end
end