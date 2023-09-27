module Reports
  class GenerateClaimsProcessingTimeReportSummary
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
        queryDatePaidToNotify!
        queryDatePaidToProcess!
        queryDatePaidToDateOfDeath!
        queryDatePaidToDateCompletedDocs!
        queryDateNotifyToProcess!
      end
      template!
    end

    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT
            SUM((CASE WHEN summary_class = '1-3-5 DAYS' THEN COUNTS END)) AS one_three_five_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 5 DAYS' THEN  COUNTS END)) AS more_than_five_days,
            SUM((CASE WHEN summary_class = '1 DAY' THEN COUNTS END)) AS one_day,
            SUM((CASE WHEN summary_class = '2-3 DAYS' THEN COUNTS END)) AS two_to_three_days,
            SUM((CASE WHEN summary_class = '4-5 DAYS' THEN COUNTS END)) AS four_to_five_days,
            SUM((CASE WHEN summary_class = '6-10 DAYS' THEN COUNTS END)) AS six_to_ten_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 10 DAYS' THEN COUNTS END)) AS more_than_ten_days
          FROM
              (
                SELECT  
                  summary_classification AS summary_class,
                  COUNT(summary_classification) AS COUNTS
                FROM
                  (
                    SELECT
                      '0' AS classification, 
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) <= 5 
                          THEN '1-3-5 DAYS'
                        ELSE 'MORE THAN 5 DAYS'
                      END AS summary_classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND b.id = '#{@branch}'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL
                       
                    UNION ALL
                       
                    SELECT
                      '0' AS summary_classification,
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) < 2 
                          THEN '1 DAY'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) > 1 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) <= 3 
                          THEN '2-3 DAYS' 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) > 3 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) <= 5
                          THEN '4-5 DAYS'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) > 5 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) <= 10 
                          THEN '6-10 DAYS'
                        ELSE 'MORE THAN 10 DAYS'
                      END AS classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND b.id = '#{@branch}'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL  
                  ) y
                GROUP BY 
                  y.summary_classification
              )x
      EOS
    end

    def queryDatePaidToNotify!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT
            SUM((CASE WHEN summary_class = '1-3-5 DAYS' THEN COUNTS END)) AS one_three_five_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 5 DAYS' THEN  COUNTS END)) AS more_than_five_days,
            SUM((CASE WHEN summary_class = '1 DAY' THEN COUNTS END)) AS one_day,
            SUM((CASE WHEN summary_class = '2-3 DAYS' THEN COUNTS END)) AS two_to_three_days,
            SUM((CASE WHEN summary_class = '4-5 DAYS' THEN COUNTS END)) AS four_to_five_days,
            SUM((CASE WHEN summary_class = '6-10 DAYS' THEN COUNTS END)) AS six_to_ten_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 10 DAYS' THEN COUNTS END)) AS more_than_ten_days
          FROM
              (
                SELECT  
                  summary_classification AS summary_class,
                  COUNT(summary_classification) AS COUNTS
                FROM
                  (
                    SELECT
                      '0' AS classification, 
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) <= 5 
                          THEN '1-3-5 DAYS'
                        ELSE 'MORE THAN 5 DAYS'
                      END AS summary_classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL
                       
                    UNION ALL
                       
                    SELECT
                      '0' AS summary_classification,
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) < 2 
                          THEN '1 DAY'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) > 1 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) <= 3 
                          THEN '2-3 DAYS' 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) > 3 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) <= 5
                          THEN '4-5 DAYS'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) > 5 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_reported')::timestamp) <= 10 
                          THEN '6-10 DAYS'
                        ELSE 'MORE THAN 10 DAYS'
                      END AS classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL  
                  ) y
                GROUP BY 
                  y.summary_classification
              )x
      EOS
    end

    def queryDatePaidToProcess!
      @result1 = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT
            SUM((CASE WHEN summary_class = '1-3-5 DAYS' THEN COUNTS END)) AS one_three_five_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 5 DAYS' THEN  COUNTS END)) AS more_than_five_days,
            SUM((CASE WHEN summary_class = '1 DAY' THEN COUNTS END)) AS one_day,
            SUM((CASE WHEN summary_class = '2-3 DAYS' THEN COUNTS END)) AS two_to_three_days,
            SUM((CASE WHEN summary_class = '4-5 DAYS' THEN COUNTS END)) AS four_to_five_days,
            SUM((CASE WHEN summary_class = '6-10 DAYS' THEN COUNTS END)) AS six_to_ten_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 10 DAYS' THEN COUNTS END)) AS more_than_ten_days
          FROM
              (
                SELECT  
                  summary_classification AS summary_class,
                  COUNT(summary_classification) AS COUNTS
                FROM
                  (
                    SELECT
                      '0' AS classification, 
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) <= 5 
                          THEN '1-3-5 DAYS'
                        ELSE 'MORE THAN 5 DAYS'
                      END AS summary_classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL
                       
                    UNION ALL
                       
                    SELECT
                      '0' AS summary_classification,
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) < 2 
                          THEN '1 DAY'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) > 1 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) <= 3 
                          THEN '2-3 DAYS' 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) > 3 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) <= 5
                          THEN '4-5 DAYS'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) > 5 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - "date_prepared"::timestamp) <= 10 
                          THEN '6-10 DAYS'
                        ELSE 'MORE THAN 10 DAYS'
                      END AS classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL  
                  ) y
                GROUP BY 
                  y.summary_classification
              )x
      EOS
    end

    def queryDatePaidToDateOfDeath!
      @result2 = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT
            SUM((CASE WHEN summary_class = '1-3-5 DAYS' THEN COUNTS END)) AS one_three_five_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 5 DAYS' THEN  COUNTS END)) AS more_than_five_days,
            SUM((CASE WHEN summary_class = '1 DAY' THEN COUNTS END)) AS one_day,
            SUM((CASE WHEN summary_class = '2-3 DAYS' THEN COUNTS END)) AS two_to_three_days,
            SUM((CASE WHEN summary_class = '4-5 DAYS' THEN COUNTS END)) AS four_to_five_days,
            SUM((CASE WHEN summary_class = '6-10 DAYS' THEN COUNTS END)) AS six_to_ten_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 10 DAYS' THEN COUNTS END)) AS more_than_ten_days
          FROM
              (
                SELECT  
                  summary_classification AS summary_class,
                  COUNT(summary_classification) AS COUNTS
                FROM
                  (
                    SELECT
                      '0' AS classification, 
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) <= 5 
                          THEN '1-3-5 DAYS'
                        ELSE 'MORE THAN 5 DAYS'
                      END AS summary_classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL
                       
                    UNION ALL
                       
                    SELECT
                      '0' AS summary_classification,
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) < 2 
                          THEN '1 DAY'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) > 1 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) <= 3 
                          THEN '2-3 DAYS' 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) > 3 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) <= 5
                          THEN '4-5 DAYS'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) > 5 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_of_death_tpd_accident')::timestamp) <= 10 
                          THEN '6-10 DAYS'
                        ELSE 'MORE THAN 10 DAYS'
                      END AS classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL  
                  ) y
                GROUP BY 
                  y.summary_classification
              )x
      EOS
    end

    def queryDatePaidToDateCompletedDocs!
      @result3 = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT
            SUM((CASE WHEN summary_class = '1-3-5 DAYS' THEN COUNTS END)) AS one_three_five_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 5 DAYS' THEN  COUNTS END)) AS more_than_five_days,
            SUM((CASE WHEN summary_class = '1 DAY' THEN COUNTS END)) AS one_day,
            SUM((CASE WHEN summary_class = '2-3 DAYS' THEN COUNTS END)) AS two_to_three_days,
            SUM((CASE WHEN summary_class = '4-5 DAYS' THEN COUNTS END)) AS four_to_five_days,
            SUM((CASE WHEN summary_class = '6-10 DAYS' THEN COUNTS END)) AS six_to_ten_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 10 DAYS' THEN COUNTS END)) AS more_than_ten_days
          FROM
              (
                SELECT  
                  summary_classification AS summary_class,
                  COUNT(summary_classification) AS COUNTS
                FROM
                  (
                    SELECT
                      '0' AS classification, 
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) <= 5 
                          THEN '1-3-5 DAYS'
                        ELSE 'MORE THAN 5 DAYS'
                      END AS summary_classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL
                       
                    UNION ALL
                       
                    SELECT
                      '0' AS summary_classification,
                      CASE 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) < 2 
                          THEN '1 DAY'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) > 1 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) <= 3 
                          THEN '2-3 DAYS' 
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) > 3 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) <= 5
                          THEN '4-5 DAYS'
                        WHEN DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) > 5 AND DATE_PART('day', DATE(a.data ->> 'date_paid')::timestamp - DATE(data ->> 'date_completed_documents')::timestamp ) <= 10 
                          THEN '6-10 DAYS'
                        ELSE 'MORE THAN 10 DAYS'
                      END AS classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL  
                  ) y
                GROUP BY 
                  y.summary_classification
              )x
      EOS
    end

    def queryDateNotifyToProcess!
      @result4 = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT
            SUM((CASE WHEN summary_class = '1-3-5 DAYS' THEN COUNTS END)) AS one_three_five_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 5 DAYS' THEN  COUNTS END)) AS more_than_five_days,
            SUM((CASE WHEN summary_class = '1 DAY' THEN COUNTS END)) AS one_day,
            SUM((CASE WHEN summary_class = '2-3 DAYS' THEN COUNTS END)) AS two_to_three_days,
            SUM((CASE WHEN summary_class = '4-5 DAYS' THEN COUNTS END)) AS four_to_five_days,
            SUM((CASE WHEN summary_class = '6-10 DAYS' THEN COUNTS END)) AS six_to_ten_days,
            SUM((CASE WHEN summary_class = 'MORE THAN 10 DAYS' THEN COUNTS END)) AS more_than_ten_days
          FROM
              (
                SELECT  
                  summary_classification AS summary_class,
                  COUNT(summary_classification) AS COUNTS
                FROM
                  (
                    SELECT
                      '0' AS classification, 
                      CASE 
                        WHEN DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) <= 5 
                          THEN '1-3-5 DAYS'
                        ELSE 'MORE THAN 5 DAYS'
                      END AS summary_classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL
                       
                    UNION ALL
                       
                    SELECT
                      '0' AS summary_classification,
                      CASE 
                        WHEN DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) < 2 
                          THEN '1 DAY'
                        WHEN DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) > 1 AND DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) <= 3 
                          THEN '2-3 DAYS' 
                        WHEN DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) > 3 AND DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) <= 5
                          THEN '4-5 DAYS'
                        WHEN DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) > 5 AND DATE_PART('day', DATE("date_prepared")::timestamp - DATE(a.data ->> 'date_reported')::timestamp) <= 10 
                          THEN '6-10 DAYS'
                        ELSE 'MORE THAN 10 DAYS'
                      END AS classification
                    FROM Claims a
                      LEFT JOIN branches b ON a.branch_id = b.id
                    WHERE  a.claim_type = 'BLIP' 
                      AND a.status = 'approved'
                      AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}' )
                      AND a.data ->> 'date_paid' IS NOT NULL  
                  ) y
                GROUP BY 
                  y.summary_classification
              )x
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
              "SUMMARY DATE PAID - DATE NOTIFY"
              ],style: header
            sheet.add_row [ 
              "TIME",
              "1-3-5 DAYS",
              "> 5 DAYS",
              "TOTAL",
              "1 DAY",
              "2-3 DAYS",
              "4-5 DAYS",
              "6-10 DAYS",
              "> 10 DAYS"
            ], style: header

            @result.each do |claim|
              sheet.add_row [
                  'DURATION',
                  date_diff_paid_notif = claim.fetch("one_three_five_days"),
                  date_diff_paid_notif = claim.fetch("more_than_five_days"),
                  0,
                  date_diff_paid_notif = claim.fetch("one_day"),
                  date_diff_paid_notif = claim.fetch("two_to_three_days"),
                  date_diff_paid_notif = claim.fetch("four_to_five_days"),
                  date_diff_paid_notif = claim.fetch("six_to_ten_days"),
                  date_diff_paid_notif = claim.fetch("more_than_ten_days")
                ], style: [nil]             
              end

              sheet.add_row []

              sheet.add_row [
                "SUMMARY DATE PAID - DATE PROCESS"
                ],style: header
              sheet.add_row [ 
                "TIME",
                "1-3-5 DAYS",
                "> 5 DAYS",
                "TOTAL",
                "1 DAY",
                "2-3 DAYS",
                "4-5 DAYS",
                "6-10 DAYS",
                "> 10 DAYS"
              ], style: header

              @result1.each do |claim|
                sheet.add_row [
                    'DURATION',
                    date_diff_paid_process = claim.fetch("one_three_five_days"),
                    date_diff_paid_process = claim.fetch("more_than_five_days"),
                    0,
                    date_diff_paid_process = claim.fetch("one_day"),
                    date_diff_paid_process = claim.fetch("two_to_three_days"),
                    date_diff_paid_process = claim.fetch("four_to_five_days"),
                    date_diff_paid_process = claim.fetch("six_to_ten_days"),
                    date_diff_paid_process = claim.fetch("more_than_ten_days")
                  ], style: [nil]             
                end

              sheet.add_row []

              sheet.add_row [
                "SUMMARY DATE PAID - DATE OF DEATH"
                ],style: header
              sheet.add_row [ 
                "TIME",
                "1-3-5 DAYS",
                "> 5 DAYS",
                "TOTAL",
                "1 DAY",
                "2-3 DAYS",
                "4-5 DAYS",
                "6-10 DAYS",
                "> 10 DAYS"
              ], style: header

              @result2.each do |claim|
                sheet.add_row [
                    'DURATION',
                    date_diff_paid_death = claim.fetch("one_three_five_days"),
                    date_diff_paid_death = claim.fetch("more_than_five_days"),
                    0,
                    date_diff_paid_death = claim.fetch("one_day"),
                    date_diff_paid_death = claim.fetch("two_to_three_days"),
                    date_diff_paid_death = claim.fetch("four_to_five_days"),
                    date_diff_paid_death = claim.fetch("six_to_ten_days"),
                    date_diff_paid_death = claim.fetch("more_than_ten_days")
                  ], style: [nil]             
                end

              sheet.add_row []

              sheet.add_row [
                "SUMMARY DATE PAID - DATE COMPLETED DOCUMENTS"
                ],style: header
              sheet.add_row [ 
                "TIME",
                "1-3-5 DAYS",
                "> 5 DAYS",
                "TOTAL",
                "1 DAY",
                "2-3 DAYS",
                "4-5 DAYS",
                "6-10 DAYS",
                "> 10 DAYS"
              ], style: header

              @result3.each do |claim|
                sheet.add_row [
                    'DURATION',
                    date_diff_paid_completed = claim.fetch("one_three_five_days"),
                    date_diff_paid_completed = claim.fetch("more_than_five_days"),
                    0,
                    date_diff_paid_completed = claim.fetch("one_day"),
                    date_diff_paid_completed = claim.fetch("two_to_three_days"),
                    date_diff_paid_completed = claim.fetch("four_to_five_days"),
                    date_diff_paid_completed = claim.fetch("six_to_ten_days"),
                    date_diff_paid_completed = claim.fetch("more_than_ten_days")
                  ], style: [nil]             
                end

              sheet.add_row []

              sheet.add_row [
                "SUMMARY DATE NOTIFY - DATE PROCESS"
                ],style: header
              sheet.add_row [ 
                "TIME",
                "1-3-5 DAYS",
                "> 5 DAYS",
                "TOTAL",
                "1 DAY",
                "2-3 DAYS",
                "4-5 DAYS",
                "6-10 DAYS",
                "> 10 DAYS"
              ], style: header

              @result4.each do |claim|
                sheet.add_row [
                    'DURATION',
                    date_diff_process_notif = claim.fetch("one_three_five_days"),
                    date_diff_process_notif = claim.fetch("more_than_five_days"),
                    0,
                    date_diff_process_notif = claim.fetch("one_day"),
                    date_diff_process_notif = claim.fetch("two_to_three_days"),
                    date_diff_process_notif = claim.fetch("four_to_five_days"),
                    date_diff_process_notif = claim.fetch("six_to_ten_days"),
                    date_diff_process_notif = claim.fetch("more_than_ten_days")
                  ], style: [nil]             
                end

            end
          end
      @p
    end
  end

end
