module Reports
  class GenerateRepaymentReport
    def initialize(config:)
      @config = config

      @as_of          = @config[:as_of].try(:to_date) || Date.today
      @branch         = @config[:branch]
      @loan_products  = LoanProduct.all
      @centers        = @branch.centers.order("name ASC")
      @so_officers    = User.where(id: @centers.pluck(:user_id))
      @loans          = Loan.where(
                          "(status = ? OR date_completed > ?) AND branch_id = ? AND first_date_of_payment <= ?",
                          'active',
                          @as_of,
                          @branch.id,
                          @as_of
                        )

      @par_bins = Settings.par_bins

      if @par_bins.blank?
        raise "par_bins config not found"
      end

      @data = {
        loan_products: [],
        principal:          0.00,
        interest:           0.00,
        total:              0.00,
        principal_due:      0.00,
        interest_due:       0.00,
        total_due:          0.00,
        principal_paid:     0.00,
        interest_paid:      0.00,
        total_paid:         0.00,
        principal_balance:  0.00,
        interest_balance:   0.00,
        total_balance:      0.00,
        principal_rr:       0,
        interest_rr:        0,
        total_rr:           0,
        par:                0,
        par_bins:           []
      }

      # Par bin headers
      @data[:par_bin_headers] = @par_bins.map{ |o| { min_days: o.min_days, max_days: o.max_days } }

      @data_loans = []
    end

    def execute!
      # Get loans hash array
      @loans.each do |loan|
        @data_loans <<  ::Reports::GenerateLoanRepaymentReport.new(
                          config: {
                            loan: loan,
                            as_of: @as_of
                          }
                        ).execute!
      end

      @loan_products.each do |o|
        d = {
          loan_product: {
            id: o.id,
            name: o.name,
          },
          officers: build_officers_for_loan_product(o),
          principal:          0.00,
          interest:           0.00,
          total:              0.00,
          principal_due:      0.00,
          interest_due:       0.00,
          total_due:          0.00,
          principal_paid:     0.00,
          interest_paid:      0.00,
          total_paid:         0.00,
          principal_balance:  0.00,
          interest_balance:   0.00,
          total_balance:      0.00,
          principal_rr:       0,
          interest_rr:        0,
          total_rr:           0,
          par:                0,
          par_bins:           []
        }

        if d[:officers].size > 0
          d[:officers].each do |temp|
            d[:principal] += temp[:principal]
            d[:interest]  += temp[:interest]

            d[:principal_due] += temp[:principal_due]
            d[:interest_due]  += temp[:interest_due]

            d[:principal_paid]  += temp[:principal_paid]
            d[:interest_paid]   += temp[:interest_paid]

            d[:principal_balance] += temp[:principal_balance]
            d[:interest_balance]  += temp[:interest_balance]
          end

          d[:total]         = (d[:principal] + d[:interest]).round(2)
          d[:total_due]     = (d[:principal_due] + d[:interest_due]).round(2)
          d[:total_paid]    = (d[:principal_paid] + d[:interest_paid]).round(2)
          d[:total_balance] = (d[:principal_balance] + d[:interest_balance]).round(2)

          # Repayment rate
          d[:principal_rr]  = (d[:principal_paid] / d[:principal_due]).round(2)
          d[:interest_rr]   = (d[:interest_paid] / d[:interest_due]).round(2)
          d[:total_rr]      = (d[:total_paid] / d[:total_due]).round(2) 

          # Clear repayment rates
          if d[:principal_rr] > 1
            d[:principal_rr] = 1
          end

          if d[:interest_rr] > 1
            d[:interest_rr] = 1
          end

          if d[:total_rr] > 1
            d[:total_rr] = 1
          end

          # PAR
          d[:par] = (d[:principal_balance] / d[:principal]).round(2)

          if @par_bins.present?
            @par_bins.each_with_index do |p, i|
              par_bin_data  = {
                min: p.min,
                max: p.max,
                principal_due: 0.00,
                interest_due: 0.00,
                total_due: 0.00,
                count: 0
              }

              d[:officers].each do |temp_officer|
                par_bin_data[:count] += temp_officer[:par_bins][i][:count]
                par_bin_data[:principal_due] += temp_officer[:par_bins][i][:principal_due]
                par_bin_data[:interest_due] += temp_officer[:par_bins][i][:interest_due]
                par_bin_data[:total_due] += temp_officer[:par_bins][i][:total_due]
              end

              d[:par_bins] << par_bin_data
            end
          end

          @data[:loan_products] << d
        end
      end

      if @data[:loan_products].size > 0
        @data[:loan_products].each do |temp|
          @data[:principal] += temp[:principal]
          @data[:interest]  += temp[:interest]

          @data[:principal_due] += temp[:principal_due]
          @data[:interest_due]  += temp[:interest_due]

          @data[:principal_paid]  += temp[:principal_paid]
          @data[:interest_paid]   += temp[:interest_paid]

          @data[:principal_balance] += temp[:principal_balance]
          @data[:interest_balance]  += temp[:interest_balance]
        end

        @data[:total]         = (@data[:principal] + @data[:interest]).round(2)
        @data[:total_due]     = (@data[:principal_due] + @data[:interest_due]).round(2)
        @data[:total_paid]    = (@data[:principal_paid] + @data[:interest_paid]).round(2)
        @data[:total_balance] = (@data[:principal_balance] + @data[:interest_balance]).round(2)

        # Repayment rate
        @data[:principal_rr]  = (@data[:principal_paid] / @data[:principal_due]).round(2)
        @data[:interest_rr]   = (@data[:interest_paid] / @data[:interest_due]).round(2)
        @data[:total_rr]      = (@data[:total_paid] / @data[:total_due]).round(2) 

        # Clear repayment rates
        if @data[:principal_rr] > 1
          @data[:principal_rr] = 1
        end

        if @data[:interest_rr] > 1
          @data[:interest_rr] = 1
        end

        if @data[:total_rr] > 1
          @data[:total_rr] = 1
        end

        # PAR
        @data[:par] = (@data[:principal_balance] / @data[:principal]).round(2)

        if @par_bins.present?
          @par_bins.each_with_index do |p, i|
            par_bin_data  = {
              min: p.min,
              max: p.max,
              principal_due: 0.00,
              interest_due: 0.00,
              total_due: 0.00,
              count: 0
            }

            @data[:loan_products].each do |temp_loan_product|
              par_bin_data[:count] += temp_loan_product[:par_bins][i][:count]
              par_bin_data[:principal_due] += temp_loan_product[:par_bins][i][:principal_due]
              par_bin_data[:interest_due] += temp_loan_product[:par_bins][i][:interest_due]
              par_bin_data[:total_due] += temp_loan_product[:par_bins][i][:total_due]
            end

            @data[:par_bins] << par_bin_data
          end
        end
      end

      @data
    end

    private

    def build_officers_for_loan_product(o)
      officers  = []

      @so_officers.each do |officer|
        d = {
          officer: {
            id: officer.id,
            first_name: officer.first_name,
            last_name: officer.last_name,
            identification_number: officer.identification_number
          },
          centers:            build_centers_for_officer(officer, loan_product: o),
          principal:          0.00,
          interest:           0.00,
          total:              0.00,
          principal_due:      0.00,
          interest_due:       0.00,
          total_due:          0.00,
          principal_paid:     0.00,
          interest_paid:      0.00,
          total_paid:         0.00,
          principal_balance:  0.00,
          interest_balance:   0.00,
          total_balance:      0.00,
          principal_rr:       0,
          interest_rr:        0,
          total_rr:           0,
          par:                0,
          par_bins:           []
        }

        if d[:centers].size > 0
          d[:centers].each do |temp|
            d[:principal] += temp[:principal]
            d[:interest]  += temp[:interest]

            d[:principal_due] += temp[:principal_due]
            d[:interest_due]  += temp[:interest_due]

            d[:principal_paid]  += temp[:principal_paid]
            d[:interest_paid]   += temp[:interest_paid]

            d[:principal_balance] += temp[:principal_balance]
            d[:interest_balance]  += temp[:interest_balance]
          end

          d[:total]         = (d[:principal] + d[:interest]).round(2)
          d[:total_due]     = (d[:principal_due] + d[:interest_due]).round(2)
          d[:total_paid]    = (d[:principal_paid] + d[:interest_paid]).round(2)
          d[:total_balance] = (d[:principal_balance] + d[:interest_balance]).round(2)

          # Repayment rate
          d[:principal_rr]  = (d[:principal_paid] / d[:principal_due]).round(2)
          d[:interest_rr]   = (d[:interest_paid] / d[:interest_due]).round(2)
          d[:total_rr]      = (d[:total_paid] / d[:total_due]).round(2) 

          # Clear repayment rates
          if d[:principal_rr] > 1
            d[:principal_rr] = 1
          end

          if d[:interest_rr] > 1
            d[:interest_rr] = 1
          end

          if d[:total_rr] > 1
            d[:total_rr] = 1
          end

          # PAR
          d[:par] = (d[:principal_balance] / d[:principal]).round(2)

          if @par_bins.present?
            @par_bins.each_with_index do |p, i|
              par_bin_data  = {
                min: p.min,
                max: p.max,
                principal_due: 0.00,
                interest_due: 0.00,
                total_due: 0.00,
                count: 0
              }

              d[:centers].each do |temp_center|
                par_bin_data[:count] += temp_center[:par_bins][i][:count]
                par_bin_data[:principal_due] += temp_center[:par_bins][i][:principal_due]
                par_bin_data[:interest_due] += temp_center[:par_bins][i][:interest_due]
                par_bin_data[:total_due] += temp_center[:par_bins][i][:total_due]
              end

              d[:par_bins] << par_bin_data
            end
          end

          officers << d
        end
      end

      officers
    end

    def build_centers_for_officer(o, loan_product:)
      data    = []
      centers = @centers.where(user_id: o.id).order("name ASC")

      centers.each do |c|
        d = {
          center: {
            id:                 c.id,
            name:               c.name
          },
          loans:              build_loans_for_center(c, loan_product: loan_product),
          principal:          0.00,
          interest:           0.00,
          total:              0.00,
          principal_due:      0.00,
          interest_due:       0.00,
          total_due:          0.00,
          principal_paid:     0.00,
          interest_paid:      0.00,
          total_paid:         0.00,
          principal_balance:  0.00,
          interest_balance:   0.00,
          total_balance:      0.00,
          principal_rr:       0,
          interest_rr:        0,
          total_rr:           0,
          par:                0,
          par_bins:           []
        }

        if d[:loans].size > 0
          d[:loans].each do |temp|
            d[:principal] += temp[:principal]
            d[:interest]  += temp[:interest]

            d[:principal_due] += temp[:principal_due]
            d[:interest_due]  += temp[:interest_due]

            d[:principal_paid]  += temp[:principal_paid]
            d[:interest_paid]   += temp[:interest_paid]

            d[:principal_balance] += temp[:principal_balance]
            d[:interest_balance]  += temp[:interest_balance]
          end

          d[:total]         = (d[:principal] + d[:interest]).round(2)
          d[:total_due]     = (d[:principal_due] + d[:interest_due]).round(2)
          d[:total_paid]    = (d[:principal_paid] + d[:interest_paid]).round(2)
          d[:total_balance] = (d[:principal_balance] + d[:interest_balance]).round(2)

          # Repayment rate
          d[:principal_rr]  = (d[:principal_paid] / d[:principal_due]).round(2)
          d[:interest_rr]   = (d[:interest_paid] / d[:interest_due]).round(2)
          d[:total_rr]      = (d[:total_paid] / d[:total_due]).round(2) 

          # Clear repayment rates
          if d[:principal_rr] > 1
            d[:principal_rr] = 1
          end

          if d[:interest_rr] > 1
            d[:interest_rr] = 1
          end

          if d[:total_rr] > 1
            d[:total_rr] = 1
          end

          # PAR
          d[:par] = (d[:principal_balance] / d[:principal]).round(2)

          if @par_bins.present?
            @par_bins.each_with_index do |p, i|
              par_bin_data  = {
                min: p.min,
                max: p.max,
                principal_due: 0.00,
                interest_due: 0.00,
                total_due: 0.00,
                count: 0
              }

              d[:loans].each do |temp_loan|
                if temp_loan[:num_days_par] >= p.min_days && temp_loan[:num_days_par] <= p.max_days
                  par_bin_data[:count] += 1
                  par_bin_data[:principal_due] += temp_loan[:principal_due]
                  par_bin_data[:interest_due] += temp_loan[:interest_due]
                  par_bin_data[:total_due] += temp_loan[:total_due]
                end
              end

              d[:par_bins] << par_bin_data
            end
          end

          data << d
        end
      end

      data
    end

    def build_loans_for_center(c, loan_product:)
      data  = []

      @data_loans.each do |o|
        if o[:loan_product][:id] == loan_product.id && o[:center][:id] == c.id
          data << o
        end
      end

      data
    end
  end
end
