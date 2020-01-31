module Reports
  class DownloadBooksExcel
    include ActionView::Helpers::NumberHelper

  def initialize(start_date:, end_date:, books:, branch:, accounting_fund: nil)
  @start_date      = start_date
  @end_date        = end_date
  @book            = books
  @branch          = branch
  @accounting_fund = accounting_fund
   
  @p          = Axlsx::Package.new
  
  if @book == "JVB"
    @book_display = "General Journal"
  elsif @book == "CRB"
    @book_display = "Cash Receipts"
  elsif @book == "CDB"
    @book_display = "Cash Disbursements"
  end

  @data       = {
                start_date: @start_date.to_date.strftime("%m/%d/%Y"),
                end_date:   @end_date.to_date.strftime("%m/%d/%Y"),
                book:       @book,
                book_display: @book_display
                }
  end

  def execute!
     @accounting_entries = AccountingEntry.approved.includes(:journal_entries).where(
                              "date_posted >= ? AND date_posted <= ? AND branch_id = ? AND book = ?",
                              @start_date,
                              @end_date,
                              @branch,
                              @book
                            )

    if @accounting_fund.present?
      @accounting_entries = @accounting_entries.where(accounting_fund_id: @accounting_fund).order("data ->> 'sub_reference_number' ASC")
    end

      @data[:accounting_entries]  = @accounting_entries.map{ |o|
                                      {
                                        id: o.id,
                                        book: o.book,
                                        reference_number: o.reference_number,
                                        date_posted: o.date_posted.strftime("%m/%d/%Y"),
                                        particular: o.particular,
                                        or_number: o.data.with_indifferent_access[:or_number],
                                        ar_number: o.data.with_indifferent_access[:ar_number],
                                        sub_reference_number: o.data.with_indifferent_access[:sub_reference_number],
                                        check_voucher_number: o.data.with_indifferent_access[:check_voucher_number],
                                        check_number: o.data.with_indifferent_access[:check_number],
                                        date_of_check: o.data.with_indifferent_access[:date_of_check],
                                        payee: o.data.with_indifferent_access[:payee],
                                        accounting_fund_id: o.accounting_fund_id,
                                        debit_entries:  o.journal_entries.where("post_type = ? AND amount > 0", "DR").map{ |e|
                                                          {
                                                            accounting_code: {
                                                              name: e.try(:accounting_code).try(:name),
                                                              code: e.try(:accounting_code).try(:code)
                                                            },
                                                            debit_amount: number_to_currency(e.amount, unit: ""),
                                                            credit_amount: ""
                                                          }
                                                        },
                                        credit_entries: o.journal_entries.where("post_type = ? AND amount > 0", "CR").map{ |e|
                                                          {
                                                            accounting_code: {
                                                              name: e.try(:accounting_code).try(:name),
                                                              code: e.try(:accounting_code).try(:code)
                                                            },
                                                            debit_amount: "",
                                                            credit_amount: number_to_currency(e.amount, unit: "")
                                                          }
                                                        }
                                      }
                                    }

      @data
      
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          col_widths= [40,100,40,40]
          @p.use_autowidth = false
          init_format!(wb)
          start_date  = @start_date.to_date.strftime("%b %d, %Y")
          end_date    = @end_date.to_date.strftime("%b %d, %Y")
          sheet.add_row ["#{@book_display}"], style: @header
          sheet.add_row ["#{Settings.company_name}"], style: @header
          sheet.add_row ["#{Settings.company_address}"], style: @header
          sheet.add_row ["Vat Registration Tin Number: #{Settings.company_tin_number}"], style: @header
          sheet.add_row ["#{start_date} - #{end_date}"], style: @header
          sheet.add_row []

          if Settings.activate_microinsurance
            if @book == "JVB"
              sheet.add_row ["Date","JV Number", "Account Title", "Debit", "Credit"],style: @title_bar
            elsif @book == "CRB"
              sheet.add_row ["Date","CRB Number", "OR Number", "Payor", "Account Title", "Debit", "Credit"],style: @title_bar
            elsif @book == "CDB"
              sheet.add_row ["Date","CDB Number", "Check Number",  "Voucher Number", "Payee", "Account Title", "Debit", "Credit"],style: @title_bar
            end  
          else
            sheet.add_row ["DATE","ACCOUNTING TITLE","DEBIT (PHP)","CREDIT (PHP)"],style: @title_bar
          end

          @data[:accounting_entries].each do |data|
            #raise data[:credit_entries].inspect
            sheet.column_widths *col_widths 
            
            date_printed  = false
            sub_ref = false
            check_num = false
            check_voucher_num = false
            py = false

            data[:debit_entries].each_with_index do |j, i|
              d = ""

              if !date_printed and data[:date_posted].present?
                d = data[:date_posted]
                date_printed  = true
              end

              if Settings.activate_microinsurance
                  n2 = ""
                  n3 = ""
                  n4 = ""

                  if !sub_ref and data[:sub_reference_number].present?
                    sub_reference_number = data[:sub_reference_number]
                    sub_ref  = true
                  end

                  or_number = data[:or_number].present? ? data[:or_number] : data[:ar_number]

                  if i != 0
                    or_number = ""
                  end

                  if !py and data[:payee].present?
                    payee = data[:payee]
                    py  = true
                  end

                  if !check_num and data[:check_number].present?
                    check_number = data[:check_number]
                    check_num  = true
                  end

                  if !check_voucher_num and data[:check_voucher_number].present?
                    check_voucher_number = data[:check_voucher_number]
                    check_voucher_num  = true
                  end

                  if data[:book] == "CRB"
                    sheet.add_row [d, sub_reference_number, or_number, payee, "#{j[:accounting_code][:name]}", "#{j[:debit_amount]}", ""], style: [@date_cell, @debit_cell, @debit_cell, @debit_cell, @debit_cell, @currency, @currency]
                  elsif data[:book] == "CDB"
                    sheet.add_row [d, sub_reference_number, check_number, check_voucher_number, payee, "#{j[:accounting_code][:name]}", "#{j[:debit_amount]}", ""], style: [@date_cell, @debit_cell, @debit_cell, @debit_cell, @debit_cell, @debit_cell, @currency, @currency]
                  elsif data[:book] == "JVB"
                    sheet.add_row [d, sub_reference_number, "#{j[:accounting_code][:name]}", "#{j[:debit_amount]}", ""], style: [@date_cell, @debit_cell, @debit_cell, @currency, @currency]
                  end     
                else              
                  sheet.add_row [
                          "#{data[:date_posted]}",
                          "#{j[:accounting_code][:name]}",
                          "#{j[:debit_amount]}",
                          ""
                        ], style: [@date_cell,@debit_cell,@currency_cell,@nil]
                end
            end
             
            data[:credit_entries].each do |je|
              if Settings.activate_microinsurance
                if data[:book] == "CDB"
                  sheet.add_row ["","","","","", "          #{je[:accounting_code][:name]}", "", "#{je[:credit_amount]}"], style: [@debit_cell, @debit_cell, @debit_cell, @debit_cell, @debit_cell, @debit_cell, @currency, @currency]
                elsif data[:book] == "CRB"
                  sheet.add_row ["","","","", "          #{je[:accounting_code][:name]}", "", "#{je[:credit_amount]}"], style: [@debit_cell, @debit_cell, @debit_cell, @debit_cell, @debit_cell, @currency, @currency]      
                elsif data[:book] == "JVB"
                  sheet.add_row ["","", "         #{je[:accounting_code][:name]}", "", "#{je[:credit_amount]}"], style: [@debit_cell, @debit_cell, @debit_cell, @currency, @currency]
                end
              else
                sheet.add_row [
                          "",
                          "#{je[:accounting_code][:name]}",
                          "",
                          "#{je[:credit_amount]}"
                        ], style: [@date_cell, @credit_cell,@nil,@currency_cell]
              end
            end
            
            if  Settings.activate_microinsurance
              if data[:book] == "CDB"
                sheet.add_row ["","","","","", "Particular: #{data[:particular]}", "", ""], style: @debit_cell, height: 30
              elsif data[:book] == "CRB"
                sheet.add_row ["","","","", "Particular: #{data[:particular]}", "", ""], style: @debit_cell, height: 30 
              elsif data[:book] == "JVB"
                sheet.add_row ["","", "Particular: #{data[:particular]}", "", ""], style: @debit_cell, height: 30
              end
            else
              sheet.add_row ["PARTICULAR: ","#{data[:particular]}","",""], style: [@nil,@nil,@nil,@nil]
              sheet.add_row []
              sheet.add_row []
            end              
          end
        end
      end
      @p
    end

    def init_format!(wb)
      @header         = wb.styles.add_style b: true, alignment: {horizontal: :left}
      @title_bar      = wb.styles.add_style b: true, alignment: {horizontal: :center}, border: Axlsx::STYLE_THIN_BORDER , bg_color: "ffbb33" 
      @currency_cell  = wb.styles.add_style b: true,alignment: {horizontal: :right}, border:Axlsx::STYLE_THIN_BORDER, bg_color: "a6a6a6", format_code: "#,##0.00" 
      @date_cell      = wb.styles.add_style alignment: {horizontal: :left},   border:Axlsx::STYLE_THIN_BORDER, bg_color: "a6a6a6"
      @debit_cell     = wb.styles.add_style alignment: {horizontal: :left}, border: Axlsx::STYLE_THIN_BORDER, bg_color: "a6a6a6"
      @credit_cell    = wb.styles.add_style alignment: {horizontal: :left}, border: Axlsx::STYLE_THIN_BORDER, bg_color: "a6a6a6"
      @nil            = wb.styles.add_style border: Axlsx::STYLE_THIN_BORDER , bg_color: "a6a6a6", b: true
      @currency       = wb.styles.add_style alignment: {horizontal: :right}, border:Axlsx::STYLE_THIN_BORDER, bg_color: "a6a6a6", format_code: "#,##0.00" 
    end

  end
end
