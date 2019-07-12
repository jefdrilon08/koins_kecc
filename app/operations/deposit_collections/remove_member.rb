module DepositCollections
  class RemoveMember
    def initialize(config:)
      @config                         = config
      @deposit_collection  = @config[:deposit_collection]
      @member                         = @config[:member]
      @user                           = @config[:user]

      @branch = @deposit_collection.branch
      @data   = @deposit_collection.data.with_indifferent_access

      @default_deposit_accounts = Settings.default_deposit_accounts
    end

    def execute!
      # Update records
      new_records = []

      @data[:records].each do |o|
        if o[:member][:id] != @member.id
          new_records << o
        end
      end

      @data[:records] = new_records

      ##########################
  
      # Recompute totals
      recompute_totals!

      # Load accounting entry
      @data[:accounting_entry]  = ::DepositCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!
      ##########################

      @deposit_collection.update!(
        data: @data
      )

      @deposit_collection
    end

    private

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
