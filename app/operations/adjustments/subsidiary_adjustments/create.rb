module Adjustments
  module SubsidiaryAdjustments
    class Create
      def initialize(config:)
        @config = config
        @branch = @config[:branch]
        @user   = @config[:user]
      end

      def execute!
        @meta = {
          date_generated: Date.today,
          branch: {
            id: @branch.id,
            name: @branch.name
          },
          generated_by: @user
        }

        @data = {
          records: [],
          accounting_entry: {
            book: "JVB",
            reference_number: "",
            date_prepared: Date.today.strftime("%B %d, %Y"),
            company_name: Settings.company_name,
            branch: @branch.to_s.upcase,
            prepared_by: @user.to_s,
            particular: "",
            debit_journal_entries: [],
            credit_journal_entries: [],
            journal_entries: [],
            branch_id: @branch.id,
            branch_name: @branch.name,
            status: "display",
            data: {
              or_number: "",
              ar_number: "",
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }
        }

        @adjustment_record  = AdjustmentRecord.new(
                                adjustment_type: "subsidiary",
                                meta: @meta,
                                data: @data
                              )

        @adjustment_record.save!

        @adjustment_record
      end
    end
  end
end
