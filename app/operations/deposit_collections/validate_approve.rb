module DepositCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config             = config
      @deposit_collection = @config[:deposit_collection]
      @user               = @config[:user]

      @data             = @deposit_collection.try(:data).try(:with_indifferent_access)
      @accounting_entry = @data[:accounting_entry]

    end

    def execute!
      if @deposit_collection.blank?
        @errors[:messages] << {
          key: "deposit_collection",
          message: "deposit_collection not found"
        }
      end

      if @data.present? and @data[:or_number].blank? and @accounting_entry[:book] == "CRB"
        @errors[:messages] << {
          key: "or_number",
          message: "no or number found"
        }
      end

      if Settings.activate_microinsurance
        if @data.present? and @data[:accounting_fund_id].blank?
          @errors[:messages] << {
            key: "accounting_fund_id",
            message: "no accounting fund found"
          }
        end

        if @data.present? and @data[:or_number].blank? and @accounting_entry[:book] == "JVB"
          @errors[:messages] << {
            key: "or_number",
            message: "no or number found"
          }
        end

        if @data[:records].present? 
          @data[:records].each do |record|
            member = Member.find(record[:member][:id])
            record[:records].each do |rec|
              
              # if rec[:record_type] == "INSURANCE" and rec[:amount].to_f > 0 and member.age >= 65
              #   @errors[:messages] << {
              #     key: "validation",
              #     message: "Cannot deposit #{rec[:account_subtype]} for #{member.full_name}, member is already 65 years old!"
              #   }
              # end

              if rec[:record_type] == "INSURANCE" and rec[:amount].to_f > 0 and MemberAccountValidationRecord.where(status: "pending", member_id: member.id).present?
                @errors[:messages] << {
                  key: "validation",
                  message: "#{member.full_name}, has pending validation!"
                }
              end

              if rec[:record_type] == "INSURANCE" and rec[:amount].to_f > 0 and MemberAccountValidationRecord.where(status: "approved", member_id: member.id).present? and MemberAccountValidationRecord.where(status: "approved", member_id: member.id).where("data ->> 'is_void' = ?", "false").present?
                @errors[:messages] << {
                  key: "validation",
                  message: "#{member.full_name}, is already validated!"
                }
              end
              
            end
          end
        end
      end  

      if @data.present? and @data[:accounting_entry][:particular].blank?
        @errors[:messages] << {
          key: "particular",
          message: "no particular found"
        }
      end

      if @data.present? and @data[:records].size == 0
        @errors[:messages] << {
          key: "records",
          message: "no records found"
        }
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
