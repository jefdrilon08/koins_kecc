module Print
  class BuildBook
    include ActionView::Helpers::NumberHelper

    def initialize(config:)
      @config = config

      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
      @branch     = @config[:branch]
      @book       = @config[:book].try(:upcase)

      if @book == "JVB"
        @book_display = "General Journal"
      elsif @book == "CRB"
        @book_display = "Cash Receipts"
      elsif @book == "CDB"
        @book_display = "Cash Disbursements"
      end

      @data   = {
        start_date:   @config[:start_date].try(:to_date).try(:strftime, "%m/%d/%Y"),
        end_date:     @config[:end_date].try(:to_date).try(:strftime, "%m/%d/%Y"),
        book:         @book,
        book_display: @book_display
      }
    end

    def execute!
      @accounting_entries = AccountingEntry.approved.includes(:journal_entries).where(
                              "date_posted >= ? AND date_posted <= ? AND branch_id = ? AND book = ?",
                              @start_date,
                              @end_date,
                              @branch.id,
                              @book
                            ).order("reference_number ASC, date_posted ASC")

      @data[:accounting_entries]  = @accounting_entries.map{ |o|
                                      {
                                        id: o.id,
                                        reference_number: o.reference_number,
                                        date_posted: o.date_posted.strftime("%m/%d/%Y"),
                                        particular: o.particular,
                                        debit_entries:  o.journal_entries.where("post_type = ? AND amount > 0", "DR").map{ |e|
                                                          {
                                                            accounting_code: {
                                                              name: e.try(:accounting_code).try(:name),
                                                              code: e.try(:accounting_code).try(:code)
                                                            },
                                                            debit_amount: number_to_currency(e.amount, unit: ""),
                                                            credit_amount: ""
                                                          }
                                                        },
                                        credit_entries: o.journal_entries.where("post_type = ? AND amount > 0", "CR").map{ |e|
                                                          {
                                                            accounting_code: {
                                                              name: e.try(:accounting_code).try(:name),
                                                              code: e.try(:accounting_code).try(:code)
                                                            },
                                                            debit_amount: "",
                                                            credit_amount: number_to_currency(e.amount, unit: "")
                                                          }
                                                        }
                                      }
                                    }

      @data
    end
  end
end
