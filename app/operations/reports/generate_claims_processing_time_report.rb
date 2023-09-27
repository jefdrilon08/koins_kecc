module Reports
  class GenerateClaimsProcessingTimeReport
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch
     
      @p          = Axlsx::Package.new
    end

    def execute!
      if @branch.present?
        query!
      else
        queryAllBranch
      end
      template!
    end

    def query!
       @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT 
            b.name AS branch_name,
            a.claim_type AS claim_type,
            a.date_prepared AS date_prepared,
            a.data ->> 'date_paid' AS date_paid,
            a.data->>'date_of_death_tpd_accident' AS date_of_death_tpd_accident,
            a.data->>'date_reported' AS date_reported,
            a.data->>'date_of_birth' AS date_of_birth,
            a.data->>'date_of_policy_issue' AS date_of_policy_issue,
            DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) AS date_diff_paid_notif,
            DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp ) AS date_diff_paid_process,
            DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) AS date_diff_paid_death,
            DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) AS date_diff_paid_completed,
            DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) AS date_diff_process_notif,
            a.data->>'classification_of_insured' AS classification_of_insured,
            a.data->>'type_of_insurance_policy' AS type_of_insurance_policy,
            a.data->>'amount' AS amount,
            a.data->>'policy_number' AS policy_number,
            a.data->>'face_amount' AS face_amount
            
          FROM Claims a
          LEFT JOIN branches b ON a.branch_id = b.id
          WHERE  a.claim_type = 'BLIP' 
              AND a.status = 'approved'
              AND b.id = '#{@branch}'
              AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
          ORDER BY 
            a.branch_id ASC,
            a.date_prepared ASC
        EOS
    end

    def queryAllBranch
       @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT 
            b.name AS branch_name,
            a.claim_type AS claim_type,
            a.date_prepared AS date_prepared,
            a.data ->> 'date_paid' AS date_paid,
            a.data->>'date_of_death_tpd_accident' AS date_of_death_tpd_accident,
            a.data->>'date_reported' AS date_reported,
            a.data->>'date_of_birth' AS date_of_birth,
            a.data->>'date_of_policy_issue' AS date_of_policy_issue,
            DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) AS date_diff_paid_notif,
            DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp ) AS date_diff_paid_process,
            DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) AS date_diff_paid_death,
            DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) AS date_diff_paid_completed,
            DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) AS date_diff_process_notif,
            a.data->>'classification_of_insured' AS classification_of_insured,
            a.data->>'type_of_insurance_policy' AS type_of_insurance_policy,
            a.data->>'amount' AS amount,
            a.data->>'policy_number' AS policy_number,
            a.data->>'face_amount' AS face_amount
          
          FROM Claims a
          LEFT JOIN branches b ON a.branch_id = b.id
          WHERE  a.claim_type = 'BLIP' 
              AND a.status = 'approved'
              AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
          ORDER BY 
            a.branch_id ASC,
            a.date_prepared ASC
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
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row [
            "CLAIMS PROCESSING TIME REPORT"
            ],style: header

          sheet.add_row [ 
            "BRANCH NAME",
            "CLAIM TYPE",
            "DATE PREPARED",
            "DATE PAID",
            "DATE OF DEATH",
            "DATE REPORTED",
            "DATE OF BIRTH",
            "DATE OF POLICY ISSUED",
            "DATE DIFF PAID AND NOTIF",
            "DATE DIFF PAID AND PROCESS",
            "DATE DIFF PAID AND DEATH",
            "DATE DIFF PAID AND COMPLETED",
            "DATE DIFF NOTIF AND PROCESS",
            "CLASSIFICATION OF INSURED",
            "TYPE OF POLICY",
            "AMOUNT",
            "POLICY NUMBER",
            "FACE AMOUNT"
          ], style: header
          @result.each do |claim|
            sheet.add_row [
                branch_name = claim.fetch("branch_name"),
                claim_type = claim.fetch("claim_type"),
                date_prepared = claim.fetch("date_prepared"),
                date_paid = claim.fetch("date_paid"),
                date_of_death_tpd_accident = claim.fetch("date_of_death_tpd_accident"),
                date_reported = claim.fetch("date_reported"),
                date_of_birth = claim.fetch("date_of_birth"),
                date_of_policy_issue = claim.fetch("date_of_policy_issue"),
                date_diff_paid_notif = claim.fetch("date_diff_paid_notif"),
                date_diff_paid_process = claim.fetch("date_diff_paid_process"),
                date_diff_paid_death = claim.fetch("date_diff_paid_death"),
                date_diff_paid_completed = claim.fetch("date_diff_paid_completed"),
                date_diff_process_notif = claim.fetch("date_diff_process_notif"),
                classification_of_insured = claim.fetch("classification_of_insured"),
                type_of_insurance_policy = claim.fetch("type_of_insurance_policy"),
                amount = claim.fetch("amount"),
                policy_number = claim.fetch("policy_number"),
                face_amount = claim.fetch("face_amount")
              ], style: [nil]             
            end
         
          end
        end
      @p
    end
  end
end
