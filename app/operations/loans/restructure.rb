module Loans
  class Restructure
    def initialize(user:, co_maker:, co_maker_member:, pn_number:, clip_number:, date_prepared:, num_installments:, term:, member:, active_loans:, loan_product:, date_released: nil, beneficiary_first_name:, beneficiary_middle_name:, beneficiary_last_name:, beneficiary_date_of_birth:, beneficiary_relationship:)
      @user             = user
      @co_maker         = co_maker
      @co_maker_member  = co_maker_member
      @pn_number        = pn_number
      @clip_number      = clip_number
      @member           = member
      @date_prepared    = date_prepared
      @num_installments = num_installments
      @term             = term
      @branch           = @member.branch
      @center           = @member.center
      @active_loans     = active_loans
      @loan_product     = loan_product

      # beneficiary information
      @beneficiary_first_name     = beneficiary_first_name
      @beneficiary_middle_name    = beneficiary_middle_name
      @beneficiary_last_name      = beneficiary_last_name
      @beneficiary_date_of_birth  = beneficiary_date_of_birth
      @beneficiary_relationship   = beneficiary_relationship

      @loan         = Loan.new(is_restructured: true)
      @member_data  = @member.data.with_indifferent_access

      # Settings
      @settings_loan_products = Settings.loan_products

      if @settings_loan_products.blank?
        raise "settings_loan_products not found"
      end

      # Actual loan product settings
      @settings = @settings_loan_products.select{ |s| 
                    s.loan_product_id == @loan_product.id and s.for_restructuring == true 
                  }.first

      if @settings.blank?
        raise "No settings found for loan_product #{@loan_product.id}"
      end

      # Primary for restructuring (initial deductions)
      @settings_primary = @settings.deductions.select{ |s| s.restructuring_primary == true }

      if @settings_primary.blank?
        raise "No primary restructuring settings found for loan_product #{@loan_product.id}"
      end

      # Secondary for application on top of primary
      @settings_secondary = @settings.deductions.select{ |s| s.restructuring_secondary == true }

      if @settings_secondary.blank?
        raise "No secondary restructuring settings found for loan_product #{@loan_product.id}"
      end

      # Offset for round off (only one)
      @settings_offset  = @settings.deductions.select{ |s| s.restructuring_offset == true }.first
      
      if @settings_offset.blank?
        raise "No offset settings found for loan_product #{@loan_product.id}"
      end

      # Set principal to be sum of active_loans balances
      #@principal  = (@active_loans.sum(:principal_balance) + @active_loans.sum(:interest_balance)).round(2)
      @principal  = (@active_loans.sum(:principal_balance)).round(2)
    end

    def execute!
      @loan.pn_number         = @pn_number
      @loan.date_prepared     = @date_prepared
      @loan.date_released     = @date_released
      @loan.principal         = @principal
      @loan.num_installments  = @num_installments
      @loan.term              = @term

      @loan.data = {
        clip_number: @clip_number,
        clip_beneficiary: {
          first_name: @beneficiary_first_name,
          middle_name: @beneficiary_middle_name,
          last_name: @beneficiary_last_name,
          date_of_birth: @beneficiary_date_of_birth,
          relationship: @beneficiary_relationship
        },
        co_maker_one: {
          value: @co_maker_member.try(:id),
          label: @co_maker_member.try(:full_name),
          id: @co_maker_member.try(:id),
          first_name: @co_maker_member.try(:first_name),
          middle_name: @co_maker_member.try(:middle_name),
          last_name: @co_maker_member.try(:last_name)
        },
        co_maker_two: @co_maker,
        voucher: {
          or_number: "",
          bank_check_number: "",
          check_number: "",
          date_of_check: ""
        },
        business_permit_available: "false",
        advance_insurance_available: false
      }


      # Setup loan cycle
      @loan_cycles            = @member_data[:loan_cycles]

      if @loan_cycles.blank? || @loan_cycles.size == 0
        @loan.cycle = 1
      else
        @loan_cycles.each_with_index do |c, i|
          if c[:loan_product_id] == @loan_product.id
            @loan.cycle = c[:cycle] + 1
          end
        end
      end

      @loan.member                = @member
      @loan.branch                = @branch
      @loan.center                = @center
      @loan.loan_product          = @loan_product
      @loan.monthly_interest_rate = @loan_product.monthly_interest_rate

      if @settings.use_term_interest.present?
        @settings.use_term_interest.each do |t|
          if t.term == @loan.term and @loan.num_installments > t.min_num_installments and @loan.num_installments <= t.max_num_installments
            @loan.monthly_interest_rate = t.monthly_interest_rate
          end
        end
      end

      ###########################################################################
      # Build accounting entry data
      ###########################################################################
      particular  = "To record #{@loan_product.name} of #{@member.full_name} CLIP ##{@clip_number}"
      @book       = "JVB"

      ae_cmd  = ::Loans::BuildRestructuredAccountingEntry.new(
                  config: {
                    member: @member,
                    loan_product: @loan_product,
                    amount: @loan.principal,
                    term: @loan.term,
                    num_installments: @loan.num_installments,
                    particular: particular,
                    book: @book,
                    loan: @loan,
                    active_loans: @active_loans
                  }
                )

      accounting_entry_data = ae_cmd.execute!
      ###########################################################################

      # Set loan principal according to debit entry
      #@loan.principal = ae_cmd.total_debit
      #@loan.principal = ae_cmd.total_debit

      params  = {
        principal: @loan.principal,
        annual_interest_rate: (@loan.monthly_interest_rate * 12),
        num_installments: @num_installments,
        term: @term
      }

      result  = ::Finance::Amortize.new(
                  params: params
               ).execute!

      @loan.principal_balance = @loan.principal
      @loan.interest_balance  = result[:interest]
      @loan.interest          = result[:interest]
      @loan.principal_paid    = 0.00
      @loan.interest_paid     = 0.00

      if !@loan.new_record?
        @loan.amortization_schedule_entries.delete_all
      end

      result[:schedule].each do |o|
        principal   = o[:principal].to_f.round(2)
        interest    = o[:interest].to_f.round(2)
        amount_due  = (principal + interest).round(2)

        @loan.amortization_schedule_entries.build(
          principal: principal,
          interest: interest,
          principal_balance: principal,
          interest_balance: interest,
          principal_paid: 0.00,
          interest_paid: 0.00,
          amount_due: amount_due
        )
      end

      @loan.data[:accounting_entry] = accounting_entry_data

      # Save information of restructured loans
      @loan.data[:restructured_loans] = @active_loans.map{ |loan|
        {
          id: loan.id,
          pn_number: loan.pn_number,
          principal_balance: loan.principal_balance,
          interest_balance: loan.interest_balance,
          total_balance: (loan.principal_balance + loan.interest_balance).to_f.round(2),
          loan_product: {
            id: loan.loan_product_id,
            name: loan.loan_product.name
          }
        }
      }

      @active_loans.each do |o|
        o.update!(status: "processing")
      end

      @loan.save!

      @loan
    end
  end
end
