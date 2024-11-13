module KpfLoanClips
  class Save
    def initialize(config:)
      @config             = config
      @branch             = @config[:branch]
      @center             = @config[:center]
      @collection_date    = @config[:collection_date]
      @user               = @config[:user]

      @kpf_loan_clip  = KpfLoanClip.new(
                                                  branch: @branch,
                                                  center: @center,
                                                  collection_date: @collection_date,
                                                  data: {
                                                    records: []
                                                  }
                                                )
    end

    def execute!
      @kpf_loan_clip.save!
      @kpf_loan_clip
    end
    
  end
end