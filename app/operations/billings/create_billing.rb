module Billings
  class CreateBilling
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date]
      @branch           = Branch.where(id: @config[:branch_id]).first
      @center           = Center.where(id: @config[:center_id]).first

      @billing  = Billing.new(
                    collection_date: @collection_date,
                    branch: @branch,
                    center: @center
                  )

      @members  = Member.active.where(center_id: @center.id)

      @entry_point_loan_products      = LoanProduct.entry_point
      @non_entry_point_loan_products  = LoanProduct.non_entry_point

      @data = {
        records: [],
        headers: [],
        total_expected_collections: 0.00,
        total_collected: 0.00
      }
    end

    def execute!
      load_headers!

      @members.each do |m|
        data  = ::Billings::NextPayment.new(
                  config: {
                    member: m,
                    collection_date: @collection_date
                  }
                ).execute!

        @data[:records] << data

        @data[:total_expected_collections]  += data[:total_expected_collections]
      end

      @billing.data = @data

      @billing.save!

      @billing
    end

    private

    def load_headers!
      @entry_point_loan_products.each do |o|
        @data[:headers] << o.to_s
      end

      @non_entry_point_loan_products.each do |o|
        @data[:headers] << o.to_s
      end
    end
  end
end
