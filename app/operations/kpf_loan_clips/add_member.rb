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
      @loan_product_id      = @config[:loan_product_id]
      @data                 = @kpf_loan_clip.try(:data).try(:with_indifferent_access)
      @branch               = @kpf_loan_clip.branch
      @amount               = ((@principal * 0.014 * (@num_installments).to_i) / 12) 
      @full_name            = @member.full_name_formatted
      @identification_number = @member.identification_number
      
    end

    def execute!
      @data[:records] << {
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          full_name: @full_name,
          identification_number: @identification_number
        },
        clip_data: {
          loan_product_id: @loan_product_id,
          principal: @principal,
          term: @term,
          num_installments: @num_installments,
          maturity_date: @maturity_date,
          effective_date: @effective_date,
          clip_number: @clip_number,
          beneficiary: @beneficiary,
          amount: @amount,
          full_name: @full_name
        },
      }
      
      # total_amount  = @data[:records].inject(0){ |sum, hash| sum + hash[:amount] }.round(2)

      @kpf_loan_clip.update!(data: @data)
      @kpf_loan_clip
      
    end
  end
end