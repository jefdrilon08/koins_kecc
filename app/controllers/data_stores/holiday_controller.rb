module DataStores
    class HolidayController < DataStoreController

    def index 
        @subheader_side_actions = [
            {
              id: "btn-new",
              link: "#",
              class: "fa fa-plus",
              text: "New"
            }
        ]
        @records = HolidayRecord.all.order(:holiday_name)

        holiday_id = params[:holiday_id]
        holiday_name = params[:holiday_name]
        date = params[:date]

      if holiday_id.present?
        @records = @records.where(id: holiday_id)
      end

      if holiday_name.present?
        @records = @records.where("holiday_name ILIKE ?", "%#{holiday_name}%")
      end

      if date.present?
        formatted_date = Date.parse(date) rescue nil
        if formatted_date
          @records = @records.where(holiday_date: formatted_date)
        end
    end

end
end
end