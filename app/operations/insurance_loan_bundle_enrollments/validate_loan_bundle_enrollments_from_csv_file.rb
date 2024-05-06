module InsuranceLoanBundleEnrollments
  class ValidateLoanBundleEnrollmentsFromCsvFile < AppValidator
    def initialize(row:)
      super()
      @row                  = row
      @center_id            = row['center_id']
      @branch_id            = row['branch_id']
      @member_id            = row['member_id']
      @full_name            = row['full_name']
      @last_name            = row['last_name']
      @first_name           = row['first_name']
      @effectivity_date     = row['effectivity_date']
      @age                  = row['age']
      @gender               = row['gender']
      @address              = row['address']
      @partner              = row['partner']
      @plan_type            = row['plan_type']
      @birth_date           = row['birth_date']
      @client_type          = row['client_type']
      @civil_status         = row['civil_status']
      @maturity_date        = row['maturity_date']
      @plan_category        = row['plan_category']
      @enrolled_status      = row['enrolled_status']
      @premium_coverage     = row['premium_coverage']
    end

    def execute!
      check_config!
      @errors
    end

    private

    def check_config!
      branch = Branch.where(id: @branch_id).first
      center = Center.where(id: @center_id).first
      member = Member.where(id: @member_id).first

      if @member_id.nil?
        @errors[:messages] << {
          key: "member",
          message: "member is empty "
        }
      elsif member.nil?
        @errors[:messages] << {
          key: "member",
          message: "member is not valid: #{@member_id} "
        }
      end

      if @center_id.nil?
        @errors[:messages] << {
          key: "center",
          message: "center is empty"
        }
      elsif center.nil?
        @errors[:messages] << {
          key: "center",
          message: "center is not valid: #{@center_id} "
        }
      end

      if @branch_id.nil?
        @errors[:messages] << {
          key: "branch",
          message: "branch is empty"
        }
      elsif branch.nil?
        @errors[:messages] << {
          key: "branch",
          message: "branch is not valid: #{@branch_id} "
        }
      end

      if @full_name.nil?
        @errors[:messages] << {
          key: "full name",
          message: "full name is empty #{@full_name} "
        }
      end

      if @last_name.nil?
        @errors[:messages] << {
          key: "last_name",
          message: "last name is empty #{@last_name} "
        }
      end

      if @first_name.nil?
        @errors[:messages] << {
          key: "first_name",
          message: "first name is empty #{@first_name} "
        }
      end

      if @effectivity_date.nil?
        @errors[:messages] << {
          key: "effectivity_date",
          message: "effectivity date is empty #{@effectivity_date} "
        }
      end

      # if @age.nil?
      #   @errors[:messages] << {
      #     key: "age",
      #     message: "age is empty #{@age} "
      #   }
      # end

      # if @gender.nil?
      #   @errors[:messages] << {
      #     key: "gender",
      #     message: "gender is empty #{@gender} "
      #   }
      # end

      # if @address.nil?
      #   @errors[:messages] << {
      #     key: "address",
      #     message: "address is empty #{@address} "
      #   }
      # end

      # if @partner.nil?
      #   @errors[:messages] << {
      #     key: "partner",
      #     message: "partner is empty #{@partner} "
      #   }
      # end

      # if @plan_category.nil?
      #   @errors[:messages] << {
      #     key: "plan_category",
      #     message: "plan category is empty #{@plan_category} "
      #   }
      # end


      # if @birth_date.nil?
      #   @errors[:messages] << {
      #     key: "birth_date",
      #     message: "birth date is empty #{@birth_date} "
      #   }
      # end

      # if @client_type.nil?
      #   @errors[:messages] << {
      #     key: "client_type",
      #     message: "client type is empty #{@client_type} "
      #   }
      # end

      # if @civil_status.nil?
      #   @errors[:messages] << {
      #     key: "civil_status",
      #     message: "civil status is empty #{@civil_status} "
      #   }
      # end

      # if @maturity_date.nil?
      #   @errors[:messages] << {
      #     key: "maturity_date",
      #     message: "maturity date is empty #{@maturity_date} "
      #   }
      # end

      # if @plan_type.nil?
      #   @errors[:messages] << {
      #     key: "plan_type",
      #     message: "plan type is empty #{@plan_type} "
      #   }
      # end

      # if @enrolled_status.nil?
      #   @errors[:messages] << {
      #     key: "enrolled_status",
      #     message: "enrolled status is empty #{@enrolled_status} "
      #   }
      # end

      # if @premium_coverage.nil?
      #   @errors[:messages] << {
      #     key: "premium_coverage",
      #     message: "premium coverage is empty #{@premium_coverage} "
      #   }
      # end
    end
  end
end
