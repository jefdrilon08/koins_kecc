module Reports
	class MemberCounts
		def initialize(start_date:, end_date:)
      @start_date       =  start_date.to_date
      @end_date         =  end_date.to_date
      @year             =  @start_date.year
      @jan              = Date.new(@year, 1)
      @feb              = Date.new(@year, 2)
      @mar              = Date.new(@year, 3)
      @apr              = Date.new(@year, 4)
      @may              = Date.new(@year, 5)
      @jun              = Date.new(@year, 6)
      @jul              = Date.new(@year, 7)
      @aug              = Date.new(@year, 8)
      @sep              = Date.new(@year, 9)
      @oct              = Date.new(@year, 10)
      @nov              = Date.new(@year, 11)
      @dec              = Date.new(@year, 12)

      
      if @start_date.present? && @end_date.present?
        @active_members             = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status IN (?)", @end_date, ["inforce", "lapsed"])
        @new_members                = Member.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @start_date, @end_date)
        @resigned_members           = Member.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ? AND insurance_status = ?", @start_date, @end_date, "resigned")

        @new_jan                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @jan.beginning_of_month, @jan.end_of_month)
        @new_feb                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @feb.beginning_of_month, @feb.end_of_month)
        @new_mar                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @mar.beginning_of_month, @mar.end_of_month)
        @new_apr                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @apr.beginning_of_month, @apr.end_of_month)
        @new_may                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @may.beginning_of_month, @may.end_of_month)
        @new_jun                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @jun.beginning_of_month, @jun.end_of_month)
        @new_jul                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @jul.beginning_of_month, @jul.end_of_month)
        @new_aug                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @aug.beginning_of_month, @aug.end_of_month)
        @new_sep                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @sep.beginning_of_month, @sep.end_of_month)
        @new_oct                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @oct.beginning_of_month, @oct.end_of_month)
        @new_nov                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @nov.beginning_of_month, @nov.end_of_month)
        @new_dec                    = @new_members.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @dec.beginning_of_month, @dec.end_of_month)

        @resigned_jan               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @jan.beginning_of_month, @jan.end_of_month)
        @resigned_feb               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @feb.beginning_of_month, @feb.end_of_month)
        @resigned_mar               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @mar.beginning_of_month, @mar.end_of_month)
        @resigned_apr               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @apr.beginning_of_month, @apr.end_of_month)
        @resigned_may               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @may.beginning_of_month, @may.end_of_month)
        @resigned_jun               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @jun.beginning_of_month, @jun.end_of_month)
        @resigned_jul               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @jul.beginning_of_month, @jul.end_of_month)
        @resigned_aug               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @aug.beginning_of_month, @aug.end_of_month)
        @resigned_sep               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @sep.beginning_of_month, @sep.end_of_month)
        @resigned_oct               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @oct.beginning_of_month, @oct.end_of_month)
        @resigned_nov               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @nov.beginning_of_month, @nov.end_of_month)
        @resigned_dec               = @resigned_members.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @dec.beginning_of_month, @dec.end_of_month)
        
        @gk_members                 = Member.where("member_type = ?", "GK")
        @active_resigned_insurance  = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "resigned")
        @active_pending             = Member.active.where("insurance_status = ?", "pending")
      else
        @all_members            = Member.all.order("last_name ASC")
      end
    end

		def execute!
			@data = {}
      @data[:members] = []
      @data[:total_members] = []

      @total_active = 0
      
      @total_new_jan = 0
      @total_new_feb = 0
      @total_new_mar = 0
      @total_new_apr = 0
      @total_new_may = 0
      @total_new_jun = 0
      @total_new_jul = 0
      @total_new_aug = 0
      @total_new_sep = 0
      @total_new_oct = 0
      @total_new_nov = 0
      @total_new_dec = 0

      @total_resigned_jan = 0
      @total_resigned_feb = 0
      @total_resigned_mar = 0
      @total_resigned_apr = 0
      @total_resigned_may = 0
      @total_resigned_jun = 0
      @total_resigned_jul = 0
      @total_resigned_aug = 0
      @total_resigned_sep = 0
      @total_resigned_oct = 0
      @total_resigned_nov = 0
      @total_resigned_dec = 0

      @total_gk = 0
      @total_active_resigned_insurance = 0
      @total_active_pending = 0

      @total_valid_dependent = 0
      @total_valid_dependent_inforce = 0
      @total_valid_dependent_lapsed = 0
      @total_valid_dependent_resigned = 0

      Branch.all.order("cluster_id ASC").each do |branch|
        member = {}
        
        member[:branch] = branch.name
        
        member[:active_count] = @active_members.where(branch_id: branch).count
        member[:new_jan_count] = @new_jan.where(branch_id: branch).count
        member[:new_feb_count] = @new_feb.where(branch_id: branch).count
        member[:new_mar_count] = @new_mar.where(branch_id: branch).count
        member[:new_apr_count] = @new_apr.where(branch_id: branch).count
        member[:new_may_count] = @new_may.where(branch_id: branch).count
        member[:new_jun_count] = @new_jun.where(branch_id: branch).count
        member[:new_jul_count] = @new_jul.where(branch_id: branch).count
        member[:new_aug_count] = @new_aug.where(branch_id: branch).count
        member[:new_sep_count] = @new_sep.where(branch_id: branch).count
        member[:new_oct_count] = @new_oct.where(branch_id: branch).count
        member[:new_nov_count] = @new_nov.where(branch_id: branch).count
        member[:new_dec_count] = @new_dec.where(branch_id: branch).count

        member[:resigned_jan_count] = @resigned_jan.where(branch_id: branch).count
        member[:resigned_feb_count] = @resigned_feb.where(branch_id: branch).count
        member[:resigned_mar_count] = @resigned_mar.where(branch_id: branch).count
        member[:resigned_apr_count] = @resigned_apr.where(branch_id: branch).count
        member[:resigned_may_count] = @resigned_may.where(branch_id: branch).count
        member[:resigned_jun_count] = @resigned_jun.where(branch_id: branch).count
        member[:resigned_jul_count] = @resigned_jul.where(branch_id: branch).count
        member[:resigned_aug_count] = @resigned_aug.where(branch_id: branch).count
        member[:resigned_sep_count] = @resigned_sep.where(branch_id: branch).count
        member[:resigned_oct_count] = @resigned_oct.where(branch_id: branch).count
        member[:resigned_nov_count] = @resigned_nov.where(branch_id: branch).count
        member[:resigned_dec_count] = @resigned_dec.where(branch_id: branch).count
        
        member[:gk_count] = @gk_members.where(branch_id: branch).count
        member[:active_resigned_insurance] = @active_resigned_insurance.where(branch_id: branch).count
        member[:active_pending] = @active_pending.where(branch_id: branch).count
        
        member[:valid_dependent_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.data ->> 'recognition_date' <= ?", branch, @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        member[:valid_dependent_inforce_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.insurance_status = ? AND members.data ->> 'recognition_date' <= ?", branch, "inforce", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        member[:valid_dependent_lapsed_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.insurance_status = ? AND members.data ->> 'recognition_date' <= ?", branch, "lapsed", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        member[:valid_dependent_resigned_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.status = ? AND members.date_resigned <= ?", branch, "resigned", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count

        @total_active += @active_members.where(branch_id: branch).count
        @total_new_jan += @new_jan.where(branch_id: branch).count
        @total_new_feb += @new_feb.where(branch_id: branch).count
        @total_new_mar += @new_mar.where(branch_id: branch).count
        @total_new_apr += @new_apr.where(branch_id: branch).count
        @total_new_may += @new_may.where(branch_id: branch).count
        @total_new_jun += @new_jun.where(branch_id: branch).count
        @total_new_jul += @new_jul.where(branch_id: branch).count
        @total_new_aug += @new_aug.where(branch_id: branch).count
        @total_new_sep += @new_sep.where(branch_id: branch).count
        @total_new_oct += @new_oct.where(branch_id: branch).count
        @total_new_nov += @new_nov.where(branch_id: branch).count
        @total_new_dec += @new_dec.where(branch_id: branch).count

        @total_resigned_jan += @resigned_jan.where(branch_id: branch).count
        @total_resigned_feb += @resigned_feb.where(branch_id: branch).count
        @total_resigned_mar += @resigned_mar.where(branch_id: branch).count
        @total_resigned_apr += @resigned_apr.where(branch_id: branch).count
        @total_resigned_may += @resigned_may.where(branch_id: branch).count
        @total_resigned_jun += @resigned_jun.where(branch_id: branch).count
        @total_resigned_jul += @resigned_jul.where(branch_id: branch).count
        @total_resigned_aug += @resigned_aug.where(branch_id: branch).count
        @total_resigned_sep += @resigned_sep.where(branch_id: branch).count
        @total_resigned_oct += @resigned_oct.where(branch_id: branch).count
        @total_resigned_nov += @resigned_nov.where(branch_id: branch).count
        @total_resigned_dec += @resigned_dec.where(branch_id: branch).count

        @total_gk += @gk_members.where(branch_id: branch).count
        @total_active_resigned_insurance += @active_resigned_insurance.where(branch_id: branch).count
        @total_active_pending += @active_pending.where(branch_id: branch).count
        
        @total_valid_dependent += LegalDependent.joins(:member).where("members.branch_id = ? AND members.data ->> 'recognition_date' <= ?", branch, @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        @total_valid_dependent_inforce += LegalDependent.joins(:member).where("members.branch_id = ? AND members.insurance_status = ? AND members.data ->> 'recognition_date' <= ?", branch, "inforce", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        @total_valid_dependent_lapsed += LegalDependent.joins(:member).where("members.branch_id = ? AND members.insurance_status = ? AND members.data ->> 'recognition_date' <= ?", branch, "lapsed", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        @total_valid_dependent_resigned += LegalDependent.joins(:member).where("members.branch_id = ? AND members.status = ? AND members.date_resigned <= ?", branch, "resigned", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count

        @data[:members] << member
      end

      total = {}
      total[:total_active] = @total_active
      total[:total_new_jan] = @total_new_jan
      total[:total_new_feb] = @total_new_feb
      total[:total_new_mar] = @total_new_mar
      total[:total_new_apr] = @total_new_apr
      total[:total_new_may] = @total_new_may
      total[:total_new_jun] = @total_new_jun
      total[:total_new_jul] = @total_new_jul
      total[:total_new_aug] = @total_new_aug
      total[:total_new_sep] = @total_new_sep
      total[:total_new_oct] = @total_new_oct
      total[:total_new_nov] = @total_new_nov
      total[:total_new_dec] = @total_new_dec

      total[:total_resigned_jan] = @total_resigned_jan
      total[:total_resigned_feb] = @total_resigned_feb
      total[:total_resigned_mar] = @total_resigned_mar
      total[:total_resigned_apr] = @total_resigned_apr
      total[:total_resigned_may] = @total_resigned_may
      total[:total_resigned_jun] = @total_resigned_jun
      total[:total_resigned_jul] = @total_resigned_jul
      total[:total_resigned_aug] = @total_resigned_aug
      total[:total_resigned_sep] = @total_resigned_sep
      total[:total_resigned_oct] = @total_resigned_oct
      total[:total_resigned_nov] = @total_resigned_nov
      total[:total_resigned_dec] = @total_resigned_dec
      
      total[:total_gk] = @total_gk
      total[:total_active_resigned_insurance] = @total_active_resigned_insurance
      total[:total_active_pending] = @total_active_pending
      
      total[:total_valid_dependent] = @total_valid_dependent
      total[:total_valid_dependent_inforce] = @total_valid_dependent_inforce
      total[:total_valid_dependent_lapsed] = @total_valid_dependent_lapsed
      total[:total_valid_dependent_resigned] = @total_valid_dependent_resigned

      @data[:total_members] << total

      @data 
		end
	end
end
