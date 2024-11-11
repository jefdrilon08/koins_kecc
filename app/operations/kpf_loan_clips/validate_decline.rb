module KpfLoanClips
  class ValidateDecline < AppValidator

    def initialize(config:)
      super()

      @config        = config
      @kpf_loan_clip         = @config[:kpf_loan_clip]
    end

    def execute!

      if @kpf_loan_clip.blank?
        @errors[:messages] << {
          key: "kpf_loan_clip",
          message: "record not found"
        }
      end

      # if @kpf_loan_clip.approved?
      #   @errors[:messages] << {
      #     key: "kpf_loan_clip",
      #     message: "KDAKILA is already approved!"
      #   }
      # end

      @errors
    end
  end
end
