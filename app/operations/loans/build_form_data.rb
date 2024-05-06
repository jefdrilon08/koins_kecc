module Loans
  class BuildFormData
    include ActionView::Helpers::NumberHelper

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

      if settings.present? and settings.maintaining_balance.present?
        member_accounts.where(account_type: settings.maintaining_balance.account_type, account_subtype: settings.maintaining_balance.account_subtype).each do |ma|
          if settings.maintaining_balance.threshold.present? and @loan.principal >= settings.maintaining_balance.threshold.to_f.round(2)
            maintaining_balance += (@loan.principal * settings.maintaining_balance.percentage)
          end
        end
      end

      @data[:maintaining_balance] = number_to_currency(maintaining_balance.to_f.round(2), unit: 'Php')
    end

    def attach_profile_pictures!
      if @member.profile_picture.attached?
        begin
          profile_picture = URI.open(@member.profile_picture.url)

          if profile_picture.present?
            @data[:profile_picture] = Base64.strict_encode64(profile_picture.read)
          else
            Rails.logger.info("Missing profile picture for member #{@member.id}: #{@member.profile_picture.url}")
            @data[:profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
          end
        rescue
          Rails.logger.info("Missing profile picture for member #{@member.id}: #{@member.profile_picture.url}")
          @data[:profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
        end
      else
        @data[:profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
      end

      if @loan.data["co_maker_one"].present? and @loan.data["co_maker_one"]["id"].present?
        @co_maker_object = Member.find(@loan.data["co_maker_one"]["id"])
      end

      if @co_maker_object.present? and @co_maker_object.profile_picture.attached?
        begin
          profile_picture = URI.open(@co_maker_object.profile_picture.url)

          if profile_picture.present?
            @data[:comaker_profile_picture] = Base64.strict_encode64(profile_picture.read)
          else
            Rails.logger.info("Missing profile picture for co maker member #{@co_maker_object.id}: #{@co_maker_object.profile_picture.url}")
            @data[:comaker_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
          end
        rescue
          Rails.logger.info("Missing profile picture for co maker member #{@co_maker_object.id}: #{@co_maker_object.profile_picture.url}")
          @data[:comaker_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
        end
      else
        @data[:comaker_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
      end

      if @loan.co_maker_relative_profile_picture.attached?
        begin
          profile_picture = URI.open(@loan.co_maker_relative_profile_picture.url)

          if profile_picture.present?
            @data[:comaker_relative_profile_picture] = Base64.strict_encode64(URI.open(profile_picture).read)
          else
            Rails.logger.info("Missing profile picture for comaker relative #{@loan.co_maker_relative_profile_picture.url}")
            @data[:comaker_relative_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
          end
        rescue
          Rails.logger.info("Missing profile picture for comaker relative #{@loan.co_maker_relative_profile_picture.url}")
          @data[:comaker_relative_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
        end
      else
        @data[:comaker_relative_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
      end

      if @loan.co_maker_non_relative_profile_picture.attached?
        begin
          profile_picture = URI.open(@loan.co_maker_non_relative_profile_picture.url)

          if profile_picture.present?
            @data[:comaker_non_relative_profile_picture] = Base64.strict_encode64(URI.open(profile_picture).read)
          else
            Rails.logger.info("Missing profile picture for comaker non relative #{@loan.co_maker_non_relative_profile_picture.url}")
            @data[:comaker_non_relative_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
          end
        rescue
          Rails.logger.info("Missing profile picture for comaker non relative #{@loan.co_maker_non_relative_profile_picture.url}")
          @data[:comaker_non_relative_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
        end
      else
        @data[:comaker_non_relative_profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
      end
    end

    def execute!
      @data[:pn_number]       = @loan.pn_number
      @data[:branch]          = @branch.name
      @data[:center]          = @center.name
      @data[:id_number]       = @member.identification_number
      @data[:first_name]      = @member.first_name
      @data[:middle_name]     = @member.middle_name
      @data[:last_name]       = @member.last_name
      @data[:full_name]       = @member.full_name
      @data[:address]         = @member.full_address_upcase
      @data[:spouse]          = @member.spouse.upcase
      @data[:project_type]    = @loan.project_type.try(:name)
    
      #@data[:loan_product_tagging_id]    = @loan.loan_product_tagging_id
      
      @data[:principal]       = number_to_currency(@loan.principal, unit: 'Php')
      @data[:interest]        = number_to_currency(@loan.interest, unit: 'Php')
      @data[:co_maker_one]    = @loan.co_maker_one
      @data[:co_maker_two]    = @loan.co_maker_two
      @data[:loan_product]    = @loan_product.name
      @data[:category]        = @loan_product.loan_product_category.try(:to_s)
      @data[:interest_rate]   = @loan_product.monthly_interest_rate * 100
      @data[:total_due]       = number_to_currency((@loan.principal + @loan.interest).round(2), unit: 'Php')
      @data[:term]            = "#{@loan.num_installments} #{@loan.term_interval}"
      @data[:mode_of_payment] = @loan.term
      @data[:weekly_payments] = number_to_currency(@loan.amortization_schedule_entries.first.amount_due, unit: 'Php')
      @data[:co_maker_spouse] = @loan.try(:member).try(:spouse)
      @data[:logo]            = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/logo_titled.png").read)

      loan_product_settings = Settings.loan_products.select{ |o| o.loan_product_id == @loan_product.id }.first

      #@data[:loan_product_maintaining_balance_percentage] = loan_product_settings.maintaining_balance.percentage * 100
      @data[:loan_product_maintaining_balance_percentage] = loan_product_settings.try(:maintaining_balance).try(:percentage) || 0 * 100

      cib_id = Settings.branch_accounting_codes.select{ |o| o.branch_id == @branch.id }.first.try(:cash_in_bank_accounting_code_id)

      if loan_product_settings.present? and loan_product_settings.amount_released_accounting_code_id.present?
        cib_id = loan_product_settings.amount_released_accounting_code_id
      end

      @data[:amount_released] = @loan.principal

      if @accounting_entry[:credit_journal_entries].present? and @accounting_entry[:credit_journal_entries].any?
        @data[:deductions]  = @accounting_entry[:credit_journal_entries].select{ |o| o[:amount].to_f > 0 and o[:accounting_code_id] != cib_id }.map{ |o|
                                {
                                  name: o[:name],
                                  amount: number_to_currency(o[:amount], unit: 'Php')
                                }
                              }

        @accounting_entry[:credit_journal_entries].each do |o|
          if o[:accounting_code_id] != cib_id
            @data[:amount_released] -= o[:amount].to_f.round(2)
          end
        end
      else
        @data[:deductions]  = []
      end

      @data[:amount_released] = number_to_currency(@data[:amount_released], unit: 'Php')

      # branched processes
      compute_maintaining_balance!
      attach_profile_pictures!

      @data
    end
  end
end
