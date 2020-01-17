module Insurance
  class FetchMembersForReinsurance
    def initialize
      @members = []
    end

    def execute!
      Member.active.each do |member|
        loan_amount_total  = 0.00

        member.loans.where(status: "active").each do |loan|
          accounting_entry = loan.accounting_entry
          if !accounting_entry.nil?
            clip = accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
            if !clip.nil?
              loan_amount_total += loan.principal
            end
          end
        end

        if loan_amount_total > 200000
          @members << member
        end
      end

      @members
    end
  end
end
