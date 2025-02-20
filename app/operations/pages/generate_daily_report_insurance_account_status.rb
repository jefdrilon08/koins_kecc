module Pages
  class GenerateDailyReportInsuranceAccountStatus
    def initialize(branch:, insurance_status:)
      @branch                         = branch
      @insurance_status               = insurance_status
      @centers                        = Center.where(branch_id: @branch).order("name ASC")
      @p                              = Axlsx::Package.new
    end

    def execute!
      if @branch.present? && @insurance_status.present?
        branch_query!
      elsif @branch.present?
        branch_only_query!
      else
        all_query!
      end
      template!
    end

    def branch_query!
      @query = ActiveRecord::Base.connection.execute(<<-EOS).to_a
        WITH LatestTransactions AS (
          SELECT
            a.id AS members_id,
            CONCAT(a.last_name, ' ', a.first_name, ' ', a.middle_name) AS member_name,
            a.data->>'recognition_date' AS recognition_date,
            a.data->'reinstatement'->>'reinstatement_date' AS reinstatement_date,
            a.data->'reinstatement'->>'old_recognition_date' AS old_recognition_date,
            a.data->'reinstatement'->>'date_stop' as date_stop,
            a.status AS status,
            a.insurance_status AS insurance_status,
            c.name AS center_name,
            a.identification_number AS identification_number,
            a.mobile_number AS mobile_number,
            a.date_of_birth AS date_of_birth,
            a.member_type AS member_type,
            a.insurance_date_resigned as insurance_date_resigned,
            -- Life Insurance Fund transaction/amount/date
            d.transacted_at AS lif_transaction_date,
            d.amount AS lif_last_transaction_amount,
            b.balance AS lif_sum_amount,
            CONCAT(e.first_name,' ', e.last_name) as coordinator_name,
            e.category,
            ROW_NUMBER() OVER(PARTITION BY a.id ORDER BY d.transacted_at DESC) AS row_num
          FROM members a
          LEFT JOIN member_accounts b ON b.member_id = a.id
          LEFT JOIN centers c ON c.id = a.center_id
          LEFT JOIN account_transactions d ON d.subsidiary_id = b.id
          LEFT JOIN referrers e ON e.id = a.coordinator_id
          WHERE
            d.data->>'is_interest' = 'false'
            AND b.account_subtype = 'Life Insurance Fund'
            AND a.insurance_status = '#{@insurance_status}'
            AND a.status IN ('active', 'resigned')
            AND a.branch_id = '#{@branch}'
            AND a.data->>'recognition_date' IS NOT NULL
        )
        SELECT
          members_id,
          member_name,
          recognition_date,
          reinstatement_date,
          old_recognition_date,
          date_stop,
          status,
          insurance_status,
          center_name,
          identification_number,
          mobile_number,
          date_of_birth,
          member_type,
          insurance_date_resigned,
          EXTRACT(YEAR FROM AGE(NOW(), date_of_birth)) AS age,
          -- Life Insurance Fund
          lif_transaction_date,
          lif_last_transaction_amount,
          lif_sum_amount,
          coordinator_name,
          category
        FROM LatestTransactions
        WHERE row_num = 1
        ORDER BY center_name
      EOS
    end

    def branch_only_query!
      @query = ActiveRecord::Base.connection.execute(<<-EOS).to_a
        WITH LatestTransactions AS (
          SELECT
            a.id AS members_id,
            CONCAT(a.last_name, ' ', a.first_name, ' ', a.middle_name) AS member_name,
            a.data->>'recognition_date' AS recognition_date,
            a.data->'reinstatement'->>'reinstatement_date' AS reinstatement_date,
            a.data->'reinstatement'->>'old_recognition_date' AS old_recognition_date,
            a.data->'reinstatement'->>'date_stop' as date_stop,
            a.status AS status,
            a.insurance_status AS insurance_status,
            c.name AS center_name,
            a.identification_number AS identification_number,
            a.mobile_number AS mobile_number,
            a.date_of_birth AS date_of_birth,
            a.member_type AS member_type,
            a.insurance_date_resigned as insurance_date_resigned,
            d.transacted_at AS lif_transaction_date,
            d.amount AS lif_last_transaction_amount,
            b.balance AS lif_sum_amount,
            CONCAT(e.first_name,' ', e.last_name) as coordinator_name,
            e.category,
            ROW_NUMBER() OVER(PARTITION BY a.id ORDER BY d.transacted_at DESC) AS row_num
          FROM members a
          LEFT JOIN member_accounts b ON b.member_id = a.id
          LEFT JOIN centers c ON c.id = a.center_id
          LEFT JOIN account_transactions d ON d.subsidiary_id = b.id
          LEFT JOIN referrers e ON e.id = a.coordinator_id
          WHERE
          d.data->>'is_interest' = 'false'
          AND b.account_subtype = 'Life Insurance Fund'
          AND a.insurance_status IN ('inforce', 'lapsed')
          AND a.branch_id = '#{@branch}'
          AND a.data->>'recognition_date' IS NOT NULL
        )
        SELECT
          members_id,
          member_name,
          recognition_date,
          reinstatement_date,
          old_recognition_date,
          date_stop,
          status,
          insurance_status,
          center_name,
          identification_number,
          mobile_number,
          date_of_birth,
          member_type,
          insurance_date_resigned,
          EXTRACT(YEAR FROM AGE(NOW(), date_of_birth)) AS age,
          lif_transaction_date,
          lif_last_transaction_amount,
          lif_sum_amount,
          coordinator_name,
          category
        FROM LatestTransactions
        WHERE row_num = 1
        ORDER BY center_name, insurance_status
      EOS
    end

    def all_query!
      @query = ActiveRecord::Base.connection.execute(<<-EOS).to_a
        WITH LatestTransactions AS (
          SELECT
            a.id AS members_id,
            CONCAT(a.last_name, ' ', a.first_name, ' ', a.middle_name) AS member_name,
            a.data->>'recognition_date' AS recognition_date,
            a.data->'reinstatement'->>'reinstatement_date' AS reinstatement_date,
            a.status AS status,
            a.insurance_status AS insurance_status,
            c.name AS center_name,
            a.identification_number AS identification_number,
            a.mobile_number AS mobile_number,
            a.date_of_birth AS date_of_birth,
            a.member_type AS member_type,
            a.insurance_date_resigned as insurance_date_resigned,
            d.transacted_at AS lif_transaction_date,
            d.amount AS lif_last_transaction_amount,
            b.balance AS lif_sum_amount,
            ROW_NUMBER() OVER(PARTITION BY a.id ORDER BY d.transacted_at DESC) AS row_num
          FROM members a
          LEFT JOIN member_accounts b ON b.member_id = a.id
          LEFT JOIN centers c ON c.id = a.center_id
          LEFT JOIN account_transactions d ON d.subsidiary_id = b.id
          WHERE
          d.data->>'is_interest' = 'false'
          AND b.account_subtype = 'Life Insurance Fund'
          AND a.insurance_status IN ('inforce', 'lapsed')
          AND a.data->>'recognition_date' IS NOT NULL
        )
        SELECT
          members_id,
          member_name,
          recognition_date,
          reinstatement_date,
          status,
          insurance_status,
          center_name,
          identification_number,
          mobile_number,
          date_of_birth,
          member_type,
          insurance_date_resigned,
          EXTRACT(YEAR FROM AGE(NOW(), date_of_birth)) AS age,
          -- Life Insurance Fund
          lif_transaction_date,
          lif_last_transaction_amount,
          lif_sum_amount
        FROM LatestTransactions
        WHERE row_num = 1
        ORDER BY center_name
      EOS
    end

    def template!
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
          right_aligned_cell = wb.styles.add_style alignment: { horizontal: :right }, font_name: "Calibri"
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row [
            "INSURANCE ACCOUNT STATUS"
            ],style: header

          sheet.add_row [
            "Member",
            "Recognition Date",
            "Reinstatement Date",
            "Member Status",
            "Insurance Status",
            "Center",
            "Length of Membership",
            "Certificate Number",
            "Mobile Number",
            "LIFE",
            "Coverage Date",
            "LIFE Number of Weeks Due",
            "LIFE Amount Due",
            "Status",
            "RF",
            "Coverage Date",
            "RF Number of Weeks Due",
            "RF Amount Due",
            "Status",
            "Date of Birth",
            "Age",
            "Member Type",
            "LIF Last Amount",
            "RF Last Amount",
            "Date Paid",
            "Insurance Coordinator"
          ], style: header

          @query.each do |member|
            id                                = member.fetch("members_id")
            age                               = Member.find(id).age
            current_date                      = Date.today
            rf_amount_display                        = (member.fetch("lif_last_transaction_amount").to_i / 3).to_i
            member_type                       = member.fetch("member_type")
            insurance_date_resigned           = member.fetch("insurance_date_resigned")
            insurance_status                  = member.fetch("insurance_status")

            if member.fetch("reinstatement_date").present?
              old_recognition_date            = member.fetch("old_recognition_date").to_date
              reinstatement_date              = member.fetch("reinstatement_date").to_date
              date_stop                       = member.fetch("date_stop").to_date
              length_of_stay                  = Member.find(id).length_of_stay

              #Life Insurance Fund
                lif_sum_amount                = member.fetch("lif_sum_amount").to_i
                lif_account                   = member.fetch("lif_last_transaction_amount")
                lif_transaction_date          = member.fetch("lif_transaction_date").to_date
                lif_default                   = 15

                lif_add                       = (lif_sum_amount / lif_default).weeks
                lif_coverage                  = (old_recognition_date + ((lif_sum_amount / lif_default) * 7).to_i + (reinstatement_date - date_stop).to_i).strftime("%B %d, %Y")

                # lif_coverage                  = (reinstatement_date + lif_add).strftime("%B %d, %Y")

                lif_num_days                  = (current_date - reinstatement_date).to_i + (date_stop - old_recognition_date).to_i
                lif_num_weeks                 = (lif_num_days / 7).to_i + 1

                lif_insured_amount            = lif_num_weeks  * lif_default
                # raise lif_num_weeks.inspect
                lif_amt_past_due              = (lif_sum_amount - lif_insured_amount).to_i * -1

                # raise [lif_sum_amount, lif_insured_amount].inspect
                lif_num_weeks_past_due        = (lif_amt_past_due / lif_default)
                lif_less_balance              = (current_date - lif_transaction_date).to_i

                total_compute_life            = (lif_sum_amount / lif_default).to_i
                lif_lapsed                    = (total_compute_life - lif_num_weeks).to_i
                days_lapsed                   = (current_date - lif_transaction_date).to_i

                if member_type == "GK"
                  status = "resigned"
                end

                if lif_sum_amount == 0.0 && insurance_status == "resigned"
                  status = "resigned"
                end

                if status == "resigned" && lif_sum_amount == 0.0
                  status = "resigned"
                end

                if status == "archived" && lif_sum_amount == 0.0
                  status = "transferred"
                end

                if lif_sum_amount == 0.0 && insurance_date_resigned.present?
                  status = "resigned"
                end

                if status == "resigned" && insurance_date_resigned.present? && lif_sum_amount == 0.0
                  status = "resigned"
                end

                if lif_amt_past_due >= 2340 && insurance_status != "resigned" && lif_sum_amount > 0.0 && member_type != "GK"
                  if lif_amt_past_due >= 2340
                    status = "dormant"
                  end
                end

                if days_lapsed <= 45 && lif_sum_amount < lif_insured_amount && lif_amt_past_due >= 97 && lif_amt_past_due < 2340 && insurance_status != "resigned" && lif_sum_amount > 0.0 && member_type != "GK"
                  status = "lapsed"
                end

                if days_lapsed > 45 && lif_sum_amount < lif_insured_amount && lif_amt_past_due >= 97 && lif_amt_past_due < 2340 && insurance_status != "resigned" && lif_sum_amount > 0.0 && member_type != "GK"
                  status = "lapsed"
                end

                if days_lapsed <= 45 && lif_sum_amount >= lif_insured_amount && insurance_status != "resigned" && member_type != "GK"
                  status = "inforce"
                end

                if days_lapsed > 45 && lif_sum_amount >= lif_insured_amount && insurance_status != "resigned" && member_type != "GK"
                  status = "inforce"
                end

                if days_lapsed <= 45 && lif_sum_amount < lif_insured_amount && lif_amt_past_due < 97 && insurance_status != "resigned" && member_type != "GK"
                  status = "inforce"
                end

                if days_lapsed > 45 && lif_sum_amount < lif_insured_amount && lif_amt_past_due < 97 && insurance_status != "resigned" && member_type != "GK"
                  status = "inforce"
                end
              #Life Insurance Fund

              #Retirement Fund
                rf_sum_amount                = ReadOnlyMemberAccount.where(account_subtype: 'Retirement Fund', member_id: id).sum(:balance).to_f
                rf_default                   = 5

                rf_add                       = (rf_sum_amount / rf_default).weeks
                # rf_coverage                  = (reinstatement_date + lif_add).strftime("%B %d, %Y")
                rf_coverage                  = (old_recognition_date + ((rf_sum_amount / rf_default) * 7).to_i + (reinstatement_date - date_stop).to_i).strftime("%B %d, %Y")
                rf_num_days                  = (current_date - reinstatement_date).to_i + (date_stop - old_recognition_date).to_i
                rf_num_weeks                 = (rf_num_days / 7).to_i + 1

                rf_insured_amount            = rf_num_weeks  * rf_default
                rf_amt_past_due              = (rf_sum_amount - rf_insured_amount) * -1
                rf_num_weeks_past_due        = (rf_amt_past_due / rf_default)
              #Retirement Fund
            elsif member.fetch("recognition_date").present?
              recognition_date        = Date.parse(member.fetch("recognition_date"))
              length_of_stay          = Member.find(id).length_of_stay

              #Life Insurance Fund
                lif_sum_amount                = member.fetch("lif_sum_amount").to_i
                lif_account                   = member.fetch("lif_last_transaction_amount")
                lif_transaction_date          = member.fetch("lif_transaction_date").to_date
                lif_default                   = 15

                lif_add                       = (lif_sum_amount / lif_default).weeks
                lif_coverage                  = (recognition_date + lif_add).strftime("%B %d, %Y")

                lif_num_days                  = (current_date - recognition_date).to_i
                lif_num_weeks                 = (lif_num_days / 7).to_i + 1

                lif_insured_amount            = lif_num_weeks  * lif_default
                lif_amt_past_due              = (lif_sum_amount - lif_insured_amount).to_i * -1

                lif_num_weeks_past_due        = (lif_amt_past_due / lif_default).floor(0)
                lif_less_balance              = (current_date - lif_transaction_date).to_i

                total_compute_life            = (lif_sum_amount / lif_default).to_i
                lif_lapsed                    = (total_compute_life - lif_num_weeks).to_i
                days_lapsed                   = (current_date - lif_transaction_date).to_i

                if member_type == "GK"
                  status = "resigned"
                end

                if lif_sum_amount == 0.0 && insurance_status == "resigned"
                  status = "resigned"
                end

                if status == "resigned" && lif_sum_amount == 0.0
                  status = "resigned"
                end

                if status == "archived" && lif_sum_amount == 0.0
                  status = "transferred"
                end

                if lif_sum_amount == 0.0 && insurance_date_resigned.present?
                  status = "resigned"
                end

                if status == "resigned" && insurance_date_resigned.present? && lif_sum_amount == 0.0
                  status = "resigned"
                end

                if lif_amt_past_due >= 2340 && insurance_status != "resigned" && lif_sum_amount > 0.0 && member_type != "GK"
                  if lif_amt_past_due >= 2340
                    status = "dormant"
                  end
                end

                if days_lapsed <= 45 && lif_sum_amount < lif_insured_amount && lif_amt_past_due >= 97 && lif_amt_past_due < 2340 && insurance_status != "resigned" && lif_sum_amount > 0.0 && member_type != "GK"
                  status = "lapsed"
                end

                if days_lapsed > 45 && lif_sum_amount < lif_insured_amount && lif_amt_past_due >= 97 && lif_amt_past_due < 2340 && insurance_status != "resigned" && lif_sum_amount > 0.0 && member_type != "GK"
                  status = "lapsed"
                end

                if days_lapsed <= 45 && lif_sum_amount >= lif_insured_amount && insurance_status != "resigned" && member_type != "GK"
                  status = "inforce"
                end

                if days_lapsed > 45 && lif_sum_amount >= lif_insured_amount && insurance_status != "resigned" && member_type != "GK"
                  status = "inforce"
                end

                if days_lapsed <= 45 && lif_sum_amount < lif_insured_amount && lif_amt_past_due < 97 && insurance_status != "resigned" && member_type != "GK"
                  status = "inforce"
                end

                if days_lapsed > 45 && lif_sum_amount < lif_insured_amount && lif_amt_past_due < 97 && insurance_status != "resigned" && member_type != "GK"
                  status = "inforce"
                end
              #Life Insurance Fund

              #Retirement Fund
                rf_sum_amount                = ReadOnlyMemberAccount.where(account_subtype: 'Retirement Fund', member_id: id).sum(:balance).to_f
                rf_default                   = 5

                rf_add                       = ((rf_sum_amount / rf_default).to_i).weeks
                rf_coverage                  = (recognition_date + rf_add).strftime("%B %d, %Y")

                rf_num_days                  = (current_date - recognition_date).to_i
                rf_num_weeks                 = (rf_num_days / 7).to_i + 1

                rf_insured_amount            = rf_num_weeks  * rf_default
                rf_amt_past_due              = (rf_sum_amount - rf_insured_amount) * -1
                rf_num_weeks_past_due        = (rf_amt_past_due / rf_default)
              #Retirement Fund
            end

            sheet.add_row [
                member.fetch("member_name"),
                if recognition_date.present? #old recognition_date from reinstate
                  member.fetch("recognition_date").try(:to_date).strftime("%b %d, %Y")
                else
                  member.fetch("old_recognition_date").try(:to_date).strftime("%b %d, %Y")
                end,
                if reinstatement_date.present?
                  member.fetch("reinstatement_date").try(:to_date).strftime("%b %d, %Y")
                else
                  "N/A"
                end,
                member.fetch("status"),
                member.fetch("insurance_status"),
                member.fetch("center_name"),
                length_of_stay,
                member.fetch("identification_number"),
                member.fetch("mobile_number"),
                member.fetch("lif_sum_amount"),
                lif_coverage,
                lif_num_weeks_past_due,
                lif_amt_past_due,
                status,
                rf_sum_amount.to_f,
                rf_coverage,
                rf_num_weeks_past_due,
                rf_amt_past_due,
                status,
                member.fetch("date_of_birth").try(:to_date).strftime("%b %d, %Y"),
                member.fetch("age"),
                member_type,
                member.fetch("lif_last_transaction_amount").to_i,
                rf_amount_display,
                member.fetch("lif_transaction_date").try(:to_date).strftime("%b %d, %Y"),
                member.fetch("coordinator_name")
              ], style: [ left_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, currency_cell_right, right_aligned_cell, currency_cell_right, right_aligned_cell, right_aligned_cell, currency_cell_right, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell, right_aligned_cell ]
            end
          end
        end
      @p
    end
  end
end
