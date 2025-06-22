module Billings
  class CreateBilling
    def initialize(config:, billing: nil)
      @config = config
      @user   = @config[:user]

      if billing.present?
        @billing          = billing
        @collection_date  = @billing.collection_date
        @branch           = @billing.branch
        @center           = @billing.center
      else
        @collection_date  = @config[:collection_date]
        @branch           = ReadOnlyBranch.where(id: @config[:branch_id]).first
        @center           = ReadOnlyCenter.where(id: @config[:center_id]).first

        @billing  = Billing.new(
                      collection_date: @collection_date,
                      branch: @branch,
                      center: @center
                    )
      end
      #if @billing.data['billing_type'].present?
      #  if @billing.data['billing_type'] == "regular"
          @members  = ReadOnlyMember.active.where(center_id: @center.id)
          #@members  = ReadOnlyMember.active_and_involutary.where(center_id: @center.id)
          
      #  elsif @billing.data['billing_type'] == "for-involutary"
      #    @members  = ReadOnlyMember.resigned.where("center_id = ? AND (data -> 'resignation' ->> 'type') = ?", @center.id, "involuntary")
        
      #  end

      #end



      valid_loan_product_ids  = ReadOnlyLoan.active.where(member_id: @members.pluck(:id)).pluck(:loan_product_id).uniq

      @entry_point_loan_products      = ReadOnlyLoanProduct.entry_point.where(id: valid_loan_product_ids)
      @non_entry_point_loan_products  = ReadOnlyLoanProduct.non_entry_point.where(id: valid_loan_product_ids)


      # Default: Checked By --> FM
      # Default: Posted By  --> BK
      # TODO: Fix this
#      branch_users  = UserBranch.where(user_id:, @user.id, branch_id: @branch.id)

#      fm_user = nil
#      bk_user = nil
#
#      branch_users.each do |o|
#        if o.user.roles.include?("FM")
#          fm_user = o.user
#        end
#
#        if o.user.roles.include?("BK") || o.user.roles.include?("SBK")
#          bk_user = o.user
#        end
#      end

      @data = {
        special_report:nil,
        print_count:0,
        or_number: "",
        ar_number: "",
        records: [],
        headers: [],
        totals: [],
        total_expected_collections: 0.00,
        total_collected: 0.00,
        grand_total_loan_paymet: 0.00,
        prepared_by: "#{@user.try(:first_name)} #{@user.try(:last_name)}",
#        checked_by: "#{fm_user.try(:first_name)} #{fm_user.try(:last_name)}",
#        approved_by: "#{bk_user.try(:first_name)} #{bk_user.try(:last_name)}"
        checked_by: "N/A",
        approved_by: "N/A"
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
        @data[:grand_total_loan_paymet]     = 0.0

      end
      load_headers_and_totals!
    
      # Load accounting entry
      @data[:accounting_entry]  = ::Billings::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user,
                                      center: @center
                                    }
                                  ).execute!

      @billing.data = @data
    

      @billing.save!

      @billing
     # raise @billing.inspect
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
        @data[:grand_total_loan_paymet] += total
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
        @data[:grand_total_loan_paymet] += total
        @data[:total_loan_payment]
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
      
      # DEPOSITS
      ::Billings::NextPayment::EQUITY_SUBTYPES.each do |o|
        @data[:headers] << "Deposit #{o}"

        total = 0.00
        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:record_type] == "EQUITY"
              if rr[:account_subtype] == o
                total += rr[:amount].to_f.round(2)
              end
            end
          end
        end

        @data[:totals] << {
          record_type: "EQUITY",
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
