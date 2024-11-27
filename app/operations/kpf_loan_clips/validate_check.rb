module KpfLoanClips
  class ValidateCheck < AppValidator
    def initialize(config:)
      super()

      @config                            = config
      @kpf_loan_clip  = @config[:kpf_loan_clip]
    end

    def execute!
      if @kpf_loan_clip.blank?
        @errors[:messages] << {
          key: "kpf_loan_clip",
          message: "record not found"
        }
      end

      if !@kpf_loan_clip.pending?
        @errors[:messages] << {
          key: "kpf_loan_clip",
          message: "Invalid status"
        }
      end
     
      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end





