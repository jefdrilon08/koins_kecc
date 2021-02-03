module Reports
	class SummaryOfCertificatesAndPolicies
		def initialize(branch_id:, plan_type:, as_of:)
			@branch_id   =  branch_id
      @plan_type   =  plan_type
      @as_of       =  as_of.to_date
      @members = []

      if @as_of.present? && @branch_id.present?
        @active_members = Member.where("data ->>'recognition_date' <= ? AND status = ? AND insurance_status = ? AND branch_id = ?", @as_of, "active", "inforce", @branch_id)
      elsif @as_of.present?
        # @active_members = Member.where("data ->>'recognition_date' <= ? AND member_type != ? AND status = ? AND insurance_status != ?", @as_of, "GK", "active", "dormant")
        @active_members = Member.where("data ->>'recognition_date' <= ? AND member_type != ? AND status = ? AND insurance_status NOT IN (?)", @as_of, "GK", "active", ["pending", "dormant"])
        @resigned = Member.where("data ->> 'recognition_date' <= ? AND insurance_date_resigned >= ?", @as_of, @as_of)
        @active_members = @active_members  + @resigned
      elsif @branch_id.present?
        # @active_members = Member.where("insurance_status !=? AND branch_id = ?", "dormant", @branch_id)
        @active_members = Member.where("insurance_status NOT IN (?) AND branch_id = ?", ["pending","dormant"], @branch_id)
      end

      @active_members.each do |m|
        recognition_date = m.data.with_indifferent_access['recognition_date']
        if @as_of.present? 
          current_date = @as_of
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
            plan_type = "Less than 3 months"
          elsif months >= 3 && years < 1 
            plan_type = "3 months but less than 1 year"
          elsif years >= 1 && years < 2
            plan_type = "1 year but less than 2 years"
          elsif years >= 2 && years < 3
            plan_type = "2 years but less than 3 years"
          elsif years >= 3
            plan_type = "3 years or more"
          end

          if plan_type == @plan_type
            @members << m
          end
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

      @members.each_with_index do |member, i|
        record = {}

        if member.data['spouse']['first_name'].present?
          number_of_dependents = member.legal_dependents.count + 1
        else
          number_of_dependents = member.legal_dependents.count         
        end
      
        recognition_date = member.try(:recognition_date).try(:to_date)
        if @as_of.present? 
          current_date = @as_of
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
        record[:name] = member.full_name_titleize
        record[:recognition_date] = member.recognition_date
        record[:branch] = member.branch.to_s
        record[:center] = member.center.to_s
        record[:number_of_dependents] = number_of_dependents
        record[:value_dependents] = dependent_value
        record[:coverage_value] = value
        record[:lif] = member.equity_value
        record[:rf] = member.rf_amount
        record[:status] = member.status

        @t_coverage += value
        @t_lif += member.equity_value
        @t_rf += member.rf_amount
        @t_dependents += number_of_dependents
        @t_dependents_value += dependent_value

        
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
