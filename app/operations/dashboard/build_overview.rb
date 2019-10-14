module Dashboard
  class BuildOverview
    def initialize(config:)
      @config = config
      @user   = @config[:user]
      @as_of  = @config[:as_of].try(:to_date) || Date.today

      @branches = Branch.where(
                    id: UserBranch.active.where(
                          user_id: @user.id
                        ).pluck(:branch_id)
                  ).order("name ASC")

      @clusters = Cluster.where(id: @branches.pluck(:cluster_id))

      @areas    = Area.where(id: @clusters.pluck(:area_id)).order("name ASC")

      @data = {
        areas: []
      }
    end

    def execute!
      branches  = build_branches!

      @areas.each do |area|
        a = {
          id: area.id,
          name: area.name,
          clusters: @clusters.where(area_id: area.id).map{ |c|
                      {
                        id: c.id,
                        name: c.name,
                        branches: branches.select{ |b| b[:cluster][:id] == c.id }
                      }
                    }
        }

        @data[:areas] << a
      end

      @data
    end

    private

    def build_branches!
      branches  = []

      @branches.each do |branch|
        data_store  = DataStore.repayment_rates.where(
                        "meta->>'branch_id' = ? AND DATE(meta->>'as_of') <= ?",
                        branch.id,
                        @as_of
                      ).order(
                        "DATE(meta->>'as_of') ASC"
                      ).last

        ds_member_counts  = DataStore.member_counts.where(
                              "meta->>'branch_id' = ? AND DATE(meta->>'as_of') <= ?",
                              branch.id,
                              @as_of
                            ).order(
                              "DATE(meta->>'as_of') ASC"
                            ).last

        d = {
          as_of: "",
          member_counts_as_of: "",
          principal: 0.00,
          interest: 0.00,
          total: 0.00,
          principal_due: 0.00,
          interest_due: 0.00,
          total_due: 0.00,
          principal_paid: 0.00,
          interest_paid: 0.00,
          principal_paid_due: 0.00,
          portfolio: 0.00,
          interest_paid_due: 0.00,
          total_paid_due: 0.00,
          total_paid: 0.00,
          principal_balance: 0.00,
          interest_balance: 0.00,
          total_balance: 0.00,
          overall_principal_balance: 0.00,
          overall_interest_balance: 0.00,
          overall_balance: 0.00,
          principal_rr: 0.00,
          interest_rr: 0.00,
          total_rr: 0.00,
          par_amount: 0.00,
          par: 0.00,
          num_days_par: 0,
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
          }
        }

        if data_store.present?
          data  = data_store.data.with_indifferent_access
          meta  = data_store.meta.with_indifferent_access

          data[:records].each do |o|
            d[:as_of] = meta[:as_of]

            d[:principal]                 += o[:principal].to_f.round(2)
            d[:interest]                  += o[:interest].to_f.round(2)
            d[:total]                     += o[:total].to_f.round(2)
            d[:principal_due]             += o[:principal_due].to_f.round(2)
            d[:interest_due]              += o[:interest_due].to_f.round(2)
            d[:total_due]                 += o[:total_due].to_f.round(2)
            d[:principal_paid]            += o[:principal_paid].to_f.round(2)
            d[:interest_paid]             += o[:interest_paid].to_f.round(2)
            d[:portfolio]                 += (o[:principal].to_f.round(2) - o[:principal_paid].to_f.round(2))
            d[:principal_paid_due]        += o[:principal_paid_due].to_f.round(2)
            d[:interest_paid_due]         += o[:interest_paid_due].to_f.round(2)
            d[:total_paid_due]            += o[:total_paid_due].to_f.round(2)
            d[:total_paid]                += o[:total_paid].to_f.round(2)
            d[:principal_balance]         += o[:principal_balance].to_f.round(2)
            d[:interest_balance]          += o[:interest_balance].to_f.round(2)
            d[:total_balance]             += o[:total_balance].to_f.round(2)
            d[:overall_principal_balance] += o[:overall_principal_balance].to_f.round(2)
            d[:overall_interest_balance]  += o[:overall_interest_balance].to_f.round(2)

            # Par Amount. Add if num_days_par > 0
            if o[:num_days_par].to_i > 0
              d[:par_amount] += o[:overall_principal_balance].to_f.round(2)
            end
          end

          # Compute principal
          d[:principal_rr]  = (d[:principal_paid_due] / d[:principal_due]).round(4)

          if d[:principal_paid_due] > 0
          else
            d[:principal_rr] = 0.00
          end

          if d[:principal_rr] > 1
            d[:principal_rr] = 1
          end

          if d[:principal_rr] >= 1 and d[:principal_paid] < d[:principal_due]
            d[:principal_rr] = 0.99
          end

          # Compute par
          d[:par] = (d[:principal_balance] / d[:principal]).round(2)
        end

        if ds_member_counts.present?
          data  = ds_member_counts.data.with_indifferent_access
          meta  = ds_member_counts.meta.with_indifferent_access

          d[:member_counts_as_of] = meta[:as_of]

          d[:pure_savers][:male]    = data[:counts][:pure_savers][:male]
          d[:pure_savers][:female]  = data[:counts][:pure_savers][:female]
          d[:pure_savers][:others]  = data[:counts][:pure_savers][:others]
          d[:pure_savers][:total]   = data[:counts][:pure_savers][:total]

          d[:loaners][:male]    = data[:counts][:loaners][:male]
          d[:loaners][:female]  = data[:counts][:loaners][:female]
          d[:loaners][:others]  = data[:counts][:loaners][:others]
          d[:loaners][:total]   = data[:counts][:loaners][:total]

          d[:active_members][:male]    = data[:counts][:active_members][:male]
          d[:active_members][:female]  = data[:counts][:active_members][:female]
          d[:active_members][:others]  = data[:counts][:active_members][:others]
          d[:active_members][:total]   = data[:counts][:active_members][:total]
        end

        branches << {
          id: branch.id,
          name: branch.name,
          cluster: {
            id: branch.cluster.id,
            name: branch.cluster.name
          },
          area: {
            id: branch.cluster.area.id,
            name: branch.cluster.area.name
          },
          data: d
        }
      end

      branches
    end
  end
end
