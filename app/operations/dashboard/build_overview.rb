module Dashboard
  class BuildOverview
    def initialize(branches:, as_of:)
      @branches = branches
      @as_of = as_of
    end

    def execute!
      areas = Area
        .includes(clusters: :branches)
        .where(clusters: { branches: { id: @branches.ids }})
        .order("areas.name ASC, clusters.name ASC")

      data_stores = DataStore
        .select("DISTINCT ON (meta->>'data_store_type', meta->>'branch_id') *")
        .where("meta->>'data_store_type' IN (?) AND meta->>'branch_id' IN (?) AND DATE(meta->>'as_of') <= ?", %w[REPAYMENT_RATES MEMBER_COUNTS], @branches.ids, @as_of)
        .order("meta->>'data_store_type', meta->>'branch_id', DATE(meta->>'as_of') DESC")

      {
        areas: areas.map do |area|
          clusters = area.clusters
            .map do |c|
              {
                id:       c.id,
                name:     c.name,
                branches: c.branches.map { |b| build_branch(data_stores, b) }
              }
            end
          { id: area.id, name: area.name, clusters: clusters }
        end
      }
    end

    private

    def build_branch(data_stores, branch)
      rr = data_stores.find { |ds| ds.meta["branch_id"] == branch.id && ds.meta["data_store_type"] == "REPAYMENT_RATES" }
      mc = data_stores.find { |ds| ds.meta["branch_id"] == branch.id && ds.meta["data_store_type"] == "MEMBER_COUNTS" }
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
        pure_savers:    { male: 0, female: 0, others: 0, total: 0 },
        loaners:        { male: 0, female: 0, others: 0, total: 0 },
        active_members: { male: 0, female: 0, others: 0, total: 0 }
      }

      if rr.present?
        d[:as_of] = rr.meta["as_of"]

        rr.data["records"].each do |r|
          d[:principal]                 += r["principal"].to_f.round(2)
          d[:interest]                  += r["interest"].to_f.round(2)
          d[:total]                     += r["total"].to_f.round(2)
          d[:principal_due]             += r["principal_due"].to_f.round(2)
          d[:interest_due]              += r["interest_due"].to_f.round(2)
          d[:total_due]                 += r["total_due"].to_f.round(2)
          d[:principal_paid]            += r["principal_paid"].to_f.round(2)
          d[:interest_paid]             += r["interest_paid"].to_f.round(2)
          d[:portfolio]                 += (r["principal"].to_f - r["principal_paid"].to_f).round(2)
          d[:principal_paid_due]        += r["principal_paid_due"].to_f.round(2)
          d[:interest_paid_due]         += r["interest_paid_due"].to_f.round(2)
          d[:total_paid_due]            += r["total_paid_due"].to_f.round(2)
          d[:total_paid]                += r["total_paid"].to_f.round(2)
          d[:principal_balance]         += r["principal_balance"].to_f.round(2)
          d[:interest_balance]          += r["interest_balance"].to_f.round(2)
          d[:total_balance]             += r["total_balance"].to_f.round(2)
          d[:overall_principal_balance] += r["overall_principal_balance"].to_f.round(2)
          d[:overall_interest_balance]  += r["overall_interest_balance"].to_f.round(2)

          # Par Amount. Add if num_days_par > 0
          if r["num_days_par"].to_i > 0
            d[:par_amount] += r["overall_principal_balance"].to_f.round(2)
          end
        end

        # Compute principal
        d[:principal_rr] = (d[:principal_paid_due] / d[:principal_due]).round(4)

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
        d[:par] = (d[:par_amount] / d[:portfolio]).round(4)
      end

      if mc.present?
        counts = mc.data["counts"]

        d[:member_counts_as_of] = mc.meta["as_of"]

        d[:pure_savers][:male]   = counts["pure_savers"]["male"]
        d[:pure_savers][:female] = counts["pure_savers"]["female"]
        d[:pure_savers][:others] = counts["pure_savers"]["others"]
        d[:pure_savers][:total]  = counts["pure_savers"]["total"]

        d[:loaners][:male]   = counts["loaners"]["male"]
        d[:loaners][:female] = counts["loaners"]["female"]
        d[:loaners][:others] = counts["loaners"]["others"]
        d[:loaners][:total]  = counts["loaners"]["total"]

        d[:active_members][:male]   = counts["active_members"]["male"]
        d[:active_members][:female] = counts["active_members"]["female"]
        d[:active_members][:others] = counts["active_members"]["others"]
        d[:active_members][:total]  = counts["active_members"]["total"]
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
