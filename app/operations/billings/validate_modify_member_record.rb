module Billings
    class ValidateModifyMemberRecord < AppValidator
        def initialize(config:)
            super()
            @config         = config
            @billing        = @config[:billing]
            @current_member = @config[:current_member]
            @member_records = @config[:member_records]
        
        end
        
        def execute!
           
            @member_records.each do |rec|
                #savings
                if rec[:record_type] == "SAVINGS"
                    member_account  = MemberAccount.find(rec[:member_account_id])

                    if member_account.blank?
                        @errors[:messages] << {
                            key: "savings",
                            message: "Savings Account: #{rec[:account_subtype]} not found"
                        }
                    elsif rec[:amount].to_f < 0
                        @errors[:messages] << {
                            key: "member_accounts",
                            message: "Amount cannot be negative in #{rec[:account_subtype]}: #{rec[:amount]}"
                        }
                    end
                end
                #equity
                if rec[:record_type] == "EQUITY" and rec[:enabled] == true
                    member_account = MemberAccount.find(rec[:member_account_id])
                    if member_account.blank?
                        @errors[:messages] << {
                            key: "equity",
                            message: "Equity Account: #{rec[:account_subtype]} not found"
                        }
                    elsif rec[:amount].to_f < 0
                        @errors[:messages] << {
                            key: "member_accounts",
                            message: "Amount cannot be negative in #{rec[:account_subtype]}: #{rec[:amount]}"
                        }
                    end
                end
                #insurance
                if rec[:record_type] == "INSURANCE" and rec[:enabled] == true
                    member_account = MemberAccount.find(rec[:member_account_id])
                    member = Member.find(@current_member[:id])
        
                    if member_account.blank?
                        @errors[:messages] << {
                            key: "insurance",
                            message: "Insurance Account: #{rec[:account_subtype]} not found"
                        }
                    elsif member[:member_type] == "GK" and rec[:account_subtype] == "Life Insurance Fund" and rec[:amount].to_f > 0.0
                        @errors[:messages] << {
                            key: "insurance",
                            message: "INSURANCE ACCOUNT: #{rec[:account_subtype]} MEMBER TYPE: #{member[:member_type]}"
                        }
                    elsif member[:member_type] == "GK" and rec[:account_subtype] == "Retirement Fund" and rec[:amount].to_f > 0.0
                        @errors[:messages] << {
                            key: "insurance",
                            message: "INSURANCE ACCOUNT: #{rec[:account_subtype]} MEMBER TYPE: #{member[:member_type]}"
                        }
                    elsif rec[:amount].to_f < 0
                        @errors[:messages] << {
                            key: "member_accounts",
                            message: "Amount cannot be negative insurance in #{rec[:account_subtype]}: #{rec[:amount]}"
                        }
                    end
                end
                #WP
                if rec[:record_type] == "WP" and rec[:enabled] == true
                   member_account = MemberAccount.find(rec[:member_account_id])
                    # 
                    if member_account.balance > member_account.maintaining_balance.to_f
                        if (member_account.balance.to_f - rec[:amount].to_f) < member_account.maintaining_balance.to_f
                            @errors[:messages] << {
                                key: "member_accounts",
                                message: "not enough funds to withdraw #{rec[:amount]}. Balance: #{member_account.balance}. Maintaning balance: #{member_account.maintaining_balance}"
                            }
                        end
                    elsif member_account.balance.to_f < member_account.maintaining_balance.to_f
                        if rec[:amount].to_f > member_account.balance
                            @errors[:messages] << {
                                key: "member_accounts",
                                message: "not enough funds to withdraw #{rec[:amount]}. Balance: #{member_account.balance}."
                            }
                        end
                    elsif member_account.blank?
                        @errors[:messages] << {
                            key: "member_accounts",
                            message: "Member Account not found"
                        }
                    elsif rec[:amount].to_f < 0
                        @errors[:messages] << {
                            key: "member_accounts",
                            message: "Amount cannot be negative wp #{rec[:amount]}"
                        }
                    end
                
                end
                #loan
                if rec[:record_type] == "LOAN_PAYMENT" and rec[:enabled] == true
                    loan = ReadOnlyLoan.where(id: rec[:loan_id]).first
                    if !loan.active?
                        @errors[:messages] << {
                            key: "loans",
                            message: "Loan #{rec[:loan_product][:name]} is not active"
                        }
                    elsif rec[:amount].to_f < 0
                        @errors[:messages] << {
                            key: "member_accounts",
                            message: "Amount cannot be negative #{rec[:amount]} loan product #{rec[:loan_product][:name]}"
                        }
                    elsif loan.blank?
                        @errors[:messages] << {
                            key: "loans",
                            message: "Loan not found"
                        }
                    
                    else
                        amount = rec[:amount].to_f
                        current_balance = loan.total_balance.to_f
                        
                        if amount > current_balance
                            @errors[:messages] << {
                                key: "loans",
                                message: "overpayment for #{rec[:loan_product][:name]} current balance: #{current_balance}"
                        }
                        end
                    end

                end

                
            end
            
            @errors[:messages].each do |o|
                @errors[:full_messages] << o[:message]
              end
        
            @errors
        
        end
    end
end