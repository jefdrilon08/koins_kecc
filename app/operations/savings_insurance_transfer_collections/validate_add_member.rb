module SavingsInsuranceTransferCollections
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @member                                 = @config[:member]
      @amount                                 = @config[:amount]
    
      if @savings_insurance_transfer_collection.clip
        @loan_product_id                        = @config[:loan_product_id]
        @principal                              = @config[:principal]
        @term                                   = @config[:term]
        @num_installments                       = @config[:num_installments]
        @maturity_date                          = @config[:maturity_date]
        @effective_date                         = @config[:effective_date]
        @clip_number                            = @config[:clip_number]
      end

      if @savings_insurance_transfer_collection.kbente
        @kbente_beneficiary_name      = @config[:kbente_beneficiary_name]
        @date_of_birth                = @config[:date_of_birth]
        @gender                       = @config[:gender]
        @status                       = @config[:status]
        @address                      = @config[:address]
        @effectivity_date             = @config[:effectivity_date]
        @premium                      = @config[:premium]
        @relationship                 = @config[:relationship]
        @beneficiary_age              = ((@effectivity_date.to_time - @date_of_birth.to_time)/(60*60*24*365.25)).floor(4)
      end

      if @savings_insurance_transfer_collection.kkalinga
        @kkalinga_name_of_insured              = @config[:kkalinga_name_of_insured]
        @kkalinga_date_of_birth                = @config[:kkalinga_date_of_birth]
        @kkalinga_gender                       = @config[:kkalinga_gender]
        @kkalinga_status                       = @config[:kkalinga_status]
        @kkalinga_address                      = @config[:kkalinga_address]
        @kkalinga_effectivity_date             = @config[:kkalinga_effectivity_date]
        @kkalinga_premium                      = @config[:premium]
        @kkalinga_relationship                 = @config[:kkalinga_relationship]
        @kkalinga_beneficiary_name             = @config[:kkalinga_beneficiary_name]
        @poc_number                            = @config[:poc_number]
        @kkalinga_beneficiary_age              = ((@kkalinga_effectivity_date.to_time - @kkalinga_date_of_birth.to_time)/(60*60*24*365.25)).floor(4)
      end

      @data = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)
      @records = @data[:records]

      @member_index_records = @records.select{|r| r[:member][:id] == @member.id}
      @total_per_member = @member_index_records.map{|c| c[:amount]}.sum
     
      if @data.present?
        @savings_subtype    = @data[:savings_subtype]
        @insurance_subtype  = @data[:insurance_subtype]
      end
    end

    def execute!
      if @savings_insurance_transfer_collection.present? and !@savings_insurance_transfer_collection.pending?
        @errors[:messages] << {
          key: "savings_insurance_transfer_collection",
          message: "record is not pending"
        }
      end

      if !Settings.activate_microinsurance
        if @amount.blank?
          @errors[:messages] << {
            key: "amount",
            message: "Amount required"
          }
        end
      end

      if @amount.present? and @amount <= 0.00
        @errors[:messages] << {
          key: "amount",
          message: "Amount should be positive"
        }
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member required"
        }
      end

      if !@savings_insurance_transfer_collection.clip && !@savings_insurance_transfer_collection.kbente && !@savings_insurance_transfer_collection.kkalinga
        if @member.present? and @savings_insurance_transfer_collection.member_ids.include?(@member.id)
          @errors[:messages] << {
            key: "message",
            message: "Member already included"
          }
        end
      end

      if !Settings.activate_microinsurance
        if @member.present?
          @savings_account  = MemberAccount.where(member_id: @member.id, account_subtype: @savings_subtype).first

          if @savings_account.blank?
            @errors[:messages] << {
              key: "savings_account",
              message: "savings account #{@savings_subtype} not found"
            }
          end

          @insurance_account  = MemberAccount.where(member_id: @member.id, account_subtype: @insurance_subtype).first
          
          if @insurance_account.blank?
            @errors[:messages] << {
              key: "insurance_account",
              message: "insurance account #{@insurance_subtype} not found"
            }
          end
        end
      end
      
      if @savings_account.present? and @savings_account.maintaining_balance > (@savings_account.balance - @amount)
        @errors[:messages] << {
          key: "savings_account",
          message: "Not enough balance for savings #{@savings_subtype} (Maintaining balance: #{@savings_account.maintaining_balance}) for member #{@member.full_name}"
        }
      end

      if @savings_account.present? and @savings_account.maintaining_balance > (@savings_account.balance - @total_per_member)
        @errors[:messages] << {
          key: "savings_account",
          message: "Not enough balance for savings #{@savings_subtype} (Maintaining balance: #{@savings_account.maintaining_balance}) for member #{@member.full_name}"
        }
      end

      if @savings_insurance_transfer_collection.clip
        if !Settings.activate_microinsurance
          if !@loan_product_id.present?
            @errors[:messages] << {
              key: "loan_product",
              message: "Loan Product is required"
            }
          end
        end

        if Settings.activate_microinsurance
          if !@clip_number.present?
            @errors[:messages] << {
              key: "clip_number",
              message: "CLIP Number is required"
            }
          end
        end

        if !@principal.present?
          @errors[:messages] << {
            key: "principal",
            message: "Principal is required"
          }
        end

        # if !@term.present?
        #   @errors[:messages] << {
        #     key: "term",
        #     message: "Term is required"
        #   }
        # end

        if !Settings.activate_microinsurance
          if !@num_installments.present?
            @errors[:messages] << {
              key: "num_installments",
              message: "Num Installments is required"
            }
          end
        end

        if !@maturity_date.present?
          @errors[:messages] << {
            key: "maturity_date",
            message: "Maturity Date is required"
          }
        end

        if !@effective_date.present?
          @errors[:messages] << {
            key: "effective_date",
            message: "Effectivity Date is required"
          }
        end
      end
      if @savings_insurance_transfer_collection.kbente
        if !@kbente_beneficiary_name.present?
          @errors[:messages] << {
            key: "kbente_beneficiary_name",
            message: "Beneficiary Name is required"
          }
        end

        if !@date_of_birth.present?
          @errors[:messages] << {
            key: "date_of_birth",
            message: "Birthdate is required"
          }
        end
        
        if !@gender.present?
          @errors[:messages] << {
            key: "gender",
            message: "Gender is required"
          }
        end

        if !@status.present?
          @errors[:messages] << {
            key: "status",
            message: "Status is required"
          }
        end

        # if !@address.present?
        #   @errors[:messages] << {
        #     key: "address",
        #     message: "Address is required"
        #   }
        # end

        if !@effectivity_date.present?
          @errors[:messages] << {
            key: "effectivity_date",
            message: "Effectivity Date is required"
          }
        end
        
        # if !@premium.present?
        #   @errors[:messages] << {
        #     key: "premium",
        #     message: "premium is required"
        #   }
        # end

        if !@relationship.present?
          @errors[:messages] << {
            key: "relationship",
            message: "Relationship is required"
          }
        end

        if @beneficiary_age > 65 && (@relationship == "Husband" or @relationship == "Wife" or @relationship == "Mother" or @relationship == "Father")
          @errors[:messages] << {
            key: "beneficiary_age",
            message: "You should be below 65 years old"
          }
        end

        if @beneficiary_age > 21 && (@relationship == "Daughter" or @relationship == "Son")
          @errors[:messages] << {
            key: "beneficiary_age",
            message: "You should be 21 years old and below"
          }
        end

        if @beneficiary_age > 65 && (@relationship == "Member")
          @errors[:messages] << {
            key: "beneficiary_age",
            message: "You should be below 65 years old"
          }
        end

        if @beneficiary_age < 18 && (@relationship == "Member")
          @errors[:messages] << {
            key: "beneficiary_age",
            message: "You should be 18 to 64 years old"
          }
        end

        if @beneficiary_age <= 0.03836 && (@relationship == "Daughter" or @relationship == "Son")
          @errors[:messages] << {
            key: "beneficiary_age",
            message: "You should be 2weeks old and above"
          }
        end

      end

      if @savings_insurance_transfer_collection.kkalinga
        if !@kkalinga_beneficiary_name.present?
          @errors[:messages] << {
            key: "kbente_beneficiary_name",
            message: "Beneficiary Name is required"
          }
        end

        if !@kkalinga_name_of_insured.present?
          @errors[:messages] << {
            key: "kkalinga_name_of_insured",
            message: "Name of Insured is required"
          }
        end

        if !@kkalinga_date_of_birth.present?
          @errors[:messages] << {
            key: "date_of_birth",
            message: "Birthdate is required"
          }
        end
        
        if !@kkalinga_gender.present?
          @errors[:messages] << {
            key: "gender",
            message: "Gender is required"
          }
        end

        if !@kkalinga_status.present?
          @errors[:messages] << {
            key: "status",
            message: "Status is required"
          }
        end

        if !@kkalinga_address.present?
          @errors[:messages] << {
            key: "address",
            message: "Address is required"
          }
        end

        if !@kkalinga_effectivity_date.present?
          @errors[:messages] << {
            key: "effectivity_date",
            message: "Effectivity Date is required"
          }
        end
        
        if !@poc_number.present?
          @errors[:messages] << {
            key: "poc_number",
            message: "POCNumber is required"
          }
        end

        if !@kkalinga_relationship.present?
          @errors[:messages] << {
            key: "relationship",
            message: "Relationship is required"
          }
        end
 
        if @kkalinga_beneficiary_age < 17 
          @errors[:messages] << {
            key: "kkalinga_beneficiary_age",
            message: "You should be 18 yrs old and above"
          }
        end

        if @kkalinga_beneficiary_age >= 65
          @errors[:messages] << {
            key: "kkalinga_beneficiary_age",
            message: "You should be below 65 yrs old"
          }
        end

      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end