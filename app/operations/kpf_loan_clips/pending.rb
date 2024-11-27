module KpfLoanClips
  class Pending
    def initialize(config:)
      @config           = config
      @kpf_loan_clip    = @config[:kpf_loan_clip]
      @user             = @config[:user]
      @branch           = @kpf_loan_clip.branch
      @data             = @kpf_loan_clip.data.with_indifferent_access
      @c_working_date   = Date.today
    end

    def execute!
      @kpf_loan_clip.update!(
        status: "pending",
        data: @data
      )
      @kpf_loan_clip
    end

  end
end
