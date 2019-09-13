module Reports
  class DownloadBooksExcel
    include ActionView::Helpers::NumberHelper

  def initialize(start_date: , end_date: ,books: ,branch:)
  @start_date = start_date
  @end_date   = end_date
  @book       = books
  @branch     = branch
   
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
                            ).order("reference_number ASC, date_posted ASC")

      @data[:accounting_entries]  = @accounting_entries.map{ |o|
                                      {
                                        id: o.id,
                                        reference_number: o.reference_number,
                                        date_posted: o.date_posted.strftime("%m/%d/%Y"),
                                        particular: o.particular,
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

        @data[:accounting_entries].each do |data|
          #raise data[:credit_entries].inspect
          sheet.column_widths *col_widths 
          sheet.add_row ["DATE","ACCOUNTING TITLE","DEBIT (PHP)","CREDIT (PHP)"],style: @title_bar
          
                  data[:debit_entries].each do |j|
                    sheet.add_row ["#{data[:date_posted]}","#{j[:accounting_code][:name]}","#{j[:debit_amount]}",""], style: [@date_cell,@debit_cell,@currency_cell,@nil]
                  end
                 
                 data[:credit_entries].each do |je|
                    sheet.add_row ["","#{je[:accounting_code][:name]}","","#{je[:credit_amount]}"], style: [@date_cell, @credit_cell,@nil,@currency_cell]
                  end
               
               sheet.add_row ["PARTICULAR: ","#{data[:particular]}","",""], style: [@nil,@nil,@nil,@nil]
               sheet.add_row []
               sheet.add_row []
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
    end

  end
end
