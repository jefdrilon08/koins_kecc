module Billings
  class ModifyTransactionRecord
    def initialize(config:)
      @config               = config
      @billing              = @config[:billing]
      @current_transaction  = @config[:current_transaction]
      @current_member       = @config[:current_member]
      @user                 = @config[:user]

      @original_amount  = false

      @data = @billing.data.with_indifferent_access
    end

    def execute!
      # Check record_type
      if @current_transaction[:record_type] == "SAVINGS"
        update_savings!
      elsif @current_transaction[:record_type] == "INSURANCE"
        update_insurance!
      elsif @current_transaction[:record_type] == "WP"
        update_wp!
      elsif @current_transaction[:record_type] == "LOAN_PAYMENT"
        update_loan_payment!
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
          billing_id: @billing.id,
          current_transaction: @current_transaction,
          current_member: @current_member
        }
      )
      

      # Update accounting_entry
      @data[:accounting_entry]  = ::Billings::BuildAccountingEntry.new(
                                    config: {
                                      branch: @billing.branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      # Update billing
      @billing.data = @data

      @billing.save!

      @billing
    end

    private

    def construct_log_message!
      content = ""

      if @current_transaction[:record_type] == "SAVINGS"
        member          = Member.find(@current_member[:id])
        member_account  = MemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified deposit amount from #{@original_amount} to #{@current_transaction[:amount]} for SAVINGS account (#{member_account.account_subtype}) of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "INSURANCE"
        member          = Member.find(@current_member[:id])
        member_account  = MemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified insurance deposit amount from #{@original_amount} to #{@current_transaction[:amount]} for INSURANCE account (#{member_account.account_subtype}) of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "WP"
        member          = Member.find(@current_member[:id])
        member_account  = MemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified WP amount from #{@original_amount} to #{@current_transaction[:amount]} for SAVINGS account (#{member_account.account_subtype}) of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "LOAN_PAYMENT"
        member  = Member.find(@current_member[:id])
        loan    = Loan.find(@current_transaction[:loan_id])

        content = "#{@user.full_name} modified loan_payment amount from #{@original_amount} to #{@current_transaction[:amount]} for loan (#{loan.pn_number}) of member #{member.full_name}"
      else
        raise "invalid record_type #{@current_transaction[:record_type]} in construct_log_message!"
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
        if t[:record_type] == "SAVINGS"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              #if rr[:record_type] == "SAVINGS" and t[:key] == MemberAccount.savings.where(id: rr[:member_account_id]).first.account_subtype
              if rr[:record_type] == "SAVINGS" and t[:key] == rr[:account_subtype]
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "INSURANCE"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              #if rr[:record_type] == "INSURANCE" and t[:key] == MemberAccount.insurance.where(id: rr[:member_account_id]).first.account_subtype
              if rr[:record_type] == "INSURANCE" and t[:key] == rr[:account_subtype]
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "WP"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "WP"
                #total_collected += rr[:amount].try(:to_f).round(3)
                total_collected -= rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "LOAN_PAYMENT"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              #if rr[:record_type] == "LOAN_PAYMENT" and rr[:enabled] == true and Loan.find(rr[:loan_id]).loan_product.name == t[:key]
              if rr[:record_type] == "LOAN_PAYMENT" and rr[:enabled] == true and t[:key] == rr[:loan_product][:name]
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
            if rr[:record_type] != "WP"
              total_collected_for_member += rr[:amount].try(:to_f).round(2)
            elsif rr[:record_type] == "WP"
              total_collected_for_member -= rr[:amount].try(:to_f).round(2)
            end
          end

          @data[:records][i][:total_collected] = total_collected_for_member
        end
      end
    end

    def update_savings!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "SAVINGS" and rr[:member_account_id] == @current_transaction[:member_account_id]
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
            if rr[:record_type] == "INSURANCE" and rr[:member_account_id] == @current_transaction[:member_account_id]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end

    def update_wp!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "WP" and rr[:member_account_id] == @current_transaction[:member_account_id]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end

    def update_loan_payment!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "LOAN_PAYMENT" and rr[:loan_id] == @current_transaction[:loan_id]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end
  end
end
