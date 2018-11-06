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
        totals: [],
        total_expected_collections: 0.00,
        total_collected: 0.00
      }
    end

    def execute!

      @members.each do |m|
        data  = ::Billings::NextPayment.new(
                  config: {
                    member: m,
                    collection_date: @collection_date
                  }
                ).execute!

        @data[:records] << data

        @data[:total_expected_collections]  += data[:total_expected_collections]
        @data[:total_collected]             += data[:total_expected_collections]
      end

      load_headers_and_totals!

      @billing.data = @data

      @billing.save!

      @billing
    end

    private

    def load_headers_and_totals!
      @entry_point_loan_products.each do |o|
        @data[:headers] << o.to_s

        total = 0.00
        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:record_type] == "LOAN_PAYMENT"
              if rr[:loan_product][:id] == o.id
                total += rr[:amount].to_f.round(2)
              end
            end
          end
        end

        @data[:totals] << {
          record_type: "LOAN_PAYMENT",
          key: o.to_s,
          amount: total
        }
      end

      @non_entry_point_loan_products.each do |o|
        @data[:headers] << o.to_s

        total = 0.00
        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:record_type] == "LOAN_PAYMENT"
              if rr[:loan_product][:id] == o.id
                total += rr[:amount].to_f.round(2)
              end
            end
          end
        end

        @data[:totals] << {
          record_type: "LOAN_PAYMENT",
          key: o.to_s,
          amount: total
        }
      end

      # DEPOSITS
      ::Billings::NextPayment::SAVINGS_SUBTYPES.each do |o|
        @data[:headers] << "Deposit #{o}"

        total = 0.00
        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:record_type] == "SAVINGS"
              if rr[:account_subtype] == o
                total += rr[:amount].to_f.round(2)
              end
            end
          end
        end

        @data[:totals] << {
          record_type: "SAVINGS",
          key: o,
          amount: total
        }
      end

      # INSURANCE
      ::Billings::NextPayment::INSURANCE_SUBTYPES.each do |o|
        @data[:headers] << "Insurance #{o}"

        total = 0.00
        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:record_type] == "INSURANCE"
              if rr[:account_subtype] == o
                total += rr[:amount].to_f.round(2)
              end
            end
          end
        end

        @data[:totals] << {
          record_type: "INSURANCE",
          key: o,
          amount: total
        }
      end

      # WP
      @data[:headers] << "WP"
      @data[:totals] << {
        record_type: "WP",
        key: "WP",
        amount: 0.00
      }
    end
  end
end
