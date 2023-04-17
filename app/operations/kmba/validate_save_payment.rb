module Kmba
  class ValidateSavePayment < AppValidator 
    def initialize(config:)
      super()
      @config               = config
      # raise @config.inspect
    end

    def execute!
      #validate the member_data

      if @config.blank?
        @errors[:messages] << {
          key: "no_member", 
          message: "No Member Record Found!"
        }
      elsif @config.nil?
        @errors[:messages] << {
          key: "no_member", 
          message: "No Member Record Found!"
        }
      else 
        @config.map{ |a|
          if a.blank?
            @errors[:messages] << {
              key: "no_member", 
              message: "No Member Record Found!"
            }
          end

          if a.nil?
            @errors[:messages] << {
              key: "no_member", 
              message: "No Member Record Found!"
            }
          end

          if a[:subsidiary_id].blank?
            @errors[:messages] << {
              key: "subsidiary_id", 
              message: "Subsidiary ID not found"
            }
          end

          if a[:subsidiary_type].blank?
            @errors[:messages] << {
              id: a[:subsidiary_id],
              key: "subsidiary_type", 
              message: "Subsidiary Type not found"
            }
          end 
 

          if a[:amount].blank?
            @errors[:messages] << {
              id: a[:subsidiary_id],
              key: "amount", 
              message: "Amount not found"
            }
          end

          if a[:transaction_type].blank?
            @errors[:messages] << {
              id: a[:subsidiary_id],
              key: "transaction_type", 
              message: "Transaction Type not found"
            }
          end

          if a[:transacted_at].blank?
            @errors[:messages] << {
              id: a[:subsidiary_id],
              key: "transacted_at", 
              message: "Transacted at not found"
            }
          end

          if a[:status].blank?
            @errors[:messages] << {
              id: a[:subsidiary_id],
              key: "status", 
              message: "Status at not found"
            }
          end

          if a[:data].blank?
            @errors[:messages] << {
              key: "data", 
              message: "Status not found"
            }
          end 

          if a[:data][:is_withdraw_payment].blank?
            @errors[:messages] << {
              key: "is_withdraw_payment", 
              message: "is Withdraw Payment not found"
            }
          end

          if a[:data][:is_fund_transfer].blank?
            @errors[:messages] << {
              key: "is_fund_transfer", 
              message: "is Fund Transfer not found"
            }
          end

          # validation need to specified
          if a[:data][:is_interest].blank?
            @errors[:messages] << {
              key: "is_interest", 
              message: "is Interest not found"
            }
          end

          if a[:data][:is_adjustment].blank?
            @errors[:messages] << {
              key: "is_adjustment", 
              message: "is Adjustment not found"
            }
          end

          if a[:data][:is_for_exit_age].blank?
            @errors[:messages] << {
              key: "is_for_exit_age", 
              message: "is for Exit Age not found"
            }
          end 

          if a[:data][:is_for_loan_payments].blank?
            @errors[:messages] << {
              key: "is_for_loan_payments", 
              message: "Is For Loan Payments not found"
            }
          end

          if a[:data][:beginning_balance].blank?
            @errors[:messages] << {
              key: "beginning_balance", 
              message: "Beginning Balance not found"
            }
          end

          if a[:data][:ending_balance].blank?
            @errors[:messages] << {
              key: "ending_balance", 
              message: "Ending Balance not found"
            }
          end          
        }
      end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors  
    end
  end
end