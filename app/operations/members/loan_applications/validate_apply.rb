module Members
  module LoanApplications
    class ValidateApply < ::Core::Validator
      def initialize(
        member:,
        amount:,
        term:,
        num_installments:,
        loan_product:,
        co_maker_first_name:,
        co_maker_last_name:,
        co_maker_member_id:,
        data: {},
        project_type_category:,
        project_type_id:
      )
        super()

        @member               = member
        @amount               = amount.try(:to_f).try(:round, 2)
        @term                 = term
        @num_installments     = num_installments
        @loan_product         = loan_product
        @data                 = data
        @co_maker_first_name  = co_maker_first_name
        @co_maker_last_name   = co_maker_last_name
        @co_maker_member_id   = co_maker_member_id
        @project_type_category = project_type_category
        @project_type_id      = project_type_id

        @payload = {
          member:               [],
          amount:               [],
          term:                 [],
          num_installments:     [],
          date_applied:         [],
          loan_product_id:      [],
          loan_application:     [],
          co_maker_first_name:  [],
          co_maker_last_name:   [],
          co_maker_member_id:   [],
          clip_beneficiary_first_name: [],
          clip_beneficiary_middle_name: [],
          clip_beneficiary_last_name: [],
          clip_beneficiary_date_of_birth: [],
          clip_beneficiary_relationship: [],
          project_type_category: [],
          project_type_id:      [],
          mobile_number:        []
        }
      end

      def execute!
        if @amount.blank?
          @payload[:amount] << "required"
        end

        if @member.blank?
          @payload[:member] << "required"
        end

        if @term.blank?
          @payload[:term] << "required"
        end

        if @num_installments.blank?
          @payload[:num_installments] << "required"
        end

        # If the member type is GK, its not required to fill the co_maker and clip
        if @member.member_type != "GK"
          if @co_maker_first_name.blank?
            @payload[:co_maker_first_name] << "required"
          end
  
          if @co_maker_last_name.blank?
            @payload[:co_maker_last_name] << "required"
          end

          if @data[:clip_beneficiary][:first_name].blank?
            @payload[:clip_beneficiary_first_name] << "required"
          end
  
          if @data[:clip_beneficiary][:middle_name].blank?
            @payload[:clip_beneficiary_middle_name] << "required"
          end
  
          if @data[:clip_beneficiary][:last_name].blank?
            @payload[:clip_beneficiary_last_name] << "required"
          end
  
          if @data[:clip_beneficiary][:date_of_birth].blank?
            @payload[:clip_beneficiary_date_of_birth] << "required"
          end
  
          if @data[:clip_beneficiary][:relationship].blank?
            @payload[:clip_beneficiary_relationship] << "required"
          end
        end

        if @co_maker_member_id.blank?
          @payload[:co_maker_member_id] << "required"
        end

        if @loan_product.blank?
          @payload[:loan_product_id] << "required"
        end

        


        mobile_number = @data[:mobile_number]
        mobile_number_count= Member.where("mobile_number LIKE ?","%" + mobile_number).count
        mobile_number_exist = false

        if @data[:mobile_number].blank? 
          @payload[:mobile_number] << "required" 

        elsif mobile_number_count > 0
          if mobile_number_count == 1
            member = Member.find(@member.id)
           
            if member.mobile_number.slice(-10..) == Member.where("mobile_number LIKE ?","%" + mobile_number).first.mobile_number.slice(-10..)
              mobile_number_exist = false
            else 
              mobile_number_exist =true 
            end
          else
            mobile_number_exist == true
          end

          if mobile_number_exist
            @payload[:mobile_number] << "mobile number is already exist!"
          end
        end

        if @project_type_id.blank?
          @payload[:project_type_id] << "required"
        end

        if @project_type_category.blank?
          @payload[:project_type_category] << "required"
        end        

        if @loan_product.present? and @amount.present?
          if @amount < @loan_product.min_loan_amount
            @payload[:amount] << "invalid amount"
          elsif @amount > @loan_product.max_loan_amount
            @payload[:amount] << "invalid amount"
          end
        end

        if @member.present? and LoanApplication.where(member_id: @member.id, status: 'pending').count > 0
          @payload[:loan_application] << "pending application"
        end

        count_errors!
      end
    end
  end
end
