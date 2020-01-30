module Loans
  class FetchJournalEntries
    def initialize(config:)
      @config = config

      @accounting_code_id = @config[:accounting_code_id]
      @branch             = @config[:branch]
      
      @data = {
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        records: []
      }
    end

    def execute!
      query!

      @data[:records] = @result.map{ |r|
                          id                    = r.fetch("loan_id")
                          principal             = r.fetch("principal").to_f.round(2)
                          interest              = r.fetch("interest").to_f.round(2)
                          first_date_of_payment = r.fetch("first_date_of_payment")
                          maturity_date         = r.fetch("maturity_date")
                          accounting_entry_id   = r.fetch("accounting_entry_id")
                          journal_entry_id      = r.fetch("journal_entry_id")
                          amount                = r.fetch("amount").to_f.round(2)
                          loan_product_id       = r.fetch("loan_product_id")
                          loan_product_name     = r.fetch("loan_product_name")
                          date_released         = r.fetch("date_released")
                          date_approved         = r.fetch("date_approved")
                          member_id             = r.fetch("member_id")

                          {
                            id: id,
                            principal: principal,
                            interest: interest,
                            first_date_of_payment: first_date_of_payment,
                            maturity_date: maturity_date,
                            accounting_entry_id: accounting_entry_id,
                            journal_entry_id: journal_entry_id,
                            amount: amount,
                            loan_product_id: loan_product_id,
                            loan_product_name: loan_product_name,
                            member_id: member_id,
                            date_approved: date_approved,
                            date_released: date_released
                          }
                        }
      @data
    end

    private

    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT
                    loans.id AS loan_id,
                    loans.principal,
                    loans.interest,
                    loans.first_date_of_payment,
                    loans.maturity_date,
                    accounting_entries.id AS accounting_entry_id,
                    journal_entries.id AS journal_entry_id,
                    journal_entries.amount,
                    loan_products.id AS loan_product_id,
                    loan_products.name AS loan_product_name,
                    loans.date_approved,
                    loans.date_released,
                    members.id AS member_id
                  FROM
                    loans
                  INNER JOIN members
                    ON
                      members.id = loans.member_id
                  INNER JOIN loan_products
                    ON
                      loan_products.id = loans.loan_product_id
                  INNER JOIN accounting_entries
                    ON
                      accounting_entries.reference_number = loans.data->'accounting_entry'->>'reference_number'
                      AND
                      accounting_entries.book = loans.data->'accounting_entry'->>'book'
                      AND
                      accounting_entries.status = 'approved'
                      AND
                      accounting_entries.branch_id = '#{@branch.id}'
                  INNER JOIN journal_entries
                    ON
                      journal_entries.accounting_entry_id = accounting_entries.id
                      AND
                      journal_entries.accounting_code_id = '#{@accounting_code_id}'
                  WHERE
                    loans.status IN ('active', 'paid') AND loans.branch_id = '#{@branch.id}'
                EOS
    end
  end
end
