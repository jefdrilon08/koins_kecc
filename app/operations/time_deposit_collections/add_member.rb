module TimeDepositCollections
  class AddMember
    def initialize(config:)
      @config                   = config
      @time_deposit_collection  = @config[:time_deposit_collection]
      @member                   = @config[:member]
      @amount                   = @config[:amount].to_f.round(2)
      @lock_in_period           = @config[:lock_in_period].to_i
      @user                     = @config[:user]

      @data = @time_deposit_collection.data.with_indifferent_access

      @settings = Settings.time_deposit

      @account_subtype  = @settings.account_subtype
      @lock_in_periods  = @settings.lock_in_periods
    end

    def execute!
      # Build member object
      @member_object  = {
        id: @member.id,
        full_name: @member.full_name,
        first_name: @member.first_name,
        middle_name: @member.middle_name,
        last_name: @member.last_name,
        identification_number: @member.identification_number
      }

      # Build member records
      @records  = []

      member_account  = MemberAccount.where(
                          member_id: @member.id,
                          account_type: "SAVINGS",
                          account_subtype: @account_subtype
                        ).first

      if member_account.blank?
        raise "No time deposit account for member #{@member.id}"
      end

      lock_in_period  = @lock_in_periods.select{ |o|
                          o.num_days.to_i == @lock_in_period
                        }.first

      @records << {
        amount: @amount,
        enabled: true,
        member_id: @member.id,
        record_type: "SAVINGS",
        account_subtype: @account_subtype,
        member_account_id: member_account.try(:id),
        lock_in_period: {
          num_days: @lock_in_period,
          num_months: lock_in_period.num_months,
          interest_rate: lock_in_period.interest_rate,
          expected_interest: (lock_in_period.num_months * lock_in_period.interest_rate * @amount).round(2)
        }
      }

      @data[:records] << {
        member: @member_object,
        records: @records,
        total_collected: @amount
      }

      # Recompute totals
      recompute_totals!

      # Log change
      log_message = construct_log_message!
      ActivityLog.create!(
        content: log_message,
        activity_type: "modification",
        data: {
          user_id: @user.id,
          time_deposit_collection_id: @time_deposit_collection.id
        }
      )

      # Update accounting_entry
      @data[:accounting_entry]  = ::TimeDepositCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @time_deposit_collection.branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @time_deposit_collection.update!(
        data: @data
      )

      @time_deposit_collection
    end
    
    private

    def construct_log_message!
      content = ""

      content = "#{@user.full_name} added time deposit for member #{@member.full_name} with amount #{@amount} and lock in period of #{@lock_in_period} days"

      content
    end

    def recompute_totals!
      # Reset
      @data[:totals].each_with_index do |t, index|
        @data[:totals][index][:amount]  = 0.00
      end

      # Recompute
      total_collected = 0.00

      @data[:totals].each_with_index do |t, index|
        @data[:records].each_with_index do |r, i|
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "SAVINGS" and t[:key] == rr[:account_subtype]
              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end
          end
        end
      end

      @data[:total_collected] = total_collected

      # Recompute member totals
      total_collected_for_member  = 0.00
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @member.id
          r[:records].each_with_index do |rr, j|
            total_collected_for_member += rr[:amount].try(:to_f).round(2)
          end

          @data[:records][i][:total_collected] = total_collected_for_member
        end
      end
    end
  end
end
