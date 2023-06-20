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
      elsif @current_transaction[:record_type] == "EQUITY"
        update_equity!
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
        member          = ReadOnlyMember.find(@current_member[:id])
        member_account  = ReadOnlyMemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified deposit amount from #{@original_amount} to #{@current_transaction[:amount]} for SAVINGS account (#{member_account.account_subtype}) of member #{member.full_name}"
      
      elsif @current_transaction[:record_type] == "EQUITY"
        member          = ReadOnlyMember.find(@current_member[:id])
        member_account  = ReadOnlyMemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified equity deposit amount from #{@original_amount} to #{@current_transaction[:amount]} for EQUITY account (#{member_account.account_subtype}) of member #{member.full_name}"
      
      elsif @current_transaction[:record_type] == "INSURANCE"
        member          = ReadOnlyMember.find(@current_member[:id])
        member_account  = ReadOnlyMemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified insurance deposit amount from #{@original_amount} to #{@current_transaction[:amount]} for INSURANCE account (#{member_account.account_subtype}) of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "WP"
        member          = ReadOnlyMember.find(@current_member[:id])
        member_account  = ReadOnlyMemberAccount.find(@current_transaction[:member_account_id])

        content = "#{@user.full_name} modified WP amount from #{@original_amount} to #{@current_transaction[:amount]} for SAVINGS account (#{member_account.account_subtype}) of member #{member.full_name}"
      elsif @current_transaction[:record_type] == "LOAN_PAYMENT"
        member  = ReadOnlyMember.find(@current_member[:id])
        loan    = ReadOnlyLoan.find(@current_transaction[:loan_id])

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
      total_loan_payment = 0.00


      @data[:totals].each_with_index do |t, index|
        if t[:record_type] == "SAVINGS"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "SAVINGS" and t[:key] == rr[:account_subtype]
            }.each do |rr|
              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end

#            r[:records].each_with_index do |rr, j|
#              if rr[:record_type] == "SAVINGS" and t[:key] == rr[:account_subtype]
#                total_collected += rr[:amount].try(:to_f).round(2)
#                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
#              end
#            end
          end
        elsif t[:record_type] == "EQUITY"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "EQUITY" and t[:key] == rr[:account_subtype]
            }.each do |rr|
              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end

#            r[:records].each_with_index do |rr, j|
#              if rr[:record_type] == "INSURANCE" and t[:key] == rr[:account_subtype]
#                total_collected += rr[:amount].try(:to_f).round(2)
#                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
#              end
#            end
          end
        elsif t[:record_type] == "INSURANCE"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "INSURANCE" and t[:key] == rr[:account_subtype]
            }.each do |rr|
              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end

#            r[:records].each_with_index do |rr, j|
#              if rr[:record_type] == "INSURANCE" and t[:key] == rr[:account_subtype]
#                total_collected += rr[:amount].try(:to_f).round(2)
#                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
#              end
#            end
          end
        elsif t[:record_type] == "WP"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "WP"
            }.each do |rr|
              total_collected -= rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)

              total_loan_payment += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end

#            r[:records].each_with_index do |rr, j|
#              if rr[:record_type] == "WP"
#                total_collected -= rr[:amount].try(:to_f).round(2)
#                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
#              end
#            end
          end
        elsif t[:record_type] == "LOAN_PAYMENT"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "LOAN_PAYMENT" and rr[:enabled] == true and t[:key] == rr[:loan_product][:name]
            }.each do |rr|
              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end

#            r[:records].each_with_index do |rr, j|
#              if rr[:record_type] == "LOAN_PAYMENT" and rr[:enabled] == true and t[:key] == rr[:loan_product][:name]
#                total_collected += rr[:amount].try(:to_f).round(2)
#                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
#              end
#            end
          end
        else
          raise "invalid record_type #{t[:record_type]} in totals"
        end
      end

      @data[:total_collected] = total_collected
      # Recompute member totals
      total_collected_for_member  = 0.00

      m_record  = @data[:records].select{ |r|
                    r[:member][:id] == @current_member[:id]
                  }.first

      m_record[:records].each_with_index do |rr, j|
        if rr[:record_type] != "WP"
          total_collected_for_member += rr[:amount].to_f.round(2)
        elsif rr[:record_type] == "WP"
          total_collected_for_member -= rr[:amount].to_f.round(2)
        end
      end
  m_record[:total_collected] = total_collected_for_member

      #recompute for thermal printer
      loan_payment = 0.00
      x_record  = @data[:records].select{ |r|
                    r[:member][:id] == @current_member[:id]
                  }.first

      x_record[:records].each_with_index do |rr, j|
        if rr[:record_type] == "LOAN_PAYMENT"
          loan_payment += rr[:amount].to_f.round(2)
        elsif rr[:record_type] == "LOAN_PAYMENT"
          loan_payment -= rr[:amount].to_f.round(2)
        end
      end

      x_record[:total_loan_payment] = loan_payment

