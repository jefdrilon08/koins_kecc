module KpfLoanClips
  class Check
    def initialize(config:)
      @config                           = config
      @kpf_loan_clip = @config[:kpf_loan_clip]
      @user                             = @config[:user]
      @branch                           = @kpf_loan_clip.branch
      @c_working_date                   = Date.today
      @data                             = @kpf_loan_clip.data.with_indifferent_access
    end


    def execute!
      @kpf_loan_clip.update!(
        status: "for-approval",
        data: @data,
        approved_by: @user.full_name,
      )

      @kpf_loan_clip
    end
  end
end