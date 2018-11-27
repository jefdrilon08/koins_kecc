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
      @data
    end
  end
end
