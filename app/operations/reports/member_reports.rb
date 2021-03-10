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
          @members      = Member.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ? AND branch_id = ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @branch_id, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")
        elsif status == "active"
          @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND branch_id = ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @status, @branch_id, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")
        end
      elsif @insurance_status.present? && @status.present? && @start_date.present? && @end_date.present?
        if insurance_status == "resigned"
          @members      = Member.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")
        elsif status == "active"
          @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status = ? AND member_type IN (?)", @start_date, @end_date, @status, @insurance_status, ["Regular", "Kaagapay"]).order("last_name ASC")
        end
      elsif @status.present? && @start_date.present? && @end_date.present?
        if status == "resigned"
          @members      = Member.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ? AND member_type IN (?)", @start_date, @end_date, ["Regular", "Kaagapay"]).order("last_name ASC")
        elsif status == "active"
          @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status IN (?) AND member_type IN (?)", @start_date, @end_date, @status, ["inforce", "lapsed", "dormant"], ["Regular", "Kaagapay"]).order("last_name ASC")
        end
      end
      
    #   elsif @insurance_status.present? && @branch_id.present? && @member_type.present? && @start_date.present? && @end_date.present?
    #     if @insurance_status == "resigned" 
    #       @members      = Member.where("date_resigned >= ? AND date_resigned <= ? AND insurance_status = ? AND branch_id = ? AND member_type = ?",  @start_date, @end_date, @insurance_status, @branch_id, @member_type).order("last_name ASC")
    #     else
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND insurance_status = ? AND branch_id = ? AND member_type = ?",  @start_date, @end_date, @insurance_status, @branch_id, @member_type).order("last_name ASC")
    #     end
    #   elsif @branch_id.present? && @insurance_status.present? && @status.present? && @start_date.present? && @end_date.present?
    #     if @status == "resigned"
    #       @members      = Member.where("date_resigned >= ? AND date_resigned <= ? AND status = ? AND branch_id = ? AND insurance_status = ?", @start_date, @end_date, @status, @branch_id, @insurance_status).order("last_name ASC")
    #     else
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status = ? AND branch_id = ? AND member_type != ?", @start_date, @end_date, @status, @insurance_status, @branch_id, "GK").order("last_name ASC")
    #     end
    #   elsif @branch_id.present? && @member_type.present? && @status.present? && @start_date.present? && @end_date.present?
    #     if @status == "resigned"
    #       @members      = Member.where("date_resigned >= ? AND date_resigned <= ? AND status = ? AND branch_id = ? AND member_type = ?", @start_date, @end_date, @status, @branch_id, @member_type).order("last_name ASC")
    #     elsif @status == "active"
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND branch_id = ? AND member_type = ? AND insurance_status != ?", @start_date, @end_date, @status, @branch_id, @member_type, "dormant").order("last_name ASC")
    #     else
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND member_type = ? AND branch_id = ?", @start_date, @end_date, @status, @member_type, @branch_id).order("last_name ASC")
    #     end  
    #   elsif @insurance_status.present? && @status.present? && @start_date.present? && @end_date.present?
    #     if @status == "resigned"
    #       @members      = Member.where("date_resigned >= ? AND date_resigned <= ? AND status = ?", @start_date, @end_date, @status).order("last_name ASC")
    #     else
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status = ?", @start_date, @end_date, @status, @insurance_status).order("last_name ASC")
    #     end      
    #   elsif @branch_id.present? && @status.present? && @start_date.present? && @end_date.present?
    #     if @status == "resigned"
    #       @members      = Member.where("date_resigned >= ? AND date_resigned <= ? AND status = ? AND branch_id = ?", @start_date, @end_date, @status, @branch_id).order("last_name ASC")
    #     elsif @status == "active"
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND branch_id = ? AND insurance_status != ?", @start_date, @end_date, @status, @branch_id, "dormant").order("last_name ASC")
    #     else
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND branch_id = ?", @start_date, @end_date, @status, @branch_id).order("last_name ASC")
    #     end
    #   elsif @start_date.present? && @end_date.present? && @status.present?    
    #     if @status == "resigned"
    #       @members      = Member.where("date_resigned >= ? AND date_resigned <= ? AND status = ?", @start_date, @end_date, @status).order("last_name ASC")
    #     elsif @status == "active"
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ? AND insurance_status != ?", @start_date, @end_date, @status, "dormant").order("last_name ASC")
    #     else
    #       @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status = ?", @start_date, @end_date, @status).order("last_name ASC")
    #     end
    #   elsif @start_date.present? && @end_date.present? && @branch_id.present?
    #     @members      = Member.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND status != ? AND branch_id = ?", @start_date, @end_date, "archived", @branch_id).order("last_name ASC")
		  # elsif @status.present? && @branch_id.present?
    #     if @status == "active"
    #       @members      = Member.where("status = ? AND branch_id = ? AND insurance_status != ?", @status, @branch_id, "dormant").order("last_name ASC")
    #     else
    #       @members      = Member.where("status = ? AND branch_id = ?", @status, @branch_id).order("last_name ASC")
    #     end
    #   elsif @insurance_status.present? && @branch_id.present?
    #     @members      = Member.where("insurance_status = ? AND status != ? AND branch_id = ?", @insurance_status, "archived", @branch_id).order("last_name ASC")
    #   elsif @status.present?
    #     if @status == "active" 
    #       @members      = Member.where("status = ? AND insurance_status != ?", @status, "dormant").order("last_name ASC")
    #     else
    #       @members      = Member.where("status = ?", @status).order("last_name ASC")
    #     end
    #   elsif @insurance_status.present?
    #     @members      = Member.where("insurance_status = ? AND status != ?", @insurance_status, "archived").order("last_name ASC")
    #   elsif @member_type.present?
    #     @members      = Member.where("member_type = ? AND status != ?", @member_type, "archived").order("last_name ASC")
    #   else
    #     @members      = Member.where("status != ?", "archived").order("last_name ASC")
    #   end
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
