module DepositCollections
  class ModifyTransactionRecord
    def initialize(config:)
      @config               = config
      @deposit_collection   = @config[:deposit_collection]
      @current_transaction  = @config[:current_transaction]
      @current_member       = @config[:current_member]
      @user                 = @config[:user]

      @original_amount  = false

      @data = @deposit_collection.data.with_indifferent_access
    end

    def execute!
      # Check record_type
      update_deposit!

      # Recompute totals
      recompute_totals!

      # Log change
      log_message = construct_log_message!
      ActivityLog.create!(
        content: log_message,
        activity_type: "modification",
        data: {
          user_id: @user.id,
          deposit_collection_id: @deposit_collection.id,
          current_transaction: @current_transaction,
          current_member: @current_member
        }
      )
      

      # Update accounting_entry
      @data[:accounting_entry]  = ::DepositCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @deposit_collection.branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      # Update deposit_collection
      @deposit_collection.data = @data

      @deposit_collection.save!

      @deposit_collection
    end

    private

    def construct_log_message!
      content = ""

      member          = Member.find(@current_member[:id])

      content = "#{@user.full_name} modified deposit amount from #{@original_amount} to #{@current_transaction[:amount]} of #{@current_transaction[:account_subtype]}) of member #{member.full_name}"

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
              if rr[:record_type] == "SAVINGS" and t[:key] == rr[:account_subtype]
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
        elsif t[:record_type] == "EQUITY" 
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "EQUITY" and t[:key] == rr[:account_subtype]
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
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

    def update_deposit!
      @data[:records].each_with_index do |r, i|
        if r[:member][:id] == @current_member[:id]
          r[:records].each_with_index do |rr, j|
            if rr[:record_type] == "SAVINGS" and rr[:account_subtype] == @current_transaction[:account_subtype]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            elsif rr[:record_type] == "INSURANCE" and rr[:account_subtype] == @current_transaction[:account_subtype]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            elsif rr[:record_type] == "EQUITY" and rr[:account_subtype] == @current_transaction[:account_subtype]
              @original_amount  = @data[:records][i][:records][j][:amount].try(:to_f)
              @data[:records][i][:records][j][:amount] = @current_transaction[:amount].try(:to_f).round(2)
            end
          end
        end
      end
    end
  end
end
