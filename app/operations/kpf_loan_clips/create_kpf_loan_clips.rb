module KpfLoanClips
  class CreateKpfLoanClips
    def initialize(config:)
      @config                               = config
      @collection_date                      = @config[:collection_date].try(:to_date)
      @user                                 = @config[:user]
      @branch                               = Branch.where(id: @config[:branch_id]).first
      @center                               = Center.where(id: @config[:center_id]).first

      @kpf_loan_clips = KpfLoanClip.new(
        branch: @branch,
        center: @center,
        collection_date: @collection_date
      )

      @data = {
        records: [
          member: {
            id: @config[:member_id],
            full_name: @config[:full_name],
            first_name: @config[:last_name],
            last_name: @config[:first_name],
            middle_name: @config[:middle_name],
          },
          clip_data: {
            loan_product_id: @config[:loan_product_id],
            loan_product_name: @config[:loan_product_name],
            principal: @config[:principal],
            term: @config[:term],
            num_installments: @config[:num_installments],
            maturity_date: @config[:maturity_date],
            effective_date: @config[:effective_date],
            clip_number: @config[:clip_number],
            beneficiary: @config[:beneficiary]
          }
        ]
      }
    end

    def execute!
      @kpf_loan_clips.data = @data
      @kpf_loan_clips.update!(status: "approved")
      @kpf_loan_clips.save!
      @kpf_loan_clips
    end
  end
end