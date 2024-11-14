module KpfLoanClips
  class RemoveMember
    def initialize(config:)
      @config         = config
      @kpf_loan_clip  = @config[:kpf_loan_clip]
      @member         = @config[:member]
      @member_index   = @config[:member_index]
      @user           = @config[:user]
      @branch         = @kpf_loan_clip.branch
      @data           = @kpf_loan_clip.try(:data).try(:with_indifferent_access)

    end

    def execute!
      @data[:records].each_with_index do |o, index|
        if @member_index.to_i == index
          @data[:records].delete_at(index)
        end
      end

      @kpf_loan_clip.update!(data: @data)
      @kpf_loan_clip
    end
  end
end