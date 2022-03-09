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
      @account_transactions = AccountTransaction.where("Date(account_transactions.updated_at) >= ? AND Date(account_transactions.updated_at) <= ? AND subsidiary_id IN (?) AND data->>'is_interest' = ?", @start_date, @end_date, @member_accounts.pluck(:id), "false")
      
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
            life_first_transaction = @account_transactions.where("subsidiary_id = ? AND transaction_type = ?", life.id, "deposit").order("transacted_at ASC").last

            if life_first_transaction.present?
              life_first_payment = life_first_transaction.amount.to_f
            else
              life_first_payment = 0.00
            end

            rf = member.member_accounts.where(account_subtype: "Retirement Fund").first
            rf_first_transaction =  @account_transactions.where("subsidiary_id = ? AND transaction_type = ?", rf.id, "deposit").order("transacted_at ASC").last
          
            if rf_first_transaction.present?
              rf_first_payment = rf_first_transaction.amount.to_f
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

          @data[:total_commission] += commission
        end
      elsif @category == "insurance coordinator"
        @coors.each do |c|
          total_life = 0.00
          total_rf = 0.00

          @members.where("coordinator_id = ?", c.id).each do |member|
            life = member.member_accounts.where(account_subtype: "Life Insurance Fund").first
            # @account_transactions.where("subsidiary_id = ? AND transacted_at >= ? AND transacted_at <= ?", life.id, @start_date, @end_date).each do |lt|
            #   if lt.transaction_type == "withdraw"
            #     life_amount = ((life_amount < 0 ? 0 : life_amount) - (lt.amount < 0 ? 0 : lt.amount))
            #   elsif lt.transaction_type == "deposit"
            #     life_amount = (life_amount + lt.amount).abs
            #   end
            # end

            rf = member.member_accounts.where(account_subtype: "Retirement Fund").first
            # @account_transactions.where("subsidiary_id = ? AND transacted_at >= ? AND transacted_at <= ?", rf.id, @start_date, @end_date).each do |rt|
            #   if rt.transaction_type == "withdraw"
            #     rf_amount = ((rf_amount < 0 ? 0 : rf_amount) - (rt.amount < 0 ? 0 : rt.amount))
            #   elsif rt.transaction_type == "deposit"
            #     rf_amount = (rf_amount + rt.amount).abs
            #   end
            # end

            life_amount_deposit = @account_transactions.where("subsidiary_id = ? AND transacted_at >= ? AND transacted_at <= ? AND transaction_type = ?", life.id, @start_date, @end_date, "deposit").sum(:amount).to_f
            life_amount_withdraw = @account_transactions.where("subsidiary_id = ? AND transacted_at >= ? AND transacted_at <= ? AND transaction_type = ?", life.id, @start_date, @end_date, "withdraw").sum(:amount).to_f
            life_amount = (life_amount_deposit - life_amount_withdraw).to_f

            rf_amount_deposit = @account_transactions.where("subsidiary_id = ? AND transacted_at >= ? AND transacted_at <= ? AND transaction_type = ?", rf.id, @start_date, @end_date, "deposit").sum(:amount).to_f
            rf_amount_withdraw = @account_transactions.where("subsidiary_id = ? AND transacted_at >= ? AND transacted_at <= ? AND transaction_type = ?", rf.id, @start_date, @end_date, "withdraw").sum(:amount).to_f
            rf_amount = (rf_amount_deposit - rf_amount_withdraw).to_f

            total_life = total_life + life_amount
            total_rf = total_rf + rf_amount
          end

          total = total_life + total_rf
          
          if !total.nil?
            if total > 5000.0
              commission = total * 0.05
            else
              commission = total * 0.03
            end
          else
            commission = 0.00
          end

          if commission > 0.0
            @data[:records] << { 
                                  referrer: c.full_name,
                                  category: @category,
                                  total_life_rf: total,
                                  commission: commission,
                                  start_date: @start_date,
                                  end_date: @end_date

                                }
          end

          @data[:total_commission] += commission
        end
      end

      if Settings.activate_microinsurance
        # Build accounting entry
        default_branch_id = Settings.try(:defaults).try(:default_branch).try(:id)
        @default_branch = Branch.find(default_branch_id)

        @data[:accounting_entry]  = ::CommissionCollections::BuildAccountingEntry.new(
                                      config: {
                                        data: @data,
                                        default_branch: @default_branch,
                                        user: @user,
                                        start_date: @start_date,
                                        end_date: @end_date,
                                        date_prepared: @commission_collection.date_prepared,
                                        category: @category
                                      }
                                    ).execute!
      end

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
