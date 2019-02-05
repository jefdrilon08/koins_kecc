module Branches
  class ComputeMemberCounts
    def initialize(config:)
      @config = config

      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today
      @cluster  = @branch.cluster
      @area     = @cluster.area

      @members          = Member.active.where(
                            "branch_id = ?",
                            @branch.id
                          )

      @resigned_members = Member.resigned.where("date_resigned > ?", @as_of)

      @members  = Member.where(id: [@members.pluck(:id) + @resigned_members.pluck(:id)])

      @pending_members  = @members.where(status: "pending")

      @data = {
        counts: {
          active_members: {
            male: 0,
            female: 0,
            others: 0,
            total: 0
          },
          pure_savers: {
            male: 0,
            female: 0,
            others: 0,
            total: 0
          },
          loaners: {
            male: 0,
            female: 0,
            others: 0,
            total: 0
          },
          active_members: {
            male: 0,
            female: 0,
            others: 0,
            total: 0
          },
          pending_members: {
            male: 0,
            female: 0,
            others: 0,
            total: 0
          }
        },
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        cluster: {
          id: @cluster.id,
          name: @cluster.name
        },
        area: {
          id: @area.id,
          name: @area.name
        },
        as_of: @as_of,
      }
    end

    def execute!
      @active_members     = @members.where(
                              id: MembershipPaymentRecord.paid.where(
                                    "date_paid <= ?",
                                    @as_of
                                  ).pluck(:member_id).uniq
                            )

      @active_loans       = ::Loans::FetchActiveAsOf.new(
                              config: {
                                as_of: @as_of,
                                branch: @branch
                              }
                            ).execute!

      #@active_loans       = Loan.active.where(branch_id: @branch.id)
      @member_loaners     = @members.where(id: @active_loans.pluck(:member_id).uniq)
      @member_pure_savers = @members.where.not(id: [@member_loaners.pluck(:id) + @active_members.pluck(:id)])

      # Pure Savers
      total_female  = @member_pure_savers.where(gender: "Female").count
      total_male    = @member_pure_savers.where(gender: "Male").count
      total_others  = @member_pure_savers.where(gender: "Others").count
      total         = total_female + total_male + total_others

      @data[:counts][:pure_savers][:female] = total_female
      @data[:counts][:pure_savers][:male]   = total_male
      @data[:counts][:pure_savers][:others] = total_others
      @data[:counts][:pure_savers][:total]  = total

      # Loaners
      total_female  = @member_loaners.where(gender: "Female").count
      total_male    = @member_loaners.where(gender: "Male").count
      total_others  = @member_loaners.where(gender: "Others").count
      total         = total_female + total_male + total_others

      @data[:counts][:loaners][:female] = total_female
      @data[:counts][:loaners][:male]   = total_male
      @data[:counts][:loaners][:others] = total_others
      @data[:counts][:loaners][:total]  = total

      # Active Members = Pure Savers + Loaners
      total_female  = @active_members.where(gender: "Female").count
      total_male    = @active_members.where(gender: "Male").count
      total_others  = @active_members.where(gender: "Others").count
      total         = total_female + total_male + total_others

      @data[:counts][:active_members][:female] = total_female
      @data[:counts][:active_members][:male]   = total_male
      @data[:counts][:active_members][:others] = total_others
      @data[:counts][:active_members][:total]  = total

      @data
    end
  end
end
