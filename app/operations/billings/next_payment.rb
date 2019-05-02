module Billings
  class NextPayment
    DEFAULT_SAVINGS_SUBTYPE = "K-IMPOK"

    SAVINGS_SUBTYPES = [
      "K-IMPOK",
      "Golden K",
      "Personal Savings Account"
    ]

    INSURANCE_SUBTYPES  = [
      "Life Insurance Fund",
      "Retirement Fund"
    ]

    def initialize(config:)
      @config           = config
      @member           = @config[:member]
      @collection_date  = @config[:collection_date]

      @active_loans = Loan.active.where(member_id: @member.id)

      @members  = Member.active.where(center_id: @member.center.id)
      valid_loan_product_ids  = Loan.active.where(member_id: @members.pluck(:id)).pluck(:loan_product_id).uniq

      @entry_point_loan_products      = LoanProduct.entry_point.where(id: valid_loan_product_ids)
      @non_entry_point_loan_products  = LoanProduct.non_entry_point.where(id: valid_loan_product_ids)

      @settings_savings_deposits  = Settings.try(:defaults).try(:savings_deposits)

      if @settings_savings_deposits.blank?
        raise "Settings for default.savings_deposits not found"
      end

      @data = {
        member: {
          id: @member.id,
          full_name: @member.full_name,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          identification_number: @member.identification_number
        },
        attendance: true,
        total_expected_collections: 0.00,
        total_collected: 0.00,
        records: []
      }
    end

    def execute!
      # Entry point loans
      @entry_point_loan_products.each_with_index do |loan_product, i|
        @data[:records] << build_loan_payment(loan_product)
      end

      # Non-entry point loans
      @non_entry_point_loan_products.each do |loan_product|
        @data[:records] << build_loan_payment(loan_product)
      end

      # Savings deposits
      SAVINGS_SUBTYPES.each do |savings_subtype|
        @data[:records] << build_savings_deposit(savings_subtype)
      end

      # Insurance deposits
      INSURANCE_SUBTYPES.each do |insurance_subtype|
        @data[:records] << build_insurance_deposit(insurance_subtype)
      end

      # Withdraw payments
      @data[:records] << build_withdraw_payment

      # Totals
      @data[:records].each do |o|
        @data[:total_expected_collections] += o[:amount]

        if o[:record_type] != "WP"
          @data[:total_collected] += o[:amount]
        end
      end

      @data
    end

    private

    def build_withdraw_payment
      data  = {
        record_type: "WP",
        amount: 0.00,
        enabled: false,
        member_account_id: false
      }

      member_account  = MemberAccount.savings.where(
                          member_id: @member.id, 
                          account_subtype: DEFAULT_SAVINGS_SUBTYPE
                        ).first

      if member_account.present?
        data[:enabled]            = true
        data[:member_account_id]  = member_account.id
      end

      data
    end

    def build_insurance_deposit(insurance_subtype)
      data  = {
        record_type: "INSURANCE",
        account_subtype: insurance_subtype,
        amount: 0.00,
        enabled: false,
        member_account_id: false
      }

      member_account  = MemberAccount.insurance.where(
                          member_id: @member.id, 
                          account_subtype: insurance_subtype
                        ).first
     
      if member_account.present?
        data[:enabled]            = true
        data[:member_account_id]  = member_account.id

        defaults  = Settings.try(:defaults).try(:insurance_deposits)

        if defaults.present? and @member.loans.size <= 1
          defaults.each do |o|
            if o.account_subtype == insurance_subtype
              data[:amount] = o.amount
            end
          end
        end
      end

      data
    end

    def build_savings_deposit(savings_subtype)
      data  = {
        record_type: "SAVINGS",
        account_subtype: savings_subtype,
        amount: 0.00,
        enabled: false,
        member_account_id: false
      }

      member_account  = MemberAccount.savings.where(member_id: @member.id, account_subtype: savings_subtype).first

      if member_account.present?
        data[:enabled]            = true
        data[:member_account_id]  = member_account.id
      end

      # Default amount
      loan_amount = @member.loans.active.sum(:principal)
      @settings_savings_deposits.each do |o|
        if o.account_subtype == savings_subtype
          o.regular_loan_deposits.each do |rs|
            if loan_amount >= rs.min_amount and loan_amount < rs.max_amount
              data[:amount] = rs.deposit_amount
            end
          end
        end
      end

      data
    end

    def build_loan_payment(loan_product)
      data  = {
        record_type: "LOAN_PAYMENT",
        loan_product: {
          id: loan_product.id,
          name: loan_product.to_s,
        },
        amount: 0.00,
        enabled: false,
        loan_id: false
      }

      loan  = @active_loans.where(loan_product_id: loan_product.id).first

      if loan.present?
        data[:enabled]  = true
        data[:loan_id]  = loan.id
        data[:amount]   = ::Billings::NextLoanPaymentAmount.new(
                            config: {
                              loan: loan,
                              current_date: @collection_date
                            }
                          ).execute!
      end

      data
    end
  end
end
