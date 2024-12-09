module DataStores
    class GenerateLoanStatsExcel
        def initialize(data:)
            @rr_data   = data
            @p      = Axlsx::Package.new

            @data = {
                        loan_products: [],
                        branch: @rr_data[:branch],
                        as_of: @rr_data[:as_of],
                        total_active_loans: 0,
                        total_principal: 0.00,
                        total_principal_paid: 0.00,
                        total_principal_paid_due: 0.00,
                        total_principal_due: 0.00,
                        total_portfolio: 0.00,
                        total_past_due_amount: 0.00,
                        total_principal_past_due_amount: 0.00,
                        total_par_amount: 0.00,
                        total_par_rate: 0,
                        total_rr: 0
                    }
        
            @loan_products  = LoanProduct.all.order("priority ASC")
        
            @loan_products.each do |o|
                @data[:loan_products] << {
                                            id: o.id,
                                            name: o.name,
                                            active_loans: 0,
                                            principal: 0.00,
                                            principal_paid: 0.00,
                                            principal_paid_due: 0.00,
                                            principal_due: 0.00,
                                            portfolio: 0.00,
                                            past_due_amount: 0.00,
                                            principal_past_due_amount: 0.00,
                                            par_amount: 0.00,
                                            par_rate: 0,
                                            rr: 0
                                        }
            end

            @loan_products.each_with_index do |lp, i|
                @rr_data[:records].each do |o|
                    if lp.id == o[:loan_product][:id]
                        principal                 = o[:principal]
                        principal_paid_due        = o[:principal_paid_due] || 0.00
                        principal_due             = o[:principal_due]
                        principal_paid            = o[:principal_paid]
                        portfolio                 = o[:principal].to_f - o[:principal_paid].to_f
                        past_due_amount           = o[:total_balance]
                        principal_past_due_amount = o[:principal_balance]
                        par_amount                = o[:overall_principal_balance]
                        par_rate                  = o[:par]
                        rr                        = o[:rr]
            
                        @data[:loan_products][i][:active_loans]       = @data[:loan_products][i][:active_loans] + 1
                        @data[:loan_products][i][:principal]          += principal.to_f.round(2)
                        @data[:loan_products][i][:principal_paid]     += principal_paid.to_f.round(2)
                        @data[:loan_products][i][:principal_paid_due] += principal_paid_due.to_f.round(2)
                        @data[:loan_products][i][:principal_due]      += principal_due.to_f.round(2)
                        @data[:loan_products][i][:portfolio]          += portfolio.to_f.round(2)
                        @data[:loan_products][i][:past_due_amount]    += past_due_amount.to_f.round(2)
                        @data[:loan_products][i][:principal_past_due_amount] += principal_past_due_amount.to_f.round(2)
            
                        if(o[:par].to_f > 0)
                          @data[:loan_products][i][:par_amount] += par_amount.to_f.round(2)
                        end
            
                        @data[:total_active_loans]              = @data[:total_active_loans] + 1
                        @data[:total_principal]                 += principal.to_f.round(2)
                        @data[:total_principal_paid]            += principal_paid.to_f.round(2)
                        @data[:total_principal_paid_due]        += principal_paid_due.to_f.round(2)
                        @data[:total_principal_due]             += principal_due.to_f.round(2)
                        @data[:total_portfolio]                 += portfolio.to_f.round(2)
                        @data[:total_past_due_amount]           += past_due_amount.to_f.round(2)
                        @data[:total_principal_past_due_amount] += principal_past_due_amount.to_f.round(2)
            
                        if(o[:par].to_f > 0)
                          @data[:total_par_amount]  += par_amount.to_f.round(2)
                        end
                    end
                end 
                    # Compute RR
                puts "sdsdsd"
                puts @data[:loan_products][i][:principal_paid_due] == 0.00
                if  @data[:loan_products][i][:principal_paid_due] == 0.00
                    @data[:loan_products][i][:rr] = 0
                        else
                        @data[:loan_products][i][:rr] = (@data[:loan_products][i][:principal_paid_due] / @data[:loan_products][i][:principal_due])
                end
            
                    # Compute PAR Rate
                @data[:loan_products][i][:par_rate]  = @data[:loan_products][i][:par_amount] / @data[:loan_products][i][:portfolio]
            end
            
                  # Compute total par rate and total rr
                  #@data[:total_par_rate]  = @data[:total_principal_past_due_amount] / @data[:total_portfolio]
            @data[:total_par_rate]  = @data[:total_par_amount] / @data[:total_portfolio]
            
            if  @data[:total_principal_paid_due] == 0.00
                @data[:total_rr]  = 0
                    else
                    @data[:total_rr]  = (@data[:total_principal_paid_due] / @data[:total_principal_due])
            end
            
            @data[:loan_products] = @data[:loan_products].select{|o|o[:active_loans] > 0}

                #####

            @data2 =    {
                            officers: []
                        }

            @officers       = @rr_data[:records].map{ |o| o[:officer] }.uniq

            @officers.each do |officer|
                officer_data  = {
                                    officer: officer,
                                    active_loans: 0,
                                    principal: 0.00,
                                    principal_paid: 0.00,
                                    principal_paid_due: 0.00,
                                    principal_due: 0.00,
                                    portfolio: 0.00,
                                    past_due_amount: 0.00,
                                    principal_past_due_amount: 0.00,
                                    par_amount: 0.00,
                                    par_rate: 0,
                                    rr: 0,
                                    loan_products: []
                                }

                @loan_products.each_with_index do |lp, i|
                    loan_product  = {
                                        id: lp.id,
                                        name: lp.name,
                                        active_loans: 0,
                                        principal: 0.00,
                                        principal_paid: 0.00,
                                        principal_paid_due: 0.00,
                                        principal_due: 0.00,
                                        portfolio: 0.00,
                                        past_due_amount: 0.00,
                                        principal_past_due_amount: 0.00,
                                        par_amount: 0.00,
                                        par_rate: 0,
                                        rr: 0,
                                        loans: []
                                    }

                    loans = @rr_data[:records].select{ |o| o[:officer][:id] == officer[:id] and o[:loan_product][:id] == lp.id }

                    loan_product[:active_loans] = loans.size
                    loan_product[:loans]        = loans

                    loans.each do |o_loan|
                        principal                 = o_loan[:principal]
                        principal_paid_due        = o_loan[:principal_paid_due] || 0.00
                        principal_due             = o_loan[:principal_due]
                        principal_paid            = o_loan[:principal_paid]
                        portfolio                 = o_loan[:principal].to_f - o_loan[:principal_paid].to_f
                        past_due_amount           = o_loan[:total_balance]
                        principal_past_due_amount = o_loan[:principal_balance]
                        par_amount                = o_loan[:overall_principal_balance]
                        par_rate                  = o_loan[:par]
                        rr                        = o_loan[:rr]

                        loan_product[:principal]                  += principal.to_f.round(2)
                        loan_product[:principal_paid]             += principal_paid.to_f.round(2)
                        loan_product[:principal_paid_due]         += principal_paid_due.to_f.round(2)
                        loan_product[:principal_due]              += principal_due.to_f.round(2)
                        loan_product[:portfolio]                  += portfolio.to_f.round(2)
                        loan_product[:past_due_amount]            += past_due_amount.to_f.round(2)
                        loan_product[:principal_past_due_amount]  += principal_past_due_amount.to_f.round(2)

                        if(o_loan[:num_days_par].to_i > 0)
                        loan_product[:par_amount] += par_amount.to_f.round(2)
                        end
                    end

                    # Compute RR
                    if loan_product[:principal_paid_due] == 0.00
                        loan_product[:rr] = 0
                    else
                        loan_product[:rr] = (loan_product[:principal_paid_due] / loan_product[:principal_due])
                    end

                    # Compute PAR Rate
                    loan_product[:par_rate]  = loan_product[:par_amount] / loan_product[:portfolio]

                    if loan_product[:loans].any?
                        officer_data[:loan_products] << loan_product
                    end
                end

                # Compute totals
                officer_data[:loan_products].each do |o|
                    active_loans              = o[:active_loans]
                    principal                 = o[:principal]
                    principal_paid_due        = o[:principal_paid_due] || 0.00
                    principal_due             = o[:principal_due]
                    principal_paid            = o[:principal_paid]
                    portfolio                 = o[:principal].to_f - o[:principal_paid].to_f
                    past_due_amount           = o[:total_balance]
                    principal_past_due_amount = o[:principal_past_due_amount]
                    par_amount                = o[:par_amount]
                    par_rate                  = o[:par]
                    rr                        = o[:rr]

                    officer_data[:active_loans]               += active_loans.to_i
                    officer_data[:principal]                  += principal.to_f.round(2)
                    officer_data[:principal_paid]             += principal_paid.to_f.round(2)
                    officer_data[:principal_paid_due]         += principal_paid_due.to_f.round(2)
                    officer_data[:principal_due]              += principal_due.to_f.round(2)
                    officer_data[:portfolio]                  += portfolio.to_f.round(2)
                    officer_data[:past_due_amount]            += past_due_amount.to_f.round(2)
                    officer_data[:principal_past_due_amount]  += principal_past_due_amount.to_f.round(2)
                    officer_data[:par_amount]                 += par_amount.to_f.round(2)
                end

                # Compute RR
                if officer_data[:principal_paid_due] == 0.00
                officer_data[:rr] = 0
                else
                officer_data[:rr] = (officer_data[:principal_paid_due] / officer_data[:principal_due])
                end

                # Compute PAR Rate
                officer_data[:par_rate]  = officer_data[:par_amount] / officer_data[:portfolio]
                @data2[:officers] << officer_data
            end
        end            

        def execute!
            @p.workbook do |wb|
                wb.add_worksheet do |sheet|
                    sheet.name="OVERALL"
                    header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
                    title_cell = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Calibri"
                    label_cell = wb.styles.add_style b: true, font_name: "Calibri"
                    count_cell = wb.styles.add_style  b: true, alignment: { horizontal: :right }, format_code: "0", font_name: "Calibri"
                    currency_cell = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
                    currency_cell_right = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
                    currency_cell_right_bold = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri", b: true
                    percent_cell = wb.styles.add_style num_fmt: 9, alignment: { horizontal: :left }, font_name: "Calibri"
                    left_aligned_cell = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Calibri"
                    underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
                    header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
                    date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
                    default_cell = wb.styles.add_style font_name: "Calibri"

                    sheet.add_row   [ "Loan Stats #{@rr_data[:branch][:name]} as of #{@rr_data[:as_of]}".upcase], style: label_cell
                    sheet.add_row   [ 
                                        "Loan Product",
                                        "Active Loans",
                                        "Principal",
                                        "Principal Paid",
                                        "Portfolio",
                                        "Past Due Amount",
                                        "Par Amount",
                                        "Par Rate",
                                        "RR"
                                    ], style: label_cell

                    puts @data[:loan_products]
                    @data[:loan_products].each do |x|
                        sheet.add_row   [
                                            x[:name],
                                            x[:active_loans].round(2),
                                            x[:principal].round(2),
                                            x[:principal_paid].round(2),
                                            x[:portfolio].round(2),
                                            x[:past_due_amount].round(2),
                                            x[:par_amount].round(2),
                                            "#{(x[:par_rate]*100).round(2)}%",
                                            "#{(x[:rr]*100).round(2)}%"
                                        ]
                    end

                    sheet.add_row   [
                                        "TOTAL",  
                                        @data[:total_active_loans].round(2),
                                        @data[:total_principal].round(2),
                                        @data[:total_principal_paid].round(2),
                                        @data[:total_portfolio].round(2),
                                        @data[:total_past_due_amount].round(2),
                                        @data[:total_par_amount].round(2),
                                        "#{(@data[:total_par_rate]*100).round(2)}%",
                                        "#{(@data[:total_rr]*100).round(2)}%"
                                    ], style: label_cell   
                                    puts @data
                end

                wb.add_worksheet do |sheet|
                    sheet.name="OFFICERS"
                    header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
                    title_cell = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Calibri"
                    label_cell = wb.styles.add_style b: true, font_name: "Calibri"
                    count_cell = wb.styles.add_style  b: true, alignment: { horizontal: :right }, format_code: "0", font_name: "Calibri"
                    currency_cell = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
                    currency_cell_right = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
                    currency_cell_right_bold = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri", b: true
                    percent_cell = wb.styles.add_style num_fmt: 9, alignment: { horizontal: :left }, font_name: "Calibri"
                    left_aligned_cell = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Calibri"
                    underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
                    header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
                    date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
                    default_cell = wb.styles.add_style font_name: "Calibri"

                    sheet.add_row   [ "Loan Stats #{@rr_data[:branch][:name]} as of #{@rr_data[:as_of]}".upcase], style: label_cell
                    @data2[:officers].each do |x|
                        sheet.add_row   [ "#{x[:officer][:last_name].upcase}, #{x[:officer][:first_name].upcase}" ], style: label_cell
                        sheet.add_row   [ 
                                            "Loan Product",
                                            "Active Loans",
                                            "Principal",
                                            "Principal Paid",
                                            "Portfolio",
                                            "Past Due Amount",
                                            "Par Amount",
                                            "Par Rate",
                                            "RR"
                                        ], style: label_cell
                        x[:loan_products].each do |y|
                            sheet.add_row   [
                                                y[:name],
                                                y[:active_loans],
                                                y[:principal],
                                                y[:principal_paid],
                                                y[:portfolio],
                                                y[:past_due_amount],
                                                y[:par_amount],
                                                "#{(y[:par_rate]*100).round(2)}%",
                                                "#{(y[:rr]*100).round(2)}%",
                                            ]
                        end   
                        sheet.add_row   [
                                            "TOTAL",  
                                            x[:active_loans].round(2),
                                            x[:principal].round(2),
                                            x[:principal_paid].round(2),
                                            x[:portfolio].round(2),
                                            x[:past_due_amount].round(2),
                                            x[:par_amount].round(2),
                                            "#{(x[:par_rate]*100).round(2)}%",
                                            "#{(x[:rr]*100).round(2)}%"
                                        ], style: label_cell
                        sheet.add_row   []    
                    end
                end    
            end
            @p
        end
    end
end

