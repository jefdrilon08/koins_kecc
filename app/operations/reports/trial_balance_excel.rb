module Reports
  class TrialBalanceExcel
  include ActionView::Helpers::NumberHelper

  def initialize(start_date:, end_date:, branch:, accounting_fund: nil, data:)
    @start_date      = start_date
    @end_date        = end_date
    @branch          = branch
    @accounting_fund = accounting_fund
    @data            = data

    @p               = Axlsx::Package.new
  end

  def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          col_widths= [40,100,40,40]
          @p.use_autowidth = false
          init_format!(wb)
          start_date  = @start_date.to_date.strftime("%b %d, %Y")
          end_date    = @end_date.to_date.strftime("%b %d, %Y")
          sheet.add_row ["#{Settings.company_name}"], style: @header
          sheet.add_row ["#{Settings.company_address}"], style: @header
          sheet.add_row ["Vat Registration Tin Number: #{Settings.company_tin_number}"], style: @header
          sheet.add_row ["#{start_date} - #{end_date}"], style: @header
          sheet.add_row []   
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
