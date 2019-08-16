module Members
  class ValidateImportMembersFromCsvFile < AppValidator
    def initialize(config:)
      super()

      @member = config[:member]
    end

    def execute!
      check_if_center_present!
      check_if_branch_present!
      @errors
    end

    private

    def check_if_branch_present!
      if @member['branch'].nil?
         @errors[:messages] << {
          key: "branch",
          message: "Branch can't be blank"
        }
      end
    end

    def check_if_center_present!
      if @member['center'].nil?
        @errors[:messages] << {
          key: "center",
          message: "Center can't be blank"
        }
      end
    end 
  end
end
