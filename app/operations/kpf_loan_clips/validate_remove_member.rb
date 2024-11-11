module KpfLoanClips
  class ValidateRemoveMember < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @kpf_loan_clip  = @config[:kpf_loan_clip]
      @member                                 = @config[:member]

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

      if @member.present? and !@kpf_loan_clip.member_ids.include?(@member.id)
        @errors[:messages] << {
          key: "message",
          message: "Member not found"
        }
      end

      

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
