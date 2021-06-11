module Print
  class BuildAccruedBilling
    include ActionView::Helpers::NumberHelper

    def initialize(accrued_billing:)
      @accrued_billing  = accrued_billing

      @data = {}
    end

    def execute!
      @accrued_billing
      @data[:center] = Center.find(@accrued_billing.center_id).to_s
      @data[:branch] = Branch.find(@accrued_billing.branch_id).to_s
      @data[:collection_date] = @accrued_billing.collection_date
      @data[:data] = @accrued_billing
      @data
    end
  end
end