#      @data[:records].each_with_index do |r, i|
#        if r[:member][:id] == @current_member[:id]
#          r[:records].each_with_index do |rr, j|
#            if rr[:record_type] != "WP"
#              total_collected_for_member += rr[:amount].try(:to_f).round(2)
#            elsif rr[:record_type] == "WP"
#              total_collected_for_member -= rr[:amount].try(:to_f).round(2)
#            end
#          end
#
#          @data[:records][i][:total_collected] = total_collected_for_member
#        end
#      end
    end

    def update_savings!
      o = @data[:records].select{ |r|
            r[:member][:id] == @current_member[:id]
          }.first[:records].select{ |rr|
            rr[:record_type] == "SAVINGS" and rr[:member_account_id] == @current_transaction[:member_account_id]
          }.first

      @original_amount  = o[:amount].try(:to_f)
      o[:amount]        = @current_transaction[:amount].to_f.round(2)

#      @data[:records].each_with_index do |r, i|
#        if r[:member][:id] == @current_member[:id]
#          r[:records].each_with_index do |rr, j|
#            if rr[:record_type] == "SAVINGS" and rr[:member_account_id] == @current_transaction[:member_account_id]
#              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
#              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
#            end
#          end
#        end
#      end
    end
    
    def update_equity!
      o = @data[:records].select{ |r|
            r[:member][:id] == @current_member[:id]
          }.first[:records].select{ |rr|
            rr[:record_type] == "EQUITY" and rr[:member_account_id] == @current_transaction[:member_account_id]
          }.first

      @original_amount  = o[:amount].try(:to_f)
      o[:amount]        = @current_transaction[:amount].to_f.round(2)

#      @data[:records].each_with_index do |r, i|
#        if r[:member][:id] == @current_member[:id]
#          r[:records].each_with_index do |rr, j|
#            if rr[:record_type] == "INSURANCE" and rr[:member_account_id] == @current_transaction[:member_account_id]
#              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
#              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
#            end
#          end
#        end
#      end
    end

    def update_insurance!
      o = @data[:records].select{ |r|
            r[:member][:id] == @current_member[:id]
          }.first[:records].select{ |rr|
            rr[:record_type] == "INSURANCE" and rr[:member_account_id] == @current_transaction[:member_account_id]
          }.first

      @original_amount  = o[:amount].try(:to_f)
      o[:amount]        = @current_transaction[:amount].to_f.round(2)

#      @data[:records].each_with_index do |r, i|
#        if r[:member][:id] == @current_member[:id]
#          r[:records].each_with_index do |rr, j|
#            if rr[:record_type] == "INSURANCE" and rr[:member_account_id] == @current_transaction[:member_account_id]
#              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
#              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
#            end
#          end
#        end
#      end
    end

    def update_wp!
      o = @data[:records].select{ |r|
            r[:member][:id] == @current_member[:id]
          }.first[:records].select{ |rr|
            rr[:record_type] == "WP" and rr[:member_account_id] == @current_transaction[:member_account_id]
          }.first

      @original_amount  = o[:amount].try(:to_f)
      o[:amount]        = @current_transaction[:amount].to_f.round(2)

#      @data[:records].each_with_index do |r, i|
#        if r[:member][:id] == @current_member[:id]
#          r[:records].each_with_index do |rr, j|
#            if rr[:record_type] == "WP" and rr[:member_account_id] == @current_transaction[:member_account_id]
#              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
#              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
#            end
#          end
#        end
#      end
    end

    def update_loan_payment!
      o = @data[:records].select{ |r|
            r[:member][:id] == @current_member[:id]
          }.first[:records].select{ |rr|
            rr[:record_type] == "LOAN_PAYMENT" and rr[:loan_id] == @current_transaction[:loan_id]
          }.first

      @original_amount  = o[:amount].try(:to_f)
      o[:amount]        = @current_transaction[:amount].to_f.round(2)

#      @data[:records].each_with_index do |r, i|
#        if r[:member][:id] == @current_member[:id]
#          r[:records].each_with_index do |rr, j|
#            if rr[:record_type] == "LOAN_PAYMENT" and rr[:loan_id] == @current_transaction[:loan_id]
#              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
#              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
#            end
#          end
#        end
#      end
    end
  end
end
