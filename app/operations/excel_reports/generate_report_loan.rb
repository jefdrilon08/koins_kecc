module ExcelReports
    class GenerateReportLoan
      def initialize(config:)
        @config = config
        @branch_id = @config[:branch_id]
        @as_of = @config[:as_of]
        @loan_product_id = @config[:loan_id]
  
        # Retrieve data store entry
        @data_store = DataStore.where(
          "meta ->> 'data_store_type' = ? AND meta ->> 'as_of' = ? AND meta ->> 'branch_id' = ?",
          'REPAYMENT_RATES', @as_of, @branch_id
        ).last
  
        @p = Axlsx::Package.new
      end
  
      def execute!
        @p.workbook do |wb|
          wb.add_worksheet(name: "Loan Report") do |sheet|
            # Define styles
            title_cell = wb.styles.add_style b: true, font_name: "Calibri"
            header_style = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
  
            # Add title and headers
            sheet.add_row ["Loan Report - #{@as_of}"], style: title_cell
            sheet.add_row [
              'Member Name', 'Center', 'Loan Product', 'Amount', 'Date Released', 'Maturity Date', 'Loan Term',
              'Monthly Interest Rate', 'Principal Balance', 'Interest Balance', 'PAR Amount', 'Num Days Par', 'RR Percentage', 'Type of Livelihood', 'Amount Paid'
            ], style: header_style
  
            # Check if data store exists and process data
            if @data_store.present?
              process_data_rows(sheet)
            else
              sheet.add_row ['No data found for the specified criteria.']
            end
  
            sheet.add_row ["END"], style: title_cell
          end
        end
  
        @p
      end
  
      private
  
      def process_data_rows(sheet)
        # Initialize category totals and counters
        totalCategoryAPastDueAmount = 0.0
        totalCategoryAParAmount = 0.0
        categoryACounter = 0
      
        totalCategoryBPastDueAmount = 0.0
        totalCategoryBParAmount = 0.0
        categoryBCounter = 0
      
        totalCategoryCPastDueAmount = 0.0
        totalCategoryCParAmount = 0.0
        categoryCCounter = 0
      
        @data_store.data['records'].each do |rec|
          next unless rec['loan_product']['id'] == @loan_product_id
      
          # Extract fields
          loan_id = rec['id']
          member_name = "#{rec['member']['last_name']}, #{rec['member']['first_name']} #{rec['member']['middle_name']}"
          loan_name = rec['loan_product']['name']
          center = rec['center']['name']
          amount = rec['principal']
          date_released = rec['date_released']
          maturity_date = rec['maturity_date']
          num_installments = Loan.find(loan_id).num_installments
          monthly_interest_rate = Loan.find(loan_id).monthly_interest_rate
          principal_balance = rec['principal_balance']
          interest_balance = rec['interest_balance']
          total_paid = rec['total_paid']
          principal_due = rec['principal_due']  # Assuming you have this field in the record
          totalRR = rec['principal_paid_due'] / principal_due
          # Fetch project type if project_type_id is present
          project_type_id = Loan.find(loan_id).project_type_id
          type_of_livelihood = project_type_id ? ProjectType.find(project_type_id).name : nil

      
          # Limit totalRR to 1 if it exceeds 1
          totalRR = 1 if totalRR > 1
          par = rec['par']
          rr_percentage = (totalRR / 1) * 100
          num_days_par = rec['num_days_par']
      
          # Initialize par amounts for each category
          categoryAParAmount = 0.0
          categoryBParAmount = 0.0
          categoryCParAmount = 0.0
          totalCategoryParAmount = 0.0

      
          # Categorize based on num_days_par
          if par > 0
            if num_days_par >= 1 && num_days_par <= 30
              categoryAParAmount = rec['overall_principal_balance']
              totalCategoryAPastDueAmount += rec['principal_balance']
              totalCategoryAParAmount += categoryAParAmount
              categoryACounter += 1
              totalCategoryParAmount += categoryAParAmount
            elsif num_days_par >= 31 && num_days_par <= 365
              categoryBParAmount = rec['overall_principal_balance']
              totalCategoryBPastDueAmount += rec['principal_balance']
              totalCategoryBParAmount += categoryBParAmount
              categoryBCounter += 1
              totalCategoryParAmount += categoryBParAmount
            elsif num_days_par >= 365
              categoryCParAmount = rec['overall_principal_balance']
              totalCategoryCPastDueAmount += rec['principal_balance']
              totalCategoryCParAmount += categoryCParAmount
              categoryCCounter += 1
              totalCategoryParAmount += categoryCParAmount
            end
          end
      
          # Add row data for each record with the corrected PAR amounts
          sheet.add_row [
            member_name, center, loan_name, amount, date_released, maturity_date, num_installments, monthly_interest_rate,
            principal_balance, interest_balance, totalCategoryParAmount,
            num_days_par, rr_percentage, type_of_livelihood, total_paid
          ]
        end
      end
    end
  end
  