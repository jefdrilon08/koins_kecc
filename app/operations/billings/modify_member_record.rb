module Billings
  class ModifyMemberRecord

    def initialize(config:)
      @config         = config
      @user          = @config[:current_user]
      @billing        = @config[:billing]
      @current_member = @config[:current_member]
      @member_records = @config[:member_records]
      @data = @billing.data.with_indifferent_access
    end

    def execute!
      m_record = @data[:records].select{ |r|
        r[:member][:id] == @current_member[:id]
      }.first

      @data[:records].each do |o|
        if o[:member][:id] == @current_member[:id]
          o[:records]= @member_records
          o[:member] = @current_member.clone
        end
      end

      # Reset
      @data[:totals].each_with_index do |t, index|
        @data[:totals][index][:amount]  = 0.00
      end

      # Recompute
      total_collected = 0.00
      total_loan_payment = 0.00
      grand_total_loan_payment = 0.00


      @data[:totals].each_with_index do |t, index|
        if t[:record_type] == "SAVINGS"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "SAVINGS" and t[:key] == rr[:account_subtype]
            }.each do |rr|
              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end
          end
        elsif t[:record_type] == "EQUITY"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "EQUITY" and t[:key] == rr[:account_subtype]
            }.each do |rr|
              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end
          end
        elsif t[:record_type] == "INSURANCE"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "INSURANCE" and t[:key] == rr[:account_subtype]
            }.each do |rr|
              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end

          end
        elsif t[:record_type] == "WP"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "WP"
            }.each do |rr|
              total_collected -= rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
            end
          end
        elsif t[:record_type] == "LOAN_PAYMENT"
          @data[:records].each_with_index do |r, i|
            r[:records].select{ |rr|
              rr[:record_type] == "LOAN_PAYMENT" and rr[:enabled] == true and t[:key] == rr[:loan_product][:name]
            }.each do |rr|

              total_collected += rr[:amount].try(:to_f).round(2)
              @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
              grand_total_loan_payment += rr[:amount].try(:to_f).round(2)
              @data[:grand_total_loan_paymet] = 0.0
              @data[:grand_total_loan_paymet] += grand_total_loan_payment.to_f
            end
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

      @data[:accounting_entry]  = ::Billings::BuildAccountingEntry.new(
                                    config: {
                                      branch: @billing.branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @billing.update!(data: @data)

      @billing
    end
  end
end
