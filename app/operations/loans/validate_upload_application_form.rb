module Loans
  class ValidateUploadApplicationForm < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @user         = @config[:user]
      @loan         = @config[:loan]
      @files        = @config[:files]

      @valid_roles  = ::Users::FetchValidRoles.new(
                        module_name: "upload_loan_application_form"
                      ).execute!
    end

    def execute!
      if @loan.blank?
        @errors[:messages] << {
          key: "loan",
          message: "loan not found"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user not found"
        }
      elsif @user.current_roles.intersection(@valid_roles).size == 0
        @errors[:messages] << {
          key: "user",
          message: "unauthorized"
        }
      end

      if @files.present? and @files.size == 0
        @errors[:messages] << {
          key: "files",
          message: "No file found"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
