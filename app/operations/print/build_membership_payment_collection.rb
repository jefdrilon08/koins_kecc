module Print
  class BuildMembershipPaymentCollection
    include ActionView::Helpers::NumberHelper

    def initialize(membership_payment_collection:)
      @membership_payment_collection  = membership_payment_collection

      @data = {}
    end

    def execute!
      @data[:collection_date] = @membership_payment_collection.collection_date
      @data[:branch]          = Branch.find(@membership_payment_collection.branch_id).to_s
      @data[:center]          = Center.find(@membership_payment_collection.center_id).to_s
      @data[:data]            = @membership_payment_collection.data.with_indifferent_access
      @data
    end
  end
end
