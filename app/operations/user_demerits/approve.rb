module UserDemerits
  class Approve
    attr_accessor :user, :user_demerit

    def initialize(config:)
      @user_demerit = config[:user_demerit]
      @user         = config[:user]
    end

    def execute!
      data  = @user_demerit.data.with_indifferent_access

      data[:approved_by]  = {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name
      }

      @user_demerit.update!(  
        data: data,
        date_approved: Date.today,
        status: 'approved'
      )

      @user_demerit
    end
  end
end
