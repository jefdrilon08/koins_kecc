module Loans
  class BuildFormData
    attr_accessor :loan

    def initialize(loan:)
      @loan         = loan
      @member       = @loan.member
      @loan_product = @loan.loan_product
      @branch       = @loan.branch
      @center       = @loan.center

      @accounting_entry = @loan.data.with_indifferent_access[:accounting_entry]

      @data = {
      }
    end

    def compute_maintaining_balance!
      member_accounts     = @member.member_accounts
      settings            = Settings.loan_products.select{ |o| o.loan_product_id == @loan_product.id }.first
      maintaining_balance = member_accounts.sum(:maintaining_balance)

      if settings.maintaining_balance.present?
        member_accounts.where(account_type: settings.maintaining_balance.account_type, account_subtype: settings.maintaining_balance.account_subtype).each do |ma|
          if settings.maintaining_balance.threshold.present? and @loan.principal >= settings.maintaining_balance.threshold.to_f.round(2)
            maintaining_balance += (@loan.principal * settings.maintaining_balance.percentage)
          end
        end
      end

      @data[:maintaining_balance] = maintaining_balance.to_f.round(2)
    end

    def attach_profile_pictures!
      if @member.profile_picture.attached?
        @data[:profile_picture] = Base64.strict_encode64(URI.open(@member.profile_picture.url).read)
      else
        @data[:profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
      end

      if @member.try(:member).present? and @member.member.profile_picture.attached?
        @data[:comaker_profile_picture] = Base64.strict_encode64(URI.open(@member.member.profile_picture.url).read)
      else
        @data[:comaker_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
      end
    end

    def execute!
      @data[:pn_number]       = @loan.pn_number
      @data[:first_name]      = @member.first_name
      @data[:middle_name]     = @member.middle_name
      @data[:last_name]       = @member.last_name
      @data[:full_name]       = @member.full_name
      @data[:address]         = @member.full_address_upcase
      @data[:project_type]    = @loan.project_type.try(:name)
      @data[:principal]       = @loan.principal
      @data[:interest]        = @loan.interest
      @data[:loan_product]    = @loan_product.name
      @data[:interest_rate]   = @loan_product.monthly_interest_rate * 100
      @data[:total_due]       = (@loan.principal + @loan.interest).round(2)
      @data[:term]            = "#{@loan.num_installments} #{@loan.term}"
      @data[:mode_of_payment] = @loan.term
      @data[:weekly_payments] = @loan.amortization_schedule_entries.first.amount_due

      @data[:deductions]  = @accounting_entry[:credit_journal_entries].select{ |o| o[:amount] > 0 }.map{ |o|
                              {
                                nmae: o[:name],
                                amount: o[:amount]
                              }
                            }

      # branched processes
      compute_maintaining_balance!
      attach_profile_pictures!

      @data
    end
  end
end
