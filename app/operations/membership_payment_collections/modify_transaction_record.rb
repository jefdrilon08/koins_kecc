module MembershipPaymentCollections
  class ModifyTransactionRecord
    def initialize(config:)
      @config               = config
      @membership_payment_collection              = @config[:membership_payment_collection]
      @current_transaction  = @config[:current_transaction]
      @current_member       = @config[:current_member]
      @user                 = @config[:user]

      @original_amount  = false

      @data = @membership_payment_collection.data.with_indifferent_access
    end

    def execute!
      # Check record_type
      if @current_transaction[:record_type] == "ID"
        update_id!
      elsif @current_transaction[:record_type] == "MEMBERSHIP_PAYMENT"
        update_membership_payment!
      elsif @current_transaction[:record_type] == "EQUITY"
        update_equity!
      elsif @current_transaction[:record_type] == "INSURANCE"
        update_insurance!
      elsif @current_transaction[:record_type] == "SAVINGS"
        update_savings!
      else
        raise "invalid record_type #{@current_transaction[:record_type]}"
      end

      # Recompute totals
      recompute_totals!

      # Log change
      log_message = construct_log_message!
      ActivityLog.create!(
        content: log_message,
        activity_type: "modification",
        data: {
          user_id: @user.id,
          membership_payment_collection_id: @membership_payment_collection.id,
          current_transaction: @current_transaction,
          current_member: @current_member
        }
      )
      

      # Update accounting_entry
      @data[:accounting_entry]  = ::MembershipPaymentCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @membership_payment_collection.branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      # Update membership_payment_collection
      @membership_payment_collection.data = @data

      @membership_payment_collection.save!

      @membership_payment_collection
    end

    private

    def construct_log_message!
      content = ""

      if @current_transaction[:record_type] == "ID"
        member          = Member.find(@current_member[:id])

        content = "#{@user.full_name} modified ID amount from #{@original_amount} to #{@current_transaction[:amount]} of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "MEMBERSHIP_PAYMENT"
        member          = Member.find(@current_member[:id])

        content = "#{@user.full_name} modified membership_payment amount from #{@original_amount} to #{@current_transaction[:amount]} for membership account (#{@current_transaction[:membership_type]} - #{@current_transaction[:account_subtype]}) of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "EQUITY"
        member          = Member.find(@current_member[:id])
        member_account  = MemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified EQUITY amount from #{@original_amount} to #{@current_transaction[:amount]} for EQUITY account (#{member_account.account_subtype}) of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "INSURANCE"
        member  = Member.find(@current_member[:id])

        content = "#{@user.full_name} modified INSURANCE amount from #{@original_amount} to #{@current_transaction[:amount]} for insurance account (#{@current_transaction[:membership_type]} - #{@current_transaction[:account_subtype]}) of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "SAVINGS"
        member          = Member.find(@current_member[:id])
        member_account  = MemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified SAVINGS amount from #{@original_amount} to #{@current_transaction[:amount]} for savings account (#{@current_transaction[:membership_type]} - #{@current_transaction[:account_subtype]}) of member #{member.full_name}"
      else
        raise "invalid record_type #{@current_transaction[:record_type]}:#{@current_transaction[:enabled]} in construct_log_message!"
      end

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
        if t[:record_type] == "ID"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "ID"
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "MEMBERSHIP_PAYMENT"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "MEMBERSHIP_PAYMENT" and t[:key] == rr[:account_subtype]
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "EQUITY"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "EQUITY"
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "INSURANCE"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "INSURANCE" and t[:key] == rr[:account_subtype]
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "SAVINGS"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "SAVINGS" and t[:key] == rr[:account_subtype]
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        else
          raise "invalid record_type #{t[:record_type]} in totals"
        end
      end

      @data[:total_collected] = total_collected

      # Recompute member totals
      total_collected_for_member  = 0.00
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            total_collected_for_member += rr[:amount].try(:to_f).round(2)
          end

          @data[:records][i][:total_collected] = total_collected_for_member
        end
      end
    end

    def update_id!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "ID"
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end

    def update_membership_payment!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "MEMBERSHIP_PAYMENT" and rr[:account_subtype] == @current_transaction[:account_subtype]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end

    def update_equity!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "EQUITY"
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end

    def update_insurance!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "INSURANCE" and rr[:account_subtype] == @current_transaction[:account_subtype]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end

    def update_savings!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "SAVINGS" and rr[:account_subtype] == @current_transaction[:account_subtype]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end
  end
end
