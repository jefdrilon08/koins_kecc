module Billings
  class ZeroOut
    def initialize(config:)
      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @current_date = @config[:current_date] || Date.today

      @data = @billing.try(:data).try(:with_indifferent_access)

      @records  = @data[:records]
    end

    def special_report!  

      @data[:special_report] = true
      @billing.update(data:@data)   
    end

    def execute!
     
      @records.each_with_index do |r, i|
        r[:records].each_with_index do |o, ii|
          if o[:enabled] and o[:amount].to_f.round(2) > 0.00
            #o[:amount]  = 0.00
            @records[i][:records][ii][:amount] = 0.00
          end

        end
      end

      @data[:records] = @records
      special_report!
      recompute_totals!
      

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

    def recompute_totals!
      # Reset
      @data[:totals].each_with_index do |t, index|
        @data[:totals][index][:amount]  = 0.00
      end

      @data[:records].each do |rec|
        rec[:total_loan_payment] = 0.00
      end

      # Recompute
      total_collected = 0.00
      grand_total_loan_payment = 0.00

      @data[:totals].each_with_index do |t, index|
        if t[:record_type] == "SAVINGS"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "SAVINGS" and t[:key] == MemberAccount.savings.where(id: rr[:member_account_id]).first.account_subtype
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "INSURANCE"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "INSURANCE" and t[:key] == MemberAccount.insurance.where(id: rr[:member_account_id]).first.account_subtype
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              end
            end
          end
        elsif t[:record_type] == "EQUITY"
          @data[:records].each_with_index do |r, i|
            r[:records].each_with_index do |rr, j|
              if rr[:record_type] == "EQUITY" and t[:key] == MemberAccount.equities.where(id: rr[:member_account_id]).first.account_subtype
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
              if rr[:record_type] == "LOAN_PAYMENT" and rr[:enabled] == true and Loan.find(rr[:loan_id]).loan_product.name == t[:key]
                total_collected += rr[:amount].try(:to_f).round(2)
                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)

              grand_total_loan_payment += rr[:amount].try(:to_f).round(2)
              #raise @data[:grand_total_loan_paymet].inspect
              @data[:grand_total_loan_paymet] = 0.0
              @data[:grand_total_loan_paymet] += grand_total_loan_payment.to_f
              end
            end
          end
        else
          raise "invalid record_type #{t[:record_type]} in totals"
        end
      end

      @data[:total_collected] = total_collected

      # Recompute member totals
      @billing.member_ids.each do |member_id|
        total_collected_for_member  = 0.00
        @data[:records].each_with_index do |r, i|
          if r[:member][:id] == member_id
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
    end
  end
end
