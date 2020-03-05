module Insurance
  class FetchMembersForReinsurance
    def execute!
      members = []

      Member.active.find_each do |member|
        total_loan_amount = 0.00

        member.loans.active.find_each do |loan|
          clip = loan
            .accounting_entry
            .try!(:journal_entries)
            .try!(:exists?, accounting_code_id: CLIP_ACCOUNTING_CODE_ID)

          total_loan_amount += loan.principal if clip
        end

        members << member if total_loan_amount > REINSURANCE_THRESHOLD_AMOUNT
      end

      members
    end
  end
end
