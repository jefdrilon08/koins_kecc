module KpfLoanClips
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                = config
      @kpf_loan_clip         = @config[:kpf_loan_clip]
      @kpf_loan_clip_data    = @kpf_loan_clip.data.with_indifferent_access
      @kpf_loan_clip_count   = @kpf_loan_clip_data[:records].count
      @member                = @config[:member]
      @data = @kpf_loan_clip.try(:data).try(:with_indifferent_access)
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

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end