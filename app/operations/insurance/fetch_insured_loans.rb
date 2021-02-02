module Insurance
  class FetchInsuredLoans
    def initialize(start_date:, end_date:, loan_status:, branch_id:)
      @records  = []
      @start_date = start_date.to_date
      @end_date = end_date.to_date
      @branch_id = branch_id
      @loan_status = loan_status
      @loans = []

      if @end_date.present? && @start_date.present? && @loan_status.present? && @branch_id.present?
        if @loan_status == "paid"
          #@entry_level_loans  = Loan.where("maturity_date >= ? AND maturity_date <= ? AND status = ?", @start_date, @end_date, @loan_status).insured
          #Loan.where("extract(month from maturity_date) = ? AND extract(year from maturity_date) = ? AND extract(month from maturity_date) = ? AND extract(year from maturity_date) = ? AND status = ?", @start_date.month, @start_date.year, @end_date.month, @end_date.year, @loan_status).each do |loan|
          Loan.where("status = ? AND maturity_date >= ? AND maturity_date <= ? AND branch_id = ?", @loan_status, @start_date, @end_date, @branch_id).each do |loan|
            accounting_entry = loan.accounting_entry
            if !accounting_entry.nil?
              clip = accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
              if !clip.nil?
                @loans << loan
              end
            end
          end

          @entry_level_loans  = @loans
        elsif @loan_status == "active"
          Loan.where("date_approved >= ? AND date_approved <= ? AND status = ? AND branch_id = ?", @start_date, @end_date, "active", @branch_id).each do |loan|
            accounting_entry = loan.accounting_entry
            if !accounting_entry.nil?
             clip = accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
              if !clip.nil?
                @loans << loan
              end
            end
          end

          @entry_level_loans  = @loans
          #@entry_level_loans  = Loan.where("date_approved > ? AND date_approved < ? AND status = ? AND clip_number != ?", @start_date, @end_date, @loan_status, "").insured
          # @entry_level_loans  = Loan.where("extract(month from date_approved) = ? AND extract(year from date_approved) = ? AND status = ? AND clip_number != ?", @start_date.month, @start_date.year, @end_date.month, @end_date.year, @loan_status, "")
        end
      else
        # @entry_level_loans  = Loan.joins(:member).insured.order("members.last_name ASC")
        Loan.where("date_approved >= ? AND date_approved <= ? AND branch_id = ?", @start_date, @end_date, @branch_id).each do |loan|
          accounting_entry = loan.accounting_entry
          if !accounting_entry.nil?
            clip = accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
            if !clip.nil?
              @loans << loan
            end
          end
        end
        
        @entry_level_loans  = @loans
      end

     # @loan_insurance_accounting_code = AccountingCode.where(id: Settings.loan_insurance_accounting_code_id).first
    end

    def execute!
      @entry_level_loans.each do |loan|
        record = {}
        record[:loan]         = loan
        record[:pn_number]    = loan.pn_number
        record[:member]        = loan.member.full_name
        record[:identification_number] = loan.member.identification_number
        record[:first_name]     = loan.member.first_name
        record[:middle_name]     = loan.member.middle_name
        record[:last_name]     = loan.member.last_name
        record[:loan_product]   = loan.loan_product.to_s
        record[:first_date_of_payment]  = loan.first_date_of_payment.strftime("%B %d, %Y")
        record[:id]  = loan.id
        record[:status] = loan.status
        record[:gender] = loan.member.gender
        record[:date_of_birth]  = loan.member.date_of_birth
        record[:amount] = loan.principal
        record[:num_installments] = loan.try(:num_installments)
        record[:maturity_date]  = loan.original_maturity_date
        record[:date_released] = loan.date_released

       lde = loan.accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
        if lde.present?
            record[:insured_amount] = lde.amount
        end
        
        @records << record
      end
      @records
    end
  end
end