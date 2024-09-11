module SavingsInsuranceTransferCollections
  class AddMember
    def initialize(config:)
      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @member                                 = @config[:member]
      if !@savings_insurance_transfer_collection.clip
        @amount                                 = @config[:amount]
      end
      @user                                   = @config[:user]

      if @savings_insurance_transfer_collection.clip
        @loan_product_id                        = @config[:loan_product_id]
        if Settings.activate_microinsurance
          @principal                              = @config[:principal].to_i
        else
          @principal                              = @config[:principal]
        end
        
        @term                                   = @config[:term]
        @maturity_date                          = @config[:maturity_date]
        @effective_date                         = @config[:effective_date]
        @clip_number                            = @config[:clip_number]
        @beneficiary                            = @config[:beneficiary]
        @num_installments                       = @config[:num_installments]
        if !Settings.activate_microinsurance
          if @loan_product_id.present?
            @loan_product_name = LoanProduct.find(@loan_product_id).to_s
          end
        end
      end
        
      if Settings.activate_microinsurance
        if @savings_insurance_transfer_collection.clip
          @amount                             = ((@principal * 0.014 * (@num_installments).to_i) / 12) 
        end
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
        @beneficiary_age              = ((@effectivity_date.to_time - @date_of_birth.to_time)/(60*60*24*365)).floor(4)
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
        @kkalinga_beneficiary_age              = ((@kkalinga_effectivity_date.to_time - @kkalinga_date_of_birth.to_time)/(60*60*24*365)).floor(4)
      end
      
      @data   = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)
      @branch = @savings_insurance_transfer_collection.branch
      @insurance_subtype  = @data[:insurance_subtype]
      if !Settings.activate_microinsurance
        @savings_subtype    = @data[:savings_subtype]
      end
    end

    def execute!
      if !Settings.activate_microinsurance
        @savings_account    = MemberAccount.where(member_id: @member.id, account_subtype: @savings_subtype).first
      end
      @insurance_account  = MemberAccount.where(member_id: @member.id, account_subtype: @insurance_subtype).first
      if !Settings.activate_microinsurance
        if @savings_insurance_transfer_collection.clip
          @data[:records] << {
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            },
            clip_data: {
              loan_product_id: @loan_product_id,
              loan_product_name: @loan_product_name,
              principal: @principal,
              term: @term,
              num_installments: @num_installments,
              maturity_date: @maturity_date,
              effective_date: @effective_date,
              clip_number: @clip_number,
              beneficiary: @beneficiary
            },
            savings_account_id: @savings_account.id,
            insurance_account_id: @insurance_account.id,
            amount: @amount,
            savings_account_balance: @savings_account.balance,
            insurance_account_balance: @insurance_account.balance
          }
        elsif @savings_insurance_transfer_collection.kbente
          @data[:records] << {
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            },
            kbente_data: {
              gender: @gender,
              kbente_beneficiary_name: @kbente_beneficiary_name,
              date_of_birth: @date_of_birth,
              status: @status,
              address: @address,
              effectivity_date: @effectivity_date,
              premium: @premium,
              relationship: @relationship,
              beneficiary_age: @beneficiary_age
            },
            savings_account_id: @savings_account.id,
            insurance_account_id: @insurance_account.id,
            amount: @amount,
            savings_account_balance: @savings_account.balance,
            insurance_account_balance: @insurance_account.balance
          }  

        elsif @savings_insurance_transfer_collection.kkalinga
          @data[:records] << {
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            },
            kkalinga_data: {
              kkalinga_gender: @kkalinga_gender,
              kkalinga_name_of_insured: @kkalinga_name_of_insured,
              kkalinga_date_of_birth: @kkalinga_date_of_birth,
              kkalinga_status: @kkalinga_status,
              kkalinga_address: @kkalinga_address,
              kkalinga_effectivity_date: @kkalinga_effectivity_date,
              kkalinga_premium: @kkalinga_premium,
              kkalinga_relationship: @kkalinga_relationship,
              kkalinga_beneficiary_name: @kkalinga_beneficiary_name,
              kkalinga_beneficiary_age: @kkalinga_beneficiary_age,
              poc_number: @poc_number
            },
            savings_account_id: @savings_account.id,
            insurance_account_id: @insurance_account.id,
            amount: @amount,
            savings_account_balance: @savings_account.balance,
            insurance_account_balance: @insurance_account.balance
          }  
         # raise @data[:records][0][:kkalinga_data].inspect  
        else  
          @data[:records] << {
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            },
            savings_account_id: @savings_account.id,
            insurance_account_id: @insurance_account.id,
            amount: @amount,
            savings_account_balance: @savings_account.balance,
            insurance_account_balance: @insurance_account.balance
          }
        end
      else
        if @savings_insurance_transfer_collection.clip
          @data[:records] << {
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            },
            clip_data: {
              loan_product_id: @loan_product_id,
              loan_product_name: @loan_product_name,
              principal: @principal,
              term: @term,
              num_installments: @num_installments,
              maturity_date: @maturity_date,
              effective_date: @effective_date,
              clip_number: @clip_number,
              beneficiary: @beneficiary
            },
            insurance_account_id: @insurance_account.id,
            amount: @amount,
            insurance_account_balance: @insurance_account.balance
          }
        elsif @savings_insurance_transfer_collection.kbente
          @data[:records] << {
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            },
            kbente_data: {
              gender: @gender,
              kbente_beneficiary_name: @kbente_beneficiary_name,
              date_of_birth: @date_of_birth,
              status: @status,
              address: @address,
              effectivity_date: @effectivity_date,
              premium: @premium,
              relationship: @relationship,
              beneficiary_age: @beneficiary_age
            },
            insurance_account_id: @insurance_account.id,
            amount: @amount,
            insurance_account_balance: @insurance_account.balance
          }  

        elsif @savings_insurance_transfer_collection.kkalinga
          @data[:records] << {
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            },
            kkalinga_data: {
              kkalinga_gender: @kkalinga_gender,
              kkalinga_name_of_insured: @kkalinga_name_of_insured,
              kkalinga_date_of_birth: @kkalinga_date_of_birth,
              kkalinga_status: @kkalinga_status,
              kkalinga_address: @kkalinga_address,
              kkalinga_effectivity_date: @kkalinga_effectivity_date,
              kkalinga_premium: @kkalinga_premium,
              kkalinga_relationship: @kkalinga_relationship,
              kkalinga_beneficiary_name: @kkalinga_beneficiary_name,
              kkalinga_beneficiary_age: @kkalinga_beneficiary_age,
              poc_number: @poc_number
            },
            insurance_account_id: @insurance_account.id,
            amount: @amount,
            insurance_account_balance: @insurance_account.balance
          }  

        else  
          @data[:records] << {
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            },
            insurance_account_id: @insurance_account.id,
            amount: @amount,
            insurance_account_balance: @insurance_account.balance
          }
        end
      end
      total_amount  = @data[:records].inject(0){ |sum, hash| sum + hash[:amount] }.round(2)

      @data[:accounting_entry]  = ::SavingsInsuranceTransferCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @savings_insurance_transfer_collection.update!(data: @data, total_amount: total_amount)

      @savings_insurance_transfer_collection
    end
  end
end