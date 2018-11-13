module MembershipPayments
  class CreateMembershipPaymentCollection
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date]
      @user             = @config[:user]
      @branch           = Branch.where(id: @config[:branch_id]).first
      @center           = Center.where(id: @config[:center_id]).first

      @membership_parameters  = Settings.memberships

      @membership_payment_collection  = MembershipPaymentCollection.new(
                                          branch: @branch,
                                          center: @center
                                        )

      @members  = Member.active.where(center_id: @center.id)

      @data = {
        or_number: "",
        ar_number: "",
        records: "",
        headers: [],
        totals: [],
        total_collected: 0.00
      }
    end

    def execute!
      # ID

      # MEMBERSHIP

      # EQUITY
    end

    private

    def load_headers_and_totals!
      # ID
      @data[:headers] << "ID"

      id_total = 0.00
      @data[:records].each do |r|
        r[:records].each do |rr|
          if rr[:record_type] == "ID_PAYMENT"
            id_total += rr[:amount].to_f.round(2)
          end
        end
      end

      @data[:totals] << {
        record_type: "ID_PAYMENT",
        key: "ID",
        amount: id_total
      }

      # MEMBERSHIP
      @membership_parameters.each do
      end

      # EQUITY
    end
  end
end
