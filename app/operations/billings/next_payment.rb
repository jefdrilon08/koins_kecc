module Billings
  class NextPayment
    def initialize(config:)
      @config           = config
      @member           = @config[:member]
      @collection_date  = @config[:collection_date]

      @active_loans = Loan.active.where(member_id: @member.id)

      @entry_point_loan_products      = LoanProduct.entry_point
      @non_entry_point_loan_products  = LoanProduct.non_entry_point

      @data = {
        member: {
          id: @member.id,
          full_name: @member.full_name,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          identification_number: @member.identification_number
        },
        attendance: true,
        total_expected_collections: 0.00,
        payments: []
      }
    end

    def execute!
      @entry_point_loan_products.each_with_index do |loan_product, i|
        if i == 0
          @data[:payments] << build_first_entry_point_payment(loan_product)
        else
          @data[:payments] << build_non_entry_point_payment(loan_product)
        end
      end

      @non_entry_point_loan_products.each do |loan_product|
        @data[:payments] << build_non_entry_point_payment(loan_product)
      end

      @data
    end

    private

    def build_first_entry_point_payment(loan_product)
      data  = {
        loan_product: {
          id: loan_product.id,
          name: loan_product.to_s,
        },
        amount: 0.00,
        withdraw_payment: 0.00,
        deposits: [],
        enabled: false,
        loan_id: false
      }

      loan  = @active_loans.where(loan_product_id: loan_product.id).first

      if loan.present?
        data[:amount] = loan.amortization_schedule_entries.unpaid.where(
                          "due_date <= ?",
                          @collection_date
                        ).sum("principal_balance + interest_balance").round(2)
        
        data[:enabled]  = true
        data[:loan_id]  = loan.id
      end

      @data[:total_expected_collections] += data[:amount]

      data
    end

    def build_non_entry_point_payment(loan_product)
      data  = {
        loan_product: {
          id: loan_product.id,
          name: loan_product.to_s,
        },
        amount: 0.00,
        withdraw_payment: 0.00,
        enabled: false,
        loan_id: false
      }

      loan  = @active_loans.where(loan_product_id: loan_product.id).first

      if loan.present?
        data[:amount] = loan.amortization_schedule_entries.unpaid.where(
                          "due_date <= ?",
                          @collection_date
                        ).sum("principal_balance + interest_balance").round(2)

        data[:enabled]  = true
        data[:loan_id]  = loan.id
      end

      @data[:total_expected_collections] += data[:amount]

      data
    end
  end
end
