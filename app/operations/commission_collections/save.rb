module CommissionCollections
  class Save
    def initialize(config:)
      @config = config

      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
      @category   = @config[:category]
      @user       = @config[:user]
      @commission_collection = @config[:commission_collection]

      if @category == "referrer"
        @referrers = Referrer.where(category: "REFERRER")
        @members = Member.where("referrer_id IN (?) AND data->>'recognition_date' >= ?", @referrers.pluck(:id), @start_date.to_date)
      elsif @category == "insurance coordinator"
        @coors = Referrer.where(category: "INSURANCE COORDINATOR")
        @members = Member.where("coordinator_id IN (?)", @coors.pluck(:id))
      end

      @member_accounts = MemberAccount.where("account_subtype IN (?) AND member_id IN (?)", ["Life Insurance Fund", "Retirement Fund"], @members.pluck(:id))
      @account_transactions = AccountTransaction.where("Date(account_transactions.updated_at) >= ? AND Date(account_transactions.updated_at) <= ? AND subsidiary_id IN (?)", @start_date, @end_date, @member_accounts.pluck(:id))
      
      @meta = {
        prepared_by: {
          id: @user.id,
          first_name: @user.first_name,
          last_name: @user.last_name,
          full_name: @user.full_name
        }
      }

      @data = {
        total_commission: 0.00,
        totals: [],
        records: []
      }
    end

    def execute!
      # Build data
      if @category == "referrer"
        total_life = 0.00
        total_rf = 0.00

        @referrers.each do |r|
          @members.where("referrer_id = ?", r.id).each do |member|
            life = member.member_accounts.where(account_subtype: "Life Insurance Fund").first
            life_first_transction = @account_transactions.where(subsidiary_id: life.id).order("transacted_at ASC").last

            if life_first_transction.present?
              life_first_payment = life_first_transction.amount.to_f
            else
              life_first_payment = 0.00
            end

            rf = member.member_accounts.where(account_subtype: "Retirement Fund").first
            rf_first_transction =  @account_transactions.where(subsidiary_id: rf.id).order("transacted_at ASC").last
          
            if rf_first_transction.present?
              rf_first_payment = rf_first_transction.amount.to_f
            else
              rf_first_payment = 0.00
            end

            total_life += life_first_payment
            total_rf   += rf_first_payment
          end

          total = total_life + total_rf
          commission = total * 0.03

          @data[:records] << { 
                                referrer: r.full_name,
                                category: @category,
                                total_life_rf: total,
                                commission: commission,
                                start_date: @start_date,
                                end_date: @end_date
                              }

          # if result[:interest] > 0
          #   @data[:records] << result
          #   @data[:total_interest] += result[:interest].to_f.round(2)
          # end
        end
      elsif @category == "insurance coordinator"
        total_life = 0.00
        total_rf = 0.00

        @coors.each do |c|
          @members.where("coordinator_id = ?", c.id).each do |member|
            life = member.member_accounts.where(account_subtype: "Life Insurance Fund").first
            rf = member.member_accounts.where(account_subtype: "Retirement Fund").first

            life_amount = @account_transactions.where("subsidiary_id = ? AND transacted_at >= ? AND transacted_at <= ?", life.id, @start_date, @end_date).sum(:amount).to_f
            rf_amount = @account_transactions.where("subsidiary_id = ? AND transacted_at >= ? AND transacted_at <= ?", rf.id, @start_date, @end_date).sum(:amount).to_f

            total_life += life_amount
            total_rf += rf_amount
          end

          total = total_life + total_rf
          
          if @total > 5000.0
            commission = @total * 0.05
          else
            commission = @total * 0.03
          end

          @data[:records] << { 
                                referrer: c.full_name,
                                category: @category,
                                total_life_rf: total,
                                commission: commission,
                                start_date: @start_date,
                                end_date: @end_date

                              }
        end
      end

      # if Settings.activate_microinsurance
      #   # Build accounting entry
      #   default_branch_id = Settings.try(:defaults).try(:default_branch).try(:id)
      #   @default_branch = Branch.find(default_branch_id)

      #   @data[:accounting_entry]  = ::InsuranceMonthlyClosingCollections::BuildAccountingEntry.new(
      #                                 config: {
      #                                   data: @data,
      #                                   branch: @branch,
      #                                   default_branch: @default_branch,
      #                                   settings: @account_settings,
      #                                   user: @user,
      #                                   collection_date: @closing_date,
      #                                   closing_date: @closing_date
      #                                 }
      #                               ).execute!
      # end

      # Attach meta
      @commission_collection.meta  = @meta

      # Attach data
      @commission_collection.data  = @data


      @commission_collection.status  = "pending"
      @commission_collection.save!

      #ActionCable.server.broadcast 'monthly_closing_collections_channel', { id: @monthly_closing_collection.id, progress: @progress }

      @commission_collection
    end
  end
end
