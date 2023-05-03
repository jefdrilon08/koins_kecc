module Kmba
  class SaveClaims
     attr_accessor :member

    def initialize(claims_data:)
      super()
      @claims_data = claims_data
    # raise @config.inspect
    end

    def execute!
      # raise @member_data.
        claims_data = Claim.new(
          date_prepared: @claims_data[:date_prepared],
          prepared_by: @claims_data[:prepared_by],
          created_at: @claims_data[:created_at],
          updated_at: @claims_data[:updated_at],
          member_id: @claims_data[:member_id],
          center_id: @claims_data[:center_id],
          branch_id: @claims_data[:branch_id],
          claim_type: @claims_data[:claim_type],
          data: @claims_data[:data],
          status: @claims_data[:status],
          approved_by: @claims_data[:approved_by],
          checked_by: @claims_data[:checked_by],
          date_checked: @claims_data[:date_checked],
          date_approved: @claims_data[:date_approved],
          posted_by: @claims_data[:posted_by],
          date_posted: @claims_data[:date_posted]
        )

        # raise @claims_data.inspect

        Rails.logger.info(puts " New Claims is Saved! Member ID NO : #{@claims_data[:member_id]}, saved! ")
        claims_data.save!
    # raise member.inspect
    # @member = Member.find(@member.id)
    end
  end
end
