module MembershipPaymentCollections
  class RemoveMember
    def initialize(config:)
      @config                         = config
      @membership_payment_collection  = @config[:membership_payment_collection]
      @member                         = @config[:member]
      @user                           = @config[:user]

      @branch = @membership_payment_collection.branch

      @data = @membership_payment_collection.data.with_indifferent_access

      @membership_parameters  = Settings.memberships
      @default_equities_key   = Settings.default_equities_key

      @default_insurance_deposits = Settings.defaults.insurance_deposits

      @default_membership_savings_deposits  = Settings.defaults.membership_savings_deposits
    end

    def execute!
      # Update records
      new_records = []

      @data[:records].each do |o|
        if o[:member][:id] != @member.id
          new_records << o
        end
      end

      @data[:records] = new_records

      ##########################
  
      # Recompute totals
      @data[:total_collected] = 0.00
      @data[:totals]          = []

      # ID
      id_total  = 0.00
      @data[:records].each do |r|
        r[:records].each do |rr|
          if rr[:record_type] == "ID"
            id_total += rr[:amount].to_f.round(2)
          end
        end
      end

      @data[:totals] << {
        record_type: "ID",
        key: "ID",
        amount: id_total
      }

      # MEMBERSHIP
      @membership_parameters.each do |o|
        total = 0.00
        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:record_type] == "MEMBERSHIP_PAYMENT" && rr[:account_subtype] == o.name
              total += rr[:amount].to_f.round(2)
            end
          end
        end

        @data[:totals] << {
          record_type: "MEMBERSHIP_PAYMENT",
          key: o.name,
          amount: total
        }
      end

      # EQUITY
      equities_total  = 0.00
      @data[:records].each do |r|
        r[:records].each do |rr|
          if rr[:record_type] == "EQUITY" && rr[:account_subtype] == @default_equities_key
            equities_total += rr[:amount].to_f.round(2)
          end
        end
      end

      @data[:totals] << {
        record_type: "EQUITY",
        key: @default_equities_key,
        amount: equities_total
      }

      # INSURANCE
      @default_insurance_deposits.each do |o|
        total = 0.00
        
        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:record_type] == "INSURANCE" && rr[:account_subtype] == o.account_subtype
              total += rr[:amount].to_f.round(2)
            end
          end
        end

        @data[:totals] << {
          record_type: "INSURANCE",
          key: o.account_subtype,
          amount: total
        }
      end

      # SAVINGS
      @default_membership_savings_deposits.each do |o|
        total = 0.00

        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:record_type] == "SAVINGS" and rr[:account_subtype] == o.account_subtype
              total += rr[:amount].to_f.round(2)
            end
          end
        end

        @data[:totals] << {
          record_type: "SAVINGS",
          key: o.account_subtype,
          amount: total
        }
      end

      ##########################

      # Load accounting entry
      @data[:accounting_entry]  = ::MembershipPaymentCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!
      ##########################

      @membership_payment_collection.update!(
        data: @data
      )

      @membership_payment_collection
    end
  end
end
