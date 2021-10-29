module Reports
	class MemberReports
		def initialize(status:, start_date:, end_date:, branch_id:, insurance_status:, member_type:)
			@branch_id        =  branch_id
      @insurance_status =  insurance_status
      @member_type      =  member_type
      @status           =  status
      @start_date       =  start_date
      @end_date         =  end_date

      
      if @branch_id.present? && @insurance_status.present? && @status.present? && @start_date.present? && @end_date.present?
        if insurance_status == "resigned"
          @members = Member.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ? AND branch_id = ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @branch_id, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")
        elsif status == "active"
          @members = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND branch_id = ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @status, @branch_id, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")
        end
      elsif @insurance_status.present? && @status.present? && @start_date.present? && @end_date.present?
        if insurance_status == "resigned"
          @members = Member.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")
        elsif status == "active"
          @members = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @status, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")
        else
          @members = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @status, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")     
        end
      elsif @branch_id.present? && @status.present? && @start_date.present? && @end_date.present?
        if status == "resigned"
          @members = Member.where("branch_id = ? AND insurance_date_resigned >= ? AND insurance_date_resigned <= ? AND member_type IN (?)", @branch_id, @start_date, @end_date, ["Regular", "Kaagapay"]).order("last_name ASC")
        elsif status == "active"
          @active_members = Member.where("branch_id = ? AND data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status IN (?) AND member_type IN (?)", @branch_id, @start_date, @end_date, @status, ["inforce", "lapsed", "dormant"], ["Regular", "Kaagapay"]).order("last_name ASC")
          @resigned_before = Member.where("data ->> 'recognition_date' <= ? AND insurance_date_resigned >= ?", @end_date, @end_date)
          @members = @active_members + @resigned_before
        end
      elsif @status.present? && @start_date.present? && @end_date.present?
        if status == "resigned"
          @members = Member.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ? AND member_type IN (?)", @start_date, @end_date, ["Regular", "Kaagapay"]).order("last_name ASC")
        elsif status == "active"
          @active_members = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status IN (?) AND member_type IN (?)", @start_date, @end_date, @status, ["inforce", "lapsed", "dormant"], ["Regular", "Kaagapay"]).order("last_name ASC")
          @resigned_before = Member.where("data ->> 'recognition_date' <= ? AND insurance_date_resigned >= ?", @end_date, @end_date)
          @members = @active_members + @resigned_before
        end
      end
    end

		def execute!
			@data = {}
      @data[:records] = []
      @data[:totals] = []

      @t_dependents = 0
      @t_dependents_value = 0.00
      @t_coverage = 0.00
      @t_lif = 0.00
      @t_rf = 0.00
      value = 0.00

      @members.each_with_index do |member, i|
        record = {}

        number_of_dependents = member.legal_dependents.count
      
        recognition_date = member.recognition_date
        if @end_date.present? 
          current_date = @end_date
        else
          current_date = Time.now.to_date
        end
          
        if !recognition_date.nil?  
          seconds_between = (current_date.to_time - recognition_date.to_time).abs
          days_between = seconds_between / 60 / 60 / 24
          number_of_months = (days_between / 30.44).floor
          years = (days_between / 365.242199).floor
          months = number_of_months - (years * 12)
          if months < 3 && years < 1
            value = 2000.00
            dependent_value = number_of_dependents * 0.0
          elsif months >= 3 && years < 1 
            value = 6000.00
            dependent_value = number_of_dependents * 5000.00
          elsif years >= 1 && years < 2
            value = 10000.00
            dependent_value = number_of_dependents * 5000.00
          elsif years >= 2 && years < 3
            value = 30000.00
            dependent_value = number_of_dependents * 10000.00
          elsif years >= 3
            value = 50000.00
            dependent_value = number_of_dependents * 10000.00
          end
        end  

        record[:index] = i+1
        record[:name] = member.full_name
        record[:recognition_date] = member.recognition_date
        record[:branch] = member.branch.name
        record[:center] = member.center.name
        record[:number_of_dependents] = number_of_dependents
        record[:value_dependents] = dependent_value
        record[:coverage_value] = value
        record[:lif] = member.try(:equity_value)
        record[:rf] = member.try(:rf_amount)
        record[:status] = member.status
        record[:insurance_status] = member.insurance_status
        record[:identification_number] = member.identification_number

        @t_coverage += value
        @t_lif += member.try(:equity_value)
        @t_rf += member.try(:rf_amount)
        @t_dependents += number_of_dependents
        @t_dependents_value += dependent_value.to_i

        
        @data[:records] << record
      end

      total = {}
      total[:total_coverage] = @t_coverage
      total[:total_lif] = @t_lif
      total[:total_rf] = @t_rf
      total[:total_member_count] = @members.count
      total[:total_dependents] = @t_dependents
      total[:total_dependents_value] = @t_dependents_value
    
      @data[:totals] << total

      @data
		end
	end
end
