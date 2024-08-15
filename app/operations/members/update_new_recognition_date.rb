module Members
  class UpdateNewRecognitionDate
    def initialize(member:, previous_recognition_date:, update_recognition_date:, user:)
      @member = member
      @previous_recognition_date = previous_recognition_date
      @update_recognition_date = update_recognition_date
      @member_data = @member.data.with_indifferent_access
      @recognition_date = @member_data["recognition_date"]
      @user_full_name = user.full_name
      @current_date = Date.today
    end

    def execute!
      @member_data[:recognition_date_record] ||= []

      if @member_data[:recognition_date_record].nil? || @member_data[:recognition_date_record].empty?
        @member_data[:recognition_date] = @update_recognition_date
        @member_data[:recognition_date_record] << {
          original_recognition_date: @recognition_date,
          previous_recognition_date: @previous_recognition_date,
          update_recognition_date: @update_recognition_date,
          updated_by: @user_full_name,
          date_changed: @current_date
        }
      else
        original_recognition_date = @member_data["recognition_date_record"][0]["original_recognition_date"]
        @member_data[:recognition_date] = @update_recognition_date
        @member_data[:recognition_date_record] << {
          original_recognition_date: original_recognition_date,
          previous_recognition_date: @previous_recognition_date,
          update_recognition_date: @update_recognition_date,
          updated_by: @user_full_name,
          date_changed: @current_date
        }
      end

      # raise @member_data[:recognition_date_record].inspect
      @member.update!(data: @member_data)
    end
  end
end
