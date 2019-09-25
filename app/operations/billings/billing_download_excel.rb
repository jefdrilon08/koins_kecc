module Billings
  class BillingDownloadExcel
    def initialize(billing:)
    @p = Axlsx::Package.new
   
    @billing = Billing.find(billing)
    @data = {}

    end

    def execute!
      @collector              = Center.find(@billing.center_id).user
      @data[:collection_date] = @billing.collection_date
      @data[:branch]          = Branch.find(@billing.branch_id).to_s
      @data[:center]          = Center.find(@billing.center_id).to_s
      @data[:data]            = @billing.data.with_indifferent_access

      # WP Details
      @data[:withdraw_payments] = @billing.withdraw_payments
      @data[:reference_number]  = @billing.reference_number
      @data[:particular]        = @billing.particular
      @data[:approved_by]       = @billing.approved_by
      @data[:checked_by]        = @billing.checked_by
      @data[:prepared_by]       = @billing.prepared_by
      @data[:collected_by]      = "#{@collector.try(:first_name)} #{@collector.try(:last_name)}"

      accounting_entry  = {
        reference_number: @billing.reference_number,
        or_number: @billing.or_number,
        date_approved: @billing.date_approved,
        particular: @billing.particular
      }

      @data[:accounting_entry]  = accounting_entry

      @data
    
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
        @header_cells    = wb.styles.add_style(alignment:{horizontal: :left}, b:true)
        @grand_total_cells  = wb.styles.add_style(alignment: {horizontal: :right}, b:true, border: Axlsx::STYLE_THIN_BORDER,format_code: "#,##0.00")
        @title_cells = wb.styles.add_style(alignment: {horizontal: :center}, b: true, border: Axlsx::STYLE_THIN_BORDER)
        @row = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER, format_code: "#,##0.00")
        sheet.add_row ["BILLING"] , style: @header_cells
        sheet.add_row ["#{Settings.company_name}"], style: @header_cells
        sheet.add_row ["#{Settings.company_address}"], style: @header_cells
        sheet.add_row ["TIN Number: #{Settings.company_tin_number}"] , style: @header_cells
        sheet.add_row ["#{@data[:center]} / #{@data[:branch]}"], style: @header_cells
        sheet.add_row ["#{@data[:collection_date].to_date.strftime("%B %d,%Y")}"], style: @header_cells
        sheet.add_row []
        @val = ["MEMBER"]
        @data[:data][:totals].each do |t|
         
          if t[:record_type] == "INSURANCE"
           @val << t[:key].split(" ").map{ |o| o.first}.join("")
          elsif t[:record_type] == "LOAN_PAYMENT"
            @val <<  t[:key].split(" ").map{ |o| o.truncate(7) }.join("")
          elsif t[:record_type] == "SAVINGS" and t[:key].split(" ").size > 1
            @val << t[:key].split(" ").map{ |o| o.first}.join("")
          else
            @val  << t[:key] 
          end
          
        end
        @val << "CP" << "Total"
        @billing_grand_total = 0.00
        @billing_total_cp = 0.00
          sheet.add_row @val, style: @title_cells
          @data[:data][:records].each do |t| 
          member_total_cp = 0.00
          member_grand_total = 0.00
          amount = []
          name = "#{t[:member][:full_name]}"
             amount << name
              t[:records].each do |tt|
              if tt[:record_type] == "WP"
              amount              << tt[:amount].to_f
              @billing_grand_total  += tt[:amount].to_f
              @billing_total_cp     -= tt[:amount].to_f
              member_grand_total   += tt[:amount].to_f
              member_total_cp     -= tt[:amount].to_f
              amount << member_total_cp << member_grand_total
              else
              amount << tt[:amount].to_f 
              @billing_grand_total += tt[:amount].to_f
              @billing_total_cp    += tt[:amount].to_f
              member_grand_total  += tt[:amount].to_f
              member_total_cp     += tt[:amount].to_f 
             end
            end
            sheet.add_row amount, style: @row 
          end
          total = [""]
          @data[:data][:totals].each do |totals|
          total << totals[:amount]
          end 
          total << @billing_total_cp << @billing_grand_total
          sheet.add_row total,style: @grand_total_cells
          sheet.add_row []
          sheet.add_row []
          sheet.add_row []
          sheet.add_row ["","OFFICERS:","","Collected By: ","","Prepared By:"]
          sheet.add_row ["","__________","","__________","","__________"]
          sheet.add_row []
          sheet.add_row ["","Checked By: ","","Encoded By:","","Posted By:"]
          sheet.add_row ["","__________","","__________","","__________"]
        end
      end

    @p
    end
  end
end
