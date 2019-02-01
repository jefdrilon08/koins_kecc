module MembershipPaymentCollections
  class CreateMembershipPaymentCollection
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today
      @user             = @config[:user]
      @branch           = Branch.where(id: @config[:branch_id]).first
      @center           = Center.where(id: @config[:center_id]).first

      @membership_parameters  = Settings.memberships

      @membership_payment_collection  = MembershipPaymentCollection.new(
                                          collection_date: @collection_date,
                                          branch: @branch,
                                          center: @center
                                        )

      @members  = Member.pending.where(center_id: @center.id)

      @default_equities_key = Settings.default_equities_key

      @data = {
        or_number: "",
        ar_number: "",
        records: [],
        headers: [],
        totals: [],
        total_collected: 0.00
      }
    end

    def execute!
      @members.each do |m|
        member_data = {
          member: {
            id: m.id,
            full_name: m.full_name,
            first_name: m.first_name,
            middle_name: m.middle_name,
            last_name: m.last_name,
            identification_number: m.identification_number
          },
          total_collected: 0.00,
          records: []
        }

        # ID
        member_data[:records] << {
          record_type: "ID",
          amount: 0.00,
          member_id: m.id,
          enabled: true
        }

        # MEMBERSHIP
        @membership_parameters.each do |o|
          if !has_membership_payment_record?(m, o.name, o.type)
            fee = o.payment_default == true ? o.fee : 0.00

            member_data[:records] << {
              record_type: "MEMBERSHIP_PAYMENT",
              account_subtype: o.name,
              membership_type: o.type,
              enabled: true,
              amount: fee,
              member_id: m.id
            }

            member_data[:total_collected] += fee

            @data[:total_collected] += fee
          else
            member_data[:records] << {
              record_type: "MEMBERSHIP_PAYMENT",
              account_subtype: o.name,
              membership_type: o.type,
              enabled: false,
              amount: 0.00,
              member_id: m.id
            }
          end
        end

        # EQUITY
        # TODO: Equity rules should be applied
        member_account = MemberAccount.equities.where(member_id: m.id, account_subtype: @default_equities_key).first
        amount  = 0.00

        if m.pending? and member_account.present?
          amount  = Settings.default_equities_amount.try(:to_f) || 0.00
        end

        member_data[:total_collected] += amount

        member_data[:records] << {
          record_type: "EQUITY",
          account_subtype: @default_equities_key,
          enabled: member_account.present?,
          member_account_id: member_account.try(:id),
          amount: amount
        }

        @data[:total_collected] += amount
        @data[:records] << member_data
      end

      load_headers_and_totals!

      # Load accounting entry
      @data[:accounting_entry]  = ::MembershipPaymentCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @membership_payment_collection.data = @data
      @membership_payment_collection.save!

      @membership_payment_collection
    end

    private

    def has_membership_payment_record?(member, membership_name, membership_type)
      MembershipPaymentRecord.paid.where(
        member_id: member.id,
        membership_name: membership_name
      ).count > 0
    end

    def load_headers_and_totals!
      # ID
      @data[:headers] << "ID"

      id_total = 0.00
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
        @data[:headers] << o.name

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
      @data[:headers] << @default_equities_key

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
    end
  end
end
