module Reports
  class DownloadForWriteoffExcel
    def initialize(record:)
       @p = Axlsx::Package.new

       @records = DataStore.find(record)
        Rails.logger.debug "batman: #{@records.inspect}"
       @data = {}
    end
    def execute!
      records = @records.data.with_indifferent_access
      
      @data[:branch] = records[:branch]['name']
      @data[:year]   = records[:year]
      
        @p.workbook do |wb|
            wb.add_worksheet do |sheet|
            @header_cells    = wb.styles.add_style(alignment:{horizontal: :left}, b:true)
            @title_cells = wb.styles.add_style(alignment: {horizontal: :center}, b: true, border: Axlsx::STYLE_THIN_BORDER)
            @row = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER, format_code: "#,##0.00")
            @data_row = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER)
            sheet.add_row ["FOR WRITEOFF"] , style: @header_cells
            sheet.add_row ["#{Settings.company_name}"], style: @header_cells
            sheet.add_row ["#{Settings.company_address}"], style: @header_cells
            sheet.add_row ["TIN Number: #{Settings.company_tin_number}"] , style: @header_cells
            sheet.add_row ["#{@data[:branch]} - #{@data[:year]}"], style: @header_cells
            sheet.add_row []
            sheet.add_row ["","UUID","MEMBERS","IDENTIFICATION_NUMBER","CENTER","MEMBER_STATUS","LOAN_PRODUCT","MATURITY_DATE","LOAN_STATUS","PRINCIPAL_BALANCE","INTEREST_BALANCE","PSA_BALANCE","RSA_BALANCE","MBS_BALANCE","GK_BALANCE","RF_BALANCE","EQUITY_BALANCE","SHARE_CAPITAL_BALANCE","CBU_BALANCE"], style: @title_cells
            records[:records].each_with_index do |value, index|
              id            = value[:id]
              member_name   = value[:last_name] + " " + value[:first_name] +", "+value[:middle_name]
              member_id     = value[:member_id]
              member_center = value[:center]["name"]
              member_status = value[:member_status]
              member_loan   = value[:loan_product]
              maturity_date = value[:maturity_date]
              loan_status   = value[:loan_status]
              principal_balance = value[:principal_balance].to_f.round(2)
              interest_balance  = value[:interest_balance].to_f.round(2)
              personal_savings  = value[:psa_balance].to_f.round(2)
              rsa_balance       = value[:rsa_balance].to_f.round(2)
              mbs_balance       = value[:mbs_balance].to_f.round(2)
              gk_balance        = value[:gk_balance].to_f.round(2)
              rf_balace         = value[:rf_balance].to_f.round(2)
              eq_balance        = value[:eq_balance].to_f.round(2)
              share_cap         = value[:sharecap_balance].to_f.round(2)
              cbu_balance       = value[:cbu_balance].to_f.round(2)
              sheet.add_row ["#{index + 1}","#{id}","#{member_name}","#{member_id}","#{member_center}","#{member_status}","#{member_loan}","#{maturity_date}","#{loan_status}","#{principal_balance}","#{interest_balance}","#{personal_savings}","#{rsa_balance}","#{mbs_balance}","#{gk_balance}","#{rf_balace}","#{eq_balance}","#{share_cap}","#{cbu_balance}"], style: @data_row
            end
          end
        end
        @p
    end
  end
end
