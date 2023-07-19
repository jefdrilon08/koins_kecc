module Adjustments
  module SubsidiaryAdjustments
    class Create
      def initialize(config:)
        @config = config
        @branch = @config[:branch]
        @user   = @config[:user]

        @current_date = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
      end

      def execute!
        @meta = {
          date_generated: @current_date,
          branch: {
            id: @branch.id,
            name: @branch.name
          },
          generated_by: @user
        }
       
        if Settings.activate_microinsurance
          branch_id  = Settings.try(:defaults).try(:default_branch).try(:id)
          @branch = Branch.where(id: branch_id).first
        end
       
        @data = {
          records: [],
          accounting_entry: {
            book: "JVB",
            reference_number: "",
            date_prepared: @current_date,
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
