module KpfLoanClips
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                = config
      @kpf_loan_clip         = @config[:kpf_loan_clip]
      @kpf_loan_clip_data    = @kpf_loan_clip.data.with_indifferent_access
      @kpf_loan_clip_count   = @kpf_loan_clip_data[:records].count
      @member                = @config[:member]
      @loan_product_id       = @config[:loan_product_id]
      @principal             = @config[:principal]
      @num_installments      = @config[:num_installments]
      @effective_date        = @config[:effective_date]
      @maturity_date         = @config[:maturity_date]
      @clip_number           = @config[:clip_number]
      @beneficiary           = @config[:beneficiary]
      @data                  = @kpf_loan_clip.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @kpf_loan_clip.present? and !@kpf_loan_clip.pending?
        @errors[:messages] << {
          key: "kpf_loan_clip",
          message: "record is not pending"
        }
      end
      
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member required"
        }
      end

      if @loan_product_id.blank?
        @errors[:messages] << {
          key: "loan_product_id",
          message: "Loan Product required"
        }
      end

      if @principal.blank?
        @errors[:messages] << {
          key: "principal",
          message: "Principal Date required"
        }
      end

      if @num_installments.blank?
        @errors[:messages] << {
          key: "num_installments",
          message: "Term required"
        }
      end

      if @effective_date.blank?
        @errors[:messages] << {
          key: "effective_date",
          message: "Effectivity Date required"
        }
      end

      if @maturity_date.blank?
        @errors[:messages] << {
          key: "maturity_date",
          message: "Maturity Date required"
        }
      end

      if @clip_number.blank?
        @errors[:messages] << {
          key: "clip_number",
          message: "CLIP Number required"
        }
      end

      if @beneficiary.blank?
        @errors[:messages] << {
          key: "beneficiary",
          message: "CLIP Beneficiary required"
        }
      end

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end