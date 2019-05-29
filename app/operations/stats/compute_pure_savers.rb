module Stats
  class ComputePureSavers
    def initialize(config:)
      @config = config

      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today
      @cluster  = @branch.cluster
      @area     = @cluster.area

      @members  = Member.active.where(
                    "branch_id = ?",
                    @branch.id
                  )

      @data = {
        male: 0,
        female: 0,
        others: 0,
        total: 0,
        members: []
      }
    end

    def execute!
      @members.each do |m|
        # Check if we have paid loans
        active_loans  = ::Loans::FetchActiveAsOf.new(
                          config: {
                            member: m,
                            as_of: @as_of
                          }
                        ).execute!

        if active_loans.size == 0
          member_accounts = MemberAccount.savings.where(
                              "members.id = ?", m.id
                            )

          total_balance = 0.00

          member_accounts.each do |a|
            latest_transaction  = AccountTransaction.savings.where(
                                    "DATE(transacted_at) <= ? AND subsidiary_id = ?",
                                    @as_of,
                                    a.id
                                  ).order(
                                    "transacted_at DESC"
                                  ).first

            if latest_transaction.present?
              total_balance += latest_transaction.data["ending_balance"].to_f.round(2)
            end
          end

          if total_balance > 0
            if m.gender == "Male"
              @data[:male] += 1
            elsif m.gender == "Female"
              @data[:female] += 1
            else
              @data[:others] += 1
            end

            @data[:total] += 1

            @data[:members] << {
              id: m.id,
              identification_number: m.identification_number,
              first_name: m.first_name,
              middle_name: m.middle_name,
              last_name: m.last_name,
              member_type: m.member_type,
              branch: {
                id: m.branch.id,
                name: m.branch.name
              },
              center: {
                id: m.center.id,
                name: m.center.name
              },
              officer: {
                id: m.center.user.id,
                first_name: m.center.user.first_name,
                last_name: m.center.user.last_name
              }
            }
          end
        end
      end

      @data
    end
  end
end
