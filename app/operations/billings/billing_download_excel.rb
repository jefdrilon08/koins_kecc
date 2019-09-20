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
        sheet.add_row ["BILLING"]
        sheet.add_row ["#{Settings.company_name}"]
        sheet.add_row ["#{Settings.company_address}"]
        sheet.add_row ["TIN Number: #{Settings.company_tin_number}"]
        sheet.add_row ["#{@data[:center]} / #{@data[:branch]}"]
        sheet.add_row ["#{@data[:collection_date].to_date.strftime("%B %d,%Y")}"]
        @val = []
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
        raise @val[1].inspect
        sheet.add_row ["Attendance","#{@val[0].shift}"]






        end
      end

    @p
    end
  end
end
