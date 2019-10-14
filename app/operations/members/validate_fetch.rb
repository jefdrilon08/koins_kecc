module Members
  class ValidateFetch < AppValidator
    def initialize(config:)
      super()

      @config = config
      @id     = @config[:id]
      @user   = @config[:user]

      @valid_roles  = ["MIS", "OAS", "BK", "REMOTE-BK", "REMOTE-FM"]
    end

    def execute!
      @member = Member.where(id: @id).first

      if @member.present? && !@member.modifiable
        @errors[:messages] << {
          key: "user",
          message: "Cannot modify member. Status is not modifiable."
        }
      end

      if @user.present?
        if (@valid_roles & @user.roles).size == 0
          @errors[:messages] << {
            key: "user",
            message: "Unauthorized role/s: #{@user.roles}"
          }
        end
      end

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
