module KpfLoanClips
  class Approve
    def initialize(config:)
      @config                                 = config
      @user                                   = @config[:user]
      @kpf_loan_clip                          = @config[:kpf_loan_clip]
      @branch                                 = @kpf_loan_clip.branch
      @data                                   = @kpf_loan_clip.data.with_indifferent_access   
      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
    end

    def execute!  
   
      @kpf_loan_clip.update!(
        data: @data,
        approved_by: @user.full_name,
        date_approved: @date_approved
      )
      @kpf_loan_clip
    
    end
  end
  
end