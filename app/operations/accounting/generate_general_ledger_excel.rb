module Accounting
  class GenerateGeneralLedgerExcel
    def initialize(config:)
      @p = Axlsx::Package.new
      @gl = []
      @config              = config
      @start_date          = @config[:start_date]
      @end_date            = @config[:end_date]
      @branch              = @config[:branch]
      @accounting_code_ids = @config[:accounting_code_ids] || []
      #raise @branch.id.inspect
      
      #raise @branch.inspect 


      @data = {
            :start_date =>  @start_date.strftime("%B %d, %Y"),
            :end_date   =>  @end_date.strftime("%B %d, %Y"),
              branch: {
                    :id => @branch,
                    :name => @branch,
                },
                entries: []
              }             

    end

    def execute!
      journal_entries_by_accounting_code  = JournalEntry
                                              .eager_load(:accounting_code, :accounting_entry)
                                              .where(
                                                "accounting_entries.date_posted >= ? AND accounting_entries.date_posted <= ? AND accounting_entries.branch_id = ?",
                                                @start_date,
                                                @end_date,
                                                @branch.id
                                              )
                                              .order("accounting_codes.code ASC, accounting_entries.date_posted ASC, accounting_entries.updated_at ASC")
                                              .group_by(&:accounting_code_id)

      dr_accounting_codes = AccountingCode.joins(
                              journal_entries: :accounting_entry
                            )
                            .where(
                              "journal_entries.post_type = ? AND accounting_entries.date_posted < ? AND accounting_entries.branch_id = ?",
                              "DR",
                              @start_date,
                              @branch.id
                            )
                            .select("accounting_codes.id as accounting_code_id, accounting_codes.name as accounting_code_name, sum(journal_entries.amount) as sum")
                            .group("accounting_codes.id")

      cr_accounting_codes = AccountingCode.joins(
                              journal_entries: :accounting_entry
                            )
                            .where(
                              "journal_entries.post_type = ? AND accounting_entries.date_posted < ? AND accounting_entries.branch_id = ?",
                              "CR",
                              @start_date,
                              @branch.id
                            )
                            .select("accounting_codes.id as accounting_code_id, accounting_codes.name as accounting_code_name, sum(journal_entries.amount) as sum")
                            .group("accounting_codes.id")

      entries = []

      # Fetch accounting codes
      #accounting_codes  = dr_accounting_codes.map{ |o| o.accounting_code_id } | cr_accounting_codes.map{ |o| o.accounting_code_id }
      accounting_codes  = AccountingCode.all.order("code ASC").pluck(:id)

      if @accounting_code_ids.size > 0
        accounting_codes  = AccountingCode.where(id: @accounting_code_ids).order("code ASC").pluck(:id)
      end

      mapped_cr_accounting_codes  = cr_accounting_codes.map{ |o| { id: o.accounting_code_id, name: o.accounting_code_name, sum: o.sum } }
      mapped_dr_accounting_codes  = dr_accounting_codes.map{ |o| { id: o.accounting_code_id, name: o.accounting_code_name, sum: o.sum } }

      accounting_codes  = AccountingCode.where(id: accounting_codes).order("code ASC")

      accounting_codes.each do |accounting_code|
        a = accounting_code.id

        debit_hash  = mapped_dr_accounting_codes.find{ |o| o[:id] == a }
        credit_hash = mapped_cr_accounting_codes.find{ |o| o[:id] == a }

        accounting_code_name  = ""

        if debit_hash.present?
          accounting_code_name  = debit_hash[:name]
        end

        if credit_hash.present?
          accounting_code_name  = credit_hash[:name]
        end

        if accounting_code_name.blank?
          accounting_code_name  = accounting_code.name
        end

        dr_sum  = debit_hash.present? ? debit_hash[:sum].to_f : 0.00 
        cr_sum  = credit_hash.present? ? credit_hash[:sum].to_f : 0.00

        beginning_balance = 0.00

        if accounting_code.debit_entry?
          beginning_balance = dr_sum - cr_sum
        else
          beginning_balance = cr_sum - dr_sum
        end

        running_balance = beginning_balance
        if journal_entries_by_accounting_code[a].present?

          mapped_entries  = journal_entries_by_accounting_code[a].map{ |x|
                              dr_amount       = x.post_type == "DR" ? x.amount.to_f : 0.00
                              cr_amount       = x.post_type == "CR" ? x.amount.to_f : 0.00
                              net_amount      = 0.00

                              if accounting_code.debit_entry?
                                running_balance = running_balance + dr_amount - cr_amount
                                net_amount      = dr_amount - cr_amount
                              else
                                running_balance = running_balance + cr_amount - dr_amount
                                net_amount      = cr_amount - dr_amount
                              end

                              {
                                id: x.id,
                                accounting_code_id: x.accounting_code.id,
                                date_posted: x.accounting_entry.date_posted.strftime("%b %d, %Y"),
                                accounting_entry_id: x.accounting_entry.id,
                                reference_number: x.accounting_entry.reference_number,
                                sub_reference_number: x.accounting_entry.sub_reference_number,
                                book: x.accounting_entry.book,
                                particular: x.accounting_entry.particular,
                                dr_amount: dr_amount,
                                cr_amount: cr_amount,
                                net_amount: net_amount,
                                running_balance: running_balance.to_f
                              }
                            }
          else 
            mapped_entries = []
          end
       
          if beginning_balance.to_f.round(2) != 0 || running_balance.to_f.round(2) != 0|| mapped_entries.size > 0
          entries << {
            accounting_code_id: a,
            accounting_code_name: accounting_code_name,
            dr_sum: dr_sum.to_f,
            cr_sum: cr_sum.to_f,
            beginning_balance: beginning_balance.to_f,
            ending_balance: running_balance.to_f,
            entries: mapped_entries
          }
         
        end
      end

      @data[:entries]  = entries
      
      @data

      @data[:branch].each do |key , value|
        @branch_name =  "#{value}"
      end
      
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
           @header_cells    = wb.styles.add_style(alignment:{horizontal: :left}, b:true)
           @currency_cells_account_title  = wb.styles.add_style(bg_color: "ff9933",b: true, alignment:{horizontal: :right}, format_code: "#,##0.00", border: Axlsx::STYLE_THIN_BORDER)
           @currency_cells      = wb.styles.add_style(alignment:{horizontal: :right}, format_code: "#,##0.00", border: Axlsx::STYLE_THIN_BORDER)
           @nil                 = wb.styles.add_style(bg_color: "ff9933",border: Axlsx::STYLE_THIN_BORDER)
           @title_cells         = wb.styles.add_style(bg_color:"99ceff", alignment:{horizontal: :left}, b:true,border: Axlsx::STYLE_THIN_BORDER)
           @account_title       = wb.styles.add_style(bg_color:"ff9933", alignment:{horizontal: :left}, b:true,border: Axlsx::STYLE_THIN_BORDER)
           @def_cell            = wb.styles.add_style(alignment: {horizontal: :left}, border: Axlsx::STYLE_THIN_BORDER)
           @def_currency_cells  = wb.styles.add_style(alignment: {horizontal: :right},format_code: "#,##0.00",border: Axlsx::STYLE_THIN_BORDER)
           @ending_cell         = wb.styles.add_style(bg_color: "66ff66",alignment:{horizontal: :left},b:true, border: Axlsx::STYLE_THIN_BORDER)
           @nil_ending_balance  = wb.styles.add_style(bg_color: "66ff66", border: Axlsx::STYLE_THIN_BORDER)
           @currency_ending     = wb.styles.add_style(bg_color: "66ff66", alignment:{horizontal: :right}, format_code: "#,##0.00",b: true, border: Axlsx::STYLE_THIN_BORDER)
            center = wb.styles.add_style(alignment: {horizontal: :center})
            sheet.add_row ["GENERAL LEDGER"],style: @header_cells
            sheet.add_row ["#{Settings.company_name}"],style: @header_cells
            sheet.add_row ["#{Settings.company_address}"],style: @header_cells
            sheet.add_row ["TIN Number: #{Settings.company_tin_number}"],style: @header_cells
            sheet.add_row ["#{@data[:start_date]} - #{@data[:end_date]}"],style: @header_cells
            sheet.add_row ["#{@branch_name}"],style: @header_cells
            sheet.add_row [""]

            sheet.add_row ["DATE","REFERENCE NUMBER","SUB REFERENCE NUMBER","BOOK","PARTICULAR","DEBIT","CREDIT",""], :style=> @title_cells
 
              @data[:entries].each do |key , value|
                                sheet.add_row ["#{key[:accounting_code_name]}","","","","","","","#{key[:beginning_balance]}"], style: [@account_title,@nil,@nil,@nil,@nil,@nil,@nil,@currency_cells_account_title]
          
                key[:entries].each do |a , b|
                  sheet.add_row ["#{a[:date_posted]}","#{a[:reference_number].rjust(10,'0')}","#{a[:sub_reference_number]}","#{a[:book]}","#{a[:particular]}","#{a[:dr_amount]}","#{a[:cr_amount]}","#{a[:running_balance]}"],
                  style: [
                  @def_cell,
                  @def_cell,
                  @def_cell,
                  @def_cell,
                  @def_cell,
                  @def_currency_cells,
                  @def_currency_cells,
                  @def_currency_cells
                  ]               
                end
                sheet.add_row ["#{key[:accounting_code_name]} - ENDING BALANCE","","","","","","","#{key[:ending_balance]}"], style: [@ending_cell,@nil_ending_balance,@nil_ending_balance,@nil_ending_balance,@nil_ending_balance,@nil_ending_balance,@nil_ending_balance,@currency_ending]

              end
        end
      end
      @p  
    end
    
  end
end
