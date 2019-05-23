module InsuranceFundTransferCollections
  class ModifyTransactionRecord
    def initialize(config:)
      @config                              = config
      @insurance_fund_transfer_collection  = @config[:insurance_fund_transfer_collection]
      @current_transaction                 = @config[:current_transaction]
      @current_member                      = @config[:current_member]
      @user                                = @config[:user]

      @original_amount                     = false

      @data                                = @insurance_fund_transfer_collection.data.with_indifferent_access
    end

    def execute!
      # Check record_type
      update_fund_transfer!

      # Recompute totals
      recompute_totals!

      # Log change
      log_message = construct_log_message!
      ActivityLog.create!(
        content: log_message,
        activity_type: "modification",
        data: {
          user_id: @user.id,
          fund_transfer_collection_id: @insurance_fund_transfer_collection.id,
          current_transaction: @current_transaction,
          current_member: @current_member
        }
      )

      # Update fund_transfer_collection
      @insurance_fund_transfer_collection.data = @data

      @insurance_fund_transfer_collection.save!

      @insurance_fund_transfer_collection
    end

    private

    def construct_log_message!
      content = ""

      member  = Member.find(@current_member[:id])
      content = "#{@user.full_name} modified insurance fund transfer amount from #{@original_amount} to #{@current_transaction[:amount]} of #{@current_transaction[:account_subtype]}) of member #{member.full_name}"

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

    def update_fund_transfer!
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
