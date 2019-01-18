module Monitoring
  class AccountingEntryPrecision
    def initialize(config:)
      @config = config
      @branch = @config[:branch]

      @start_date = @config[:start_date].try(:to_date)
      @end_date   = @config[:end_date].try(:to_date)

      @data = {
        journal_entries: []
      }

      @journal_entries  = JournalEntry.joins(:accounting_entry).where(
                            "accounting_entries.branch_id = ?",
                            @branch.id
                          ).order("accounting_entries.date_posted DESC")

      if @start_date.present? and @end_date.present?
        @journal_entries  = @journal_entries.where(
                              "accounting_entries.date_posted >= ? AND accounting_entries.date_posted <= ?",
                              @start_date,
                              @end_date
                            )
      end
    end

    def execute!
      @journal_entries.each do |o|
        if o.amount > 0 and o.amount.to_f.to_s.split(".").last.size > 2
          @data[:journal_entries] << {
            id: o.id,
            amount: o.amount.to_f,
            post_type: o.post_type,
            accounting_entry: {
              id: o.accounting_entry.id,
              particular: o.accounting_entry.particular,
              book: o.accounting_entry.book,
              date_posted: o.accounting_entry.date_posted.strftime("%B %d, %Y")
            },
            accounting_code: {
              id: o.accounting_code.id,
              name: o.accounting_code.name,
              code: o.accounting_code.code
            }
          }
        end
      end

      @data
    end
  end
end
