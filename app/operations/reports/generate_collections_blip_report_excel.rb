module Reports
  class GenerateCollectionsBlipReportExcel
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch
      @valid_members = []

      if @branch.present? && @start_date.present? && @end_date.present?
        #@members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ? AND branch_id = ?", @start_date, @end_date, @branch).order("identification_number ASC")
        @members  = Member.where("data->>'recognition_date' <= ? AND branch_id = ?", @end_date, @branch).order("identification_number ASC")
      elsif @start_date.present? && @end_date.present?
        @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ?", @start_date, @end_date).order("identification_number ASC")
      elsif @branch.present?
        @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ? AND branch_id = ?", Date.today, Date.today, @branch).order("identification_number ASC")
      else
         @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ?", Date.today, Date.today).order("identification_number ASC") 
      end
      
      @p        = Axlsx::Package.new
    end

    # def query!
    #   @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
    #     SELECT
    #       members.id AS member_uuid,
    #       members.identification_number,
    #       members.first_name,
    #       members.middle_name,
    #       members.last_name,
    #       members.status,
    #       members.insurance_status,
    #       members.data->'recognition_date' AS recognition_date,
    #       tt.member_account_subtype AS account_subtype,
    #       tt.member_account_id AS member_account_id,
    #       COALESCE(SUM(tt.amount::float), 0.00) AS sum_amount
    #     FROM members 
    #     LEFT JOIN
    #       (
    #       SELECT
    #         member_accounts.member_id,
    #         member_accounts.id AS member_account_id,
    #         member_accounts.account_subtype AS member_account_subtype,
    #         account_transactions.id AS account_transaction_id,
    #         account_transactions.transacted_at AS latest_transaction_date,
    #         account_transactions.data->>'ending_balance' AS ending_balance,
    #         account_transactions.amount AS amount
    #     FROM 
    #         member_accounts
    #     INNER JOIN
    #         account_transactions ON member_accounts.id = account_transactions.subsidiary_id 
    #         AND member_accounts.account_type = 'INSURANCE'
    #         AND member_accounts.account_subtype IN ('Life Insurance Fund', 'Retirement Fund') 
    #         AND account_transactions.data->>'is_interest' = 'false'
    #         AND account_transactions.transaction_type = 'deposit'
    #         AND account_transactions.transacted_at BETWEEN '#{@start_date}' AND '#{@end_date}'
    #     ORDER BY
    #         member_accounts.id, account_transactions.transacted_at DESC
    #       ) tt ON tt.member_id = members.id
    #     WHERE 
    #       members.insurance_status IN ('inforce', 'lapsed', 'dormant', 'resigned', 'inactive')
    #       AND members.branch_id::text = '#{@branch}'
    #       AND members.data->>'recognition_date' <= '#{@end_date}'
    #     GROUP BY
    #       members.id,
    #       tt.member_account_id,
    #       tt.member_account_subtype
    #   EOS
    # end

    def execute!
      # query!

      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
          title_cell = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Calibri"
          label_cell = wb.styles.add_style b: true, font_name: "Calibri"
          currency_cell = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right_bold = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri", b: true
          percent_cell = wb.styles.add_style num_fmt: 9, alignment: { horizontal: :left }, font_name: "Calibri"
          left_aligned_cell = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Calibri"
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row [ 
            "Number",
            "Name of Member",
            "Policy Number (ID Number)",
            "Certificate Number / ID Number",
            "Sum Assure / Face Amount",
            "Premium (LIFE)",
            "Premium (RF)",
            "Premium Tax",
            "Amount Collected (LIFE)",
            "Amount Collected (RF)",
            "Official Receipt (voucher check number)",
            "OR Date (date of release)",
            "Recognition Date"
          ], style: header


          # @result.each do |o|
          #   member_uuid = o.fetch("member_uuid")
          #   member = Member.find(member_uuid)
          #   recognition_date = member.recognition_date
          #   current_date = @end_date

          #   if !recognition_date.nil?  
          #     seconds_between = (current_date.to_time - recognition_date.to_time).abs
          #     days_between = seconds_between / 60 / 60 / 24
          #     number_of_months = (days_between / 30.44).floor
          #     years = (days_between / 365.242199).floor
          #     months = number_of_months - (years * 12)
          #     if months < 3 && years < 1
          #       value = 2000
          #     elsif months >= 3 && years < 1 
          #       value = 6000
          #     elsif years >= 1 && years < 2
          #       value = 10000
          #     elsif years >= 2 && years < 3
          #       value = 30000
          #     elsif years >= 3
          #       value = 50000
          #     end
          #   end

          #   sum_amount = o.fetch("sum_amount")

          #   if sum_amount > 0.0
          #     sheet.add_row [
          #         "",
          #         member.full_name_titleize,
          #         member.identification_number,
          #         member.identification_number,
          #         value,
          #         sum_amount,
          #         sum_amount,
          #         "",
          #         sum_amount,
          #         sum_amount,
          #         nil,
          #         nil,
          #         recognition_date
          #     ], style: [nil, nil, date_format_cell, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
          #   end
          # end

          @member_accounts = MemberAccount.where("account_subtype IN (?) AND member_id IN (?)", ["Life Insurance Fund", "Retirement Fund"], @members.pluck(:id))
          @account_transactions = AccountTransaction.where("subsidiary_id IN (?) AND transacted_at >= ? AND transacted_at <= ?", @member_accounts.ids, @start_date, @end_date)
          
          @life_accounts = @member_accounts.where("account_subtype = ?", "Life Insurance Fund")
          @rf_accounts = @member_accounts.where("account_subtype = ?", "Retirement Fund")

          @rf_account_transactions = @account_transactions.where("subsidiary_id IN (?)", @rf_accounts.ids)
          @life_account_transactions = @account_transactions.where("subsidiary_id IN (?)", @life_accounts.ids)

          @life_accounts.each do |life|
            if life.account_transactions.where("transacted_at >= ? AND transacted_at <= ?", @start_date, @end_date).count > 0
              @valid_members << life.member
            end
          end

          # add code check kung may laman ung transaction ni member
          @valid_members.each do |member|
            current_date = @end_date
            recognition_date = member.try(:recognition_date).try(:to_date)
            
            official_receipt_dates = []
            
            total_life_amount = 0.0
            life_amount = 0.0
            total_rf_amount = 0.0
            rf_amount = 0.0

            lif_account = member.member_accounts.where(account_subtype: "Life Insurance Fund").first
            life_insurance_account_transactions = @life_account_transactions.where("subsidiary_id = ?", lif_account.id)
            
            rf_account = member.member_accounts.where(account_subtype: "Retirement Fund").first
            rf_insurance_account_transactions = @rf_account_transactions.where("subsidiary_id = ?", rf_account.id)
            
            if life_insurance_account_transactions.count > 0
            
              if !recognition_date.nil?  
                seconds_between = (current_date.to_time - recognition_date.to_time).abs
                days_between = seconds_between / 60 / 60 / 24
                number_of_months = (days_between / 30.44).floor
                years = (days_between / 365.242199).floor
                months = number_of_months - (years * 12)
                if months < 3 && years < 1
                  value = 2000
                elsif months >= 3 && years < 1 
                  value = 6000
                elsif years >= 1 && years < 2
                  value = 10000
                elsif years >= 2 && years < 3
                  value = 30000
                elsif years >= 3
                  value = 50000
                end
              end  

              life_amount = life_insurance_account_transactions.order("transacted_at ASC, updated_at ASC").last.data.with_indifferent_access["ending_balance"].to_f

              total_life_amount = life_insurance_account_transactions.where("transacted_at >= ? AND transacted_at <= ? AND transaction_type = ? AND data ->> 'is_interest' = ?", @start_date, @end_date, "deposit", "false").sum(:amount).to_f

              life_minus = life_insurance_account_transactions.where("transacted_at >= ? AND transacted_at <= ? AND transaction_type = ?", @start_date, @end_date, "withdraw").sum(:amount).to_f

              if life_minus > 0.0
                total_life_amount = total_life_amount - life_minus
              end  

              official_receipt_dates = life_insurance_account_transactions.where("transacted_at >= ? AND transacted_at <= ?", @start_date, @end_date).order("transacted_at ASC").pluck("date(transacted_at)")

            
              if rf_insurance_account_transactions.count > 0
                rf_amount = rf_insurance_account_transactions.order("transacted_at ASC, updated_at ASC").last.data.with_indifferent_access["ending_balance"].to_f

                total_rf_amount = rf_insurance_account_transactions.where("transacted_at >= ? AND transacted_at <= ? AND transaction_type = ? AND data ->> 'is_interest' = ?", @start_date, @end_date, "deposit", "false").sum(:amount).to_f

                rf_minus = rf_insurance_account_transactions.where("transacted_at >= ? AND transacted_at <= ? AND transaction_type = ?", @start_date, @end_date, "withdraw").sum(:amount).to_f

                if rf_minus > 0.0
                  total_rf_amount = total_rf_amount - rf_minus
                end
              end

              if total_life_amount > 0.0
                sheet.add_row [
                    "",
                    member.full_name_titleize,
                    member.identification_number,
                    member.identification_number,
                    value,
                    life_amount,
                    rf_amount,
                    "",
                    total_life_amount,
                    total_rf_amount,
                    nil,
                    official_receipt_dates.join(', '),
                    recognition_date
                  ], style: [nil, nil, date_format_cell, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
              end
            end
          end
        end
      end

      @p
    end
  end
end
