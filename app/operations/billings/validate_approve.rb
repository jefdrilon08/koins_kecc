module Billings
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @current_date = @config[:current_date] || Date.today

      @data = @billing.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @billing.blank?
        @errors[:messages] << {
          key: "billing",
          message: "billing not found"
        }
      elsif !@billing.pending?
        @errors[:messages] << {
          key: "billing",
          message: "billing is not pending"
        }
      elsif !@billing.checked?
        @errors[:messages] << {
          key: "billing",
          message: "this record has not been checked yet"
        }
      elsif @data[:records].present? 
        
        @data[:records].each do |record|
          member = Member.find(record[:member][:id])
          record[:records].each do |rec|
            if rec[:record_type] == "INSURANCE" and rec[:amount].to_f > 0 and member.age >= 65
              @errors[:messages] << {
                key: "validation",
                message: "Cannot deposit #{rec[:account_subtype]} for #{member.full_name}, member is already 65 years old!"
              }
            end

            # if rec[:record_type] == "INSURANCE" and rec[:amount].to_f > 0 and MemberAccountValidationRecord.where(status: "pending", member_id: member.id).present?
            #   @errors[:messages] << {
            #     key: "validation",
            #     message: "#{member.full_name}, has pending validation!"
            #   }
            # end

            # if rec[:record_type] == "INSURANCE" and rec[:amount].to_f > 0 and MemberAccountValidationRecord.where(status: "approved", member_id: member.id).present?
            #   @errors[:messages] << {
            #     key: "validation",
            #     message: "#{member.full_name}, is already validated!"
            #   }
            # end
          end
        end
      end
    
      if @data.present? and @data[:or_number].blank? and @data[:accounting_entry][:book].present? and @data[:accounting_entry][:book] == "CRB"
        @errors[:messages] << {
          key: "or_number",
          message: "no or number found"
        }
      elsif @data.present? and @data[:accounting_entry][:particular].blank?
      
        @errors[:messages] << {
          key: "particular",
          message: "no particular found"
        }
      elsif @data.present? and @data[:or_number].present?
      
        if Billing.where("branch_id = ? AND data->>'or_number' = ? AND id <> ?", @billing.branch_id, @data[:or_number], @billing.id).count > 0
          @errors[:messages] << {
            key: "or_number",
            message: "Duplicate OR NUMBER"
          }
        end
      end

  

      validate_accounting_entry!

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end

    def validate_accounting_entry!
      accounting_entry_data = @billing.data.with_indifferent_access[:accounting_entry]

      dr_amount = 0.00
      cr_amount = 0.00

      if accounting_entry_data[:journal_entries].any?
        accounting_entry_data[:journal_entries].each do |o|
          if o[:post_type] == "DR"
            dr_amount += o[:amount].to_f.round(2)
          end

          if o[:post_type] == "CR"
            cr_amount += o[:amount].to_f.round(2)
          end
        end

        dr_amount = dr_amount.round(2)
        cr_amount = cr_amount.round(2)

        if dr_amount != cr_amount
          @errors[:messages] << {
            key: "accounting_entry",
            message: "Accounting entry not balanced. DR: #{dr_amount} CR: #{cr_amount}"
          }
        end
      else
        @errors[:messages] << {
          key: "accounting_entry",
          message: "No journal entries found for accounting entry"
        }
      end
    end
  end
end
