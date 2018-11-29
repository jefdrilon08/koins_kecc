module Print
  class BuildBilling
    include ActionView::Helpers::NumberHelper

    def initialize(billing:)
      @billing  = billing

      @data = {}
    end

    def execute!
      @data[:collection_date] = @billing.collection_date
      @data[:branch]          = Branch.find(@billing.branch_id).to_s
      @data[:center]          = Center.find(@billing.center_id).to_s
      @data[:data]            = @billing.data.with_indifferent_access

      # WP Details
      @data[:withdraw_payments] = @billing.withdraw_payments
      @data[:reference_number]  = @billing.reference_number
      @data[:particular]        = @billing.particular
      @data[:approved_by]       = @billing.approved_by

      accounting_entry  = {
        reference_number: @billing.reference_number,
        or_number: @billing.or_number,
        date_approved: @billing.date_approved,
        particular: @billing.particular
      }

      @data[:accounting_entry]  = accounting_entry

      @data
    end
  end
end
