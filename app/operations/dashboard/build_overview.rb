module Dashboard
  class BuildOverview
    def initialize(branches:, as_of:)
      @branches = branches
      @as_of = as_of
    end

    def execute!
      areas = ReadOnlyArea
        .includes(clusters: :branches)
        .where(clusters: { branches: { id: @branches.ids }})
        .order("areas.name ASC, clusters.name ASC")

      branch_metrics = ReadOnlyDailyBranchMetric
        .select("DISTINCT ON (branch_id) *")
        .where("branch_id IN (?) AND DATE(as_of) <= ? AND status = ?", @branches.ids, @as_of, "done")
        .order("branch_id, as_of DESC, updated_at DESC")

      {
        areas: areas.map do |area|
          clusters = area.clusters
            .map do |c|
              {
                id:       c.id,
                name:     c.name,
                branches: c.branches.map { |b| build_branch(branch_metrics, b) }
              }
            end
          { id: area.id, name: area.name, clusters: clusters }
        end
      }
    end

    private

    def build_branch(branch_metrics, branch)
      metric = branch_metrics.find{ |bm| bm.branch_id == branch.id }

      d = {
        as_of: metric.try(:as_of),
        member_counts_as_of: metric.try(:as_of),
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
        pure_savers:    { male: 0, female: 0, others: 0, total: 0 },
        loaners:        { male: 0, female: 0, others: 0, total: 0 },
        active_members: { male: 0, female: 0, others: 0, total: 0 },
        inactive_members:{ male: 0, female: 0, others: 0, total: 0 }
      }

      if metric.present?
        d[:as_of] = metric.as_of

        d[:principal]                 = metric.principal.to_f.round(2) 
        d[:interest]                  = metric.interest.to_f.round(2)
        d[:total]                     = metric.total.to_f.round(2)
        d[:principal_due]             = metric.principal_due.to_f.round(2)
        d[:interest_due]              = metric.interest_due.to_f.round(2) 
        d[:total_due]                 = metric.total_due.to_f.round(2) 
        d[:principal_paid]            = metric.principal_paid.to_f.round(2)
        d[:interest_paid]             = metric.interest_paid.to_f.round(2)
        d[:portfolio]                 = metric.portfolio.to_f.round(2)
        d[:principal_paid_due]        = metric.principal_paid_due.to_f.round(2) 
        d[:interest_paid_due]         = metric.interest_paid_due.to_f.round(2) 
        d[:total_paid_due]            = metric.total_paid_due.to_f.round(2) 
        d[:total_paid]                = metric.total_paid.to_f.round(2) 
        d[:principal_balance]         = metric.principal_balance.to_f.round(2) 
        d[:interest_balance]          = metric.interest_balance.to_f.round(2)
        d[:total_balance]             = metric.total_balance.to_f.round(2)
        d[:overall_principal_balance] = metric.overall_principal_balance.to_f.round(2)
        d[:overall_interest_balance]  = metric.overall_interest_balance.to_f.round(2)

        d[:par_amount]    = metric.par_amount.to_f.round(2)
        d[:principal_rr]  = metric.principal_rr.to_f
        d[:par]           = metric.par.to_f

        d[:member_counts_as_of] = metric.as_of

        d[:pure_savers][:male]   = metric.data["pure_savers"]["male"]
        d[:pure_savers][:female] = metric.data["pure_savers"]["female"]
        d[:pure_savers][:others] = metric.data["pure_savers"]["others"]
        d[:pure_savers][:total]  = metric.data["pure_savers"]["total"]

        d[:loaners][:male]   = metric.data["loaners"]["male"]
        d[:loaners][:female] = metric.data["loaners"]["female"]
        d[:loaners][:others] = metric.data["loaners"]["others"]
        d[:loaners][:total]  = metric.data["loaners"]["total"]

        d[:active_members][:male]   = metric.data["active_members"]["male"]
        d[:active_members][:female] = metric.data["active_members"]["female"]
        d[:active_members][:others] = metric.data["active_members"]["others"]
        d[:active_members][:total]  = metric.data["active_members"]["total"]

        if metric.data["inactive_members"].present?
            
            d[:inactive_members][:male]   = metric.data["inactive_members"]["male"]
            d[:inactive_members][:female] = metric.data["inactive_members"]["female"]
            d[:inactive_members][:others] = metric.data["inactive_members"]["others"]
            d[:inactive_members][:total]  = metric.data["inactive_members"]["total"]
        else
            d[:inactive_members][:male]   = 0
            d[:inactive_members][:female] = 0
            d[:inactive_members][:others] = 0
            d[:inactive_members][:total]  = 0
           
        end
        
      end

      {
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
  end
end
