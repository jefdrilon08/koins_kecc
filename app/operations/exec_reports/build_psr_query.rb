module ExecReports
  class BuildPsrQuery
    attr_accessor :data

    def initialize(area:, cluster:, branch:, month:, year:)
      @area     = area
      @cluster  = cluster
      @branch   = branch
      @month    = month
      @year     = year

      @data = {
        area:                     @area.try(:name),
        cluster:                  @cluster.try(:name),
        branch:                   @branch.try(:name),
        count_active_female:      0,
        count_active_male:        0,
        count_active_others:      0,
        total_active:             0,
        count_pure_savers_female: 0,
        count_pure_savers_male:   0,
        count_pure_savers_others: 0,
        total_pure_savers:        0,
        count_loaners_female:     0,
        count_loaners_male:       0,
        count_loaners_others:     0,
        total_loaners:            0,
        count_resigned_female:    0,
        count_resigned_male:      0,
        count_resigned_others:    0,
        total_resigned:           0,
        total_new:                0
      }
    end

    def execute!
      # Count Active Members
      build_count_active_members!

      # Count Pure Savers
      build_count_pure_savers!

      # Count Loaners
      build_count_loaners!

      # Count New
      build_count_new_members!

      # Count Resigned
      build_count_resigned!

      # Active Loans
      @data[:active_loans] = {
        total: 0,
        categories: []
      }

      LoanProductCategory.all.order("name ASC").each do |loan_product_category|
        obj = {
          id: loan_product_category.id,
          name: loan_product_category.name,
          total: 0,
          loan_products: []
        }

        dw_branch_active_loan_counts = DwBranchLoanProductActiveLoanCount.where(
          loan_product_category_id: loan_product_category.id,
          month: @month,
          year: @year
        )

        if dw_branch_active_loan_counts.count > 0
          latest_as_of = dw_branch_active_loan_counts.order("as_of DESC").first.as_of

          dw_branch_active_loan_counts.where(as_of: latest_as_of, loan_product_category_id: loan_product_category.id)

          if @branch.present?
            obj[:total] = dw_branch_active_loan_counts.where(branch_id: @branch.id).sum(:total)
          elsif @cluster.present?
            obj[:total] = dw_branch_active_loan_counts.where(cluster_id: @cluster.id).sum(:total)
          elsif @area.present?
            obj[:total] = dw_branch_active_loan_counts.where(area_id: @area.id).sum(:total)
          end

          loan_product_category.loan_products.order("name ASC").each do |loan_product|
            lp_obj = {
              id: loan_product.id,
              name: loan_product.name,
              total: 0
            }

            dw_branch_active_loan_counts = DwBranchLoanProductActiveLoanCount.where(as_of: latest_as_of, loan_product_id: loan_product.id)

            if @branch.present?
              lp_obj[:total] = dw_branch_active_loan_counts.where(branch_id: @branch.id).sum(:total)
            elsif @cluster.present?
              lp_obj[:total] = dw_branch_active_loan_counts.where(cluster_id: @cluster.id).sum(:total)
            elsif @area.present?
              lp_obj[:total] = dw_branch_active_loan_counts.where(area_id: @area.id).sum(:total)
            end

            obj[:loan_products] << lp_obj
          end
        end

        @data[:active_loans][:categories] << obj
      end

      @data
    end

    private

    def build_count_new_members!
      dw_branch_new_member_counts = DwBranchNewMemberCount.where(
        month: @month,
        year: @year
      ).order("updated_at DESC")

      if dw_branch_new_member_counts.count > 0
        if @branch.present?
          dw_branch_new_member_count = dw_branch_new_member_counts.where(
            branch_id: @branch.id
          ).first

          if dw_branch_new_member_count.present?
            @data[:total_new] = dw_branch_new_member_count.total
          end
        elsif @cluster.present?
          dw_branch_new_member_counts = dw_branch_new_member_counts.where(
            cluster_id: @cluster.id
          )

          @data[:total_new] = dw_branch_new_member_counts.sum(:total)
        elsif @area.present?
          dw_branch_new_member_counts = dw_branch_new_member_counts.where(
            area_id: @area.id
          )

          @data[:total_new] = dw_branch_new_member_counts.sum(:total)
        end
      end
    end

    def build_count_resigned!
      dw_branch_member_counts = DwBranchMemberCount.where(
        month: @month,
        year: @year,
        record_type: "resigned"
      )

      if dw_branch_member_counts.count > 0
        latest_as_of = dw_branch_member_counts.order("as_of DESC").first.as_of

        if @branch.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            branch_id: @branch.id,
            as_of: latest_as_of
          )
        elsif @cluster.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            cluster_id: @cluster.id,
            as_of: latest_as_of
          )
        elsif @area.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            area_id: @area.id,
            as_of: latest_as_of
          )
        end

        @data[:count_resigned_female] = dw_branch_member_counts.sum(:count_female)
        @data[:count_resigned_male]   = dw_branch_member_counts.sum(:count_male)
        @data[:count_resigned_others] = dw_branch_member_counts.sum(:count_others)
        @data[:total_resigned]        = dw_branch_member_counts.sum(:total)
      end
    end

    def build_count_loaners!
      dw_branch_member_counts = DwBranchMemberCount.where(
        month: @month,
        year: @year,
        record_type: "loaners"
      )

      if dw_branch_member_counts.count > 0
        latest_as_of = dw_branch_member_counts.order("as_of DESC").first.as_of

        if @branch.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            branch_id: @branch.id,
            as_of: latest_as_of
          )
        elsif @cluster.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            cluster_id: @cluster.id,
            as_of: latest_as_of
          )
        elsif @area.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            area_id: @area.id,
            as_of: latest_as_of
          )
        end

        @data[:count_loaners_female] = dw_branch_member_counts.sum(:count_female)
        @data[:count_loaners_male]   = dw_branch_member_counts.sum(:count_male)
        @data[:count_loaners_others] = dw_branch_member_counts.sum(:count_others)
        @data[:total_loaners]        = dw_branch_member_counts.sum(:total)
      end
    end

    def build_count_pure_savers!
      dw_branch_member_counts = DwBranchMemberCount.where(
        month: @month,
        year: @year,
        record_type: "pure_savers"
      )

      if dw_branch_member_counts.count > 0
        latest_as_of = dw_branch_member_counts.order("as_of DESC").first.as_of

        if @branch.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            branch_id: @branch.id,
            as_of: latest_as_of
          )
        elsif @cluster.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            cluster_id: @cluster.id,
            as_of: latest_as_of
          )
        elsif @area.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            area_id: @area.id,
            as_of: latest_as_of
          )
        end

        @data[:count_pure_savers_female] = dw_branch_member_counts.sum(:count_female)
        @data[:count_pure_savers_male]   = dw_branch_member_counts.sum(:count_male)
        @data[:count_pure_savers_others] = dw_branch_member_counts.sum(:count_others)
        @data[:total_pure_savers]        = dw_branch_member_counts.sum(:total)
      end
    end

    def build_count_active_members!
      dw_branch_member_counts = DwBranchMemberCount.where(
        month: @month,
        year: @year,
        record_type: "active_members"
      )

      if dw_branch_member_counts.count > 0
        latest_as_of = dw_branch_member_counts.order("as_of DESC").first.as_of

        if @branch.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            branch_id: @branch.id,
            as_of: latest_as_of
          )
        elsif @cluster.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            cluster_id: @cluster.id,
            as_of: latest_as_of
          )
        elsif @area.present?
          dw_branch_member_counts = dw_branch_member_counts.where(
            area_id: @area.id,
            as_of: latest_as_of
          )
        end

        @data[:count_active_female] = dw_branch_member_counts.sum(:count_female)
        @data[:count_active_male]   = dw_branch_member_counts.sum(:count_male)
        @data[:count_active_others] = dw_branch_member_counts.sum(:count_others)
        @data[:total_active]        = dw_branch_member_counts.sum(:total)
      end
    end
  end
end
