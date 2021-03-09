module Reports
	class MemberQuarterlyReports
		def initialize(start_date:, end_date:)
      @start_date       =  start_date.to_date
      @end_date         =  end_date.to_date
      
      if @start_date.present? && @end_date.present?
        @active_members             = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status IN (?)", @end_date, ["inforce", "lapsed", "dormant"])
        @resigned_before            = Member.where("data ->> 'recognition_date' <= ? AND insurance_date_resigned >= ?", @end_date, @end_date)
        
        @resigned_before_inforce    = ::Members::FetchInsuranceMembers.new(config: {members: @resigned_before, as_of: @end_date, insurance_status: "inforce"}).execute!
        @resigned_before_lapsed     = ::Members::FetchInsuranceMembers.new(config: {members: @resigned_before, as_of: @end_date, insurance_status: "lapsed"}).execute!
        @resigned_before_dormant    = ::Members::FetchInsuranceMembers.new(config: {members: @resigned_before, as_of: @end_date, insurance_status: "dormant"}).execute!
        
        @gk_members                 = Member.where("member_type = ?", "GK")
        @active_lapsed_members      = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "lapsed")
        @active_inforce_members     = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "inforce")
        @active_dormant_members     = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "dormant")
        
        @resigned_members           = Member.insurance_resigned.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @start_date, @end_date)
        @all_resigned_members       = Member.insurance_resigned.where("insurance_date_resigned <= ?", @end_date)
        @active_resigned_insurance  = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "resigned")
        
        @pending                    = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "pending")
        @new_members                = Member.active.where("data ->> 'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND insurance_status IN (?)", @start_date, @end_date, ["inforce", "lapsed"])
        
        @male_members               = @active_members.where(gender: "Male")
        @female_members             = @active_members.where(gender: "Female")

        @members_with_spouse        = @active_members.where("data -> 'spouse' ->> 'first_name' = ?", '')
        @single_members             = @active_members.where(civil_status: "Single")
        @married_members            = @active_members.where(civil_status: "Kasal") 
        @maykinakasama_members      = @active_members.where(civil_status: "May Kinakasama")
        @hiwalay_members            = @active_members.where(civil_status: 'Hiwalay')
        @biyuda_members             = @active_members.where(civil_status: "Biyudo/a")

        @all_active_members         = @active_members + @resigned_before_inforce + @resigned_before_lapsed + @resigned_before_dormant
      else
        @all_members            = Member.all.order("last_name ASC")
      end
    end

		def execute!
			@data = {}
      @data[:members] = []
      @data[:total_members] = []

      @total_active = 0
      @total_all_resigned = 0
      @total_active_lapsed = 0
      @total_active_inforce = 0
      @total_active_dormant = 0
      @total_new = 0
      @total_resigned = 0
      @total_pending = 0
      @total_active_resigned_insurance = 0
      @total_resigned_before = 0
      @total_resigned_before_inforce = 0
      @total_resigned_before_lapsed = 0
      @total_resigned_before_dormant = 0
      @total_male = 0
      @total_gk = 0
      # @total_inforce_male = 0
      # @total_lapsed_male = 0
      # @total_resigned_male = 0
      @total_female = 0
      # @total_inforce_female = 0
      # @total_lapsed_female = 0
      # @total_resigned_female = 0
      @total_with_spouse = 0
      # @total_inforce_with_spouse = 0
      # @total_lapsed_with_spouse = 0
      # @total_resigned_with_spouse = 0
      @total_valid_dependent = 0
      # @total_valid_dependent_inforce = 0
      # @total_valid_dependent_lapsed = 0
      # @total_valid_dependent_resigned = 0
      @total_single = 0
      @total_married = 0
      @total_maykinakasama = 0
      @total_hiwalay = 0
      @total_biyuda = 0

      Branch.all.order("cluster_id ASC").each do |branch|
        member = {}
        
        member[:branch] = branch.name
        
        member[:gk_count] = @gk_members.where(branch_id: branch).count
        member[:active_count] = @active_members.where(branch_id: branch).count
        member[:all_resigned_count] = @all_resigned_members.where(branch_id: branch).count
        member[:active_lapsed_count] = @active_lapsed_members.where(branch_id: branch).count
        member[:active_inforce_count] = @active_inforce_members.where(branch_id: branch).count
        member[:active_dormant_count] = @active_dormant_members.where(branch_id: branch).count
        member[:resigned_count] = @resigned_members.where(branch_id: branch).count
        member[:new_count] = @new_members.where(branch_id: branch).count
        member[:pending] = @pending.where(branch_id: branch).count
        member[:active_resigned_insurance] = @active_resigned_insurance.where(branch_id: branch).count
        member[:resigned_before] = @resigned_before.where(branch_id: branch).count
        member[:resigned_before_inforce] = @resigned_before_inforce.select{|o| o[:branch_id] == branch}.count
        member[:resigned_before_lapsed] = @resigned_before_lapsed.select{|o| o[:branch_id] == branch}.count
        member[:resigned_before_dormant] = @resigned_before_dormant.select{|o| o[:branch_id] == branch}.count
        
        member[:male_count] = @male_members.where(branch_id: branch).count
        # member[:male_inforce_count] = @active_inforce_members.where(branch_id: branch, gender: "Male").count
        # member[:male_lapsed_count] = @active_lapsed_members.where(branch_id: branch, gender: "Male").count
        # member[:male_resigned_count] = @all_resigned_members.where(branch_id: branch, gender: "Male").count
        member[:female_count] = @female_members.where(branch_id: branch).count
        # member[:female_inforce_count] = @active_inforce_members.where(branch_id: branch, gender: "Female").count
        # member[:female_lapsed_count] = @active_lapsed_members.where(branch_id: branch, gender: "Female").count
        # member[:female_resigned_count] = @all_resigned_members.where(branch_id: branch, gender: "Female").count
        member[:member_with_spouse_count] = @members_with_spouse.where(branch_id: branch).count
        # member[:member_inforce_with_spouse_count] = @members_with_spouse.where(branch_id: branch, insurance_status: "inforce").count
        # member[:member_lapsed_with_spouse_count] = @members_with_spouse.where(branch_id: branch, insurance_status: "lapsed").count
        # member[:member_resigned_with_spouse_count] = @all_resigned_members.where("branch_id = ? AND data -> 'spouse' ->> 'first_name' = ?", branch, '').count
        member[:valid_dependent_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.data ->> 'recognition_date' <= ?", branch, @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        # member[:valid_dependent_inforce_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.insurance_status = ? AND members.data ->> 'recognition_date' <= ?", branch, "inforce", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        # member[:valid_dependent_lapsed_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.insurance_status = ? AND members.data ->> 'recognition_date' <= ?", branch, "lapsed", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        # member[:valid_dependent_resigned_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.status = ? AND members.date_resigned <= ?", branch, "resigned", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        member[:single] = @single_members.where(branch_id: branch).count
        member[:married] = @married_members.where(branch_id: branch).count
        member[:maykinakasama] = @maykinakasama_members.where(branch_id: branch).count
        member[:hiwalay] = @hiwalay_members.where(branch_id: branch).count
        member[:biyuda] = @biyuda_members.where(branch_id: branch).count

        @total_resigned += @resigned_members.where(branch_id: branch).count
        @total_all_resigned += @all_resigned_members.where(branch_id: branch).count
        @total_new += @new_members.where(branch_id: branch).count
        @total_active += @active_members.where(branch_id: branch).count
        @total_active_lapsed += @active_lapsed_members.where(branch_id: branch).count
        @total_active_inforce += @active_inforce_members.where(branch_id: branch).count
        @total_pending += @pending.where(branch_id: branch).count
        @total_active_resigned_insurance += @active_resigned_insurance.where(branch_id: branch).count
        @total_resigned_before += @resigned_before.where(branch_id: branch).count
        @total_resigned_before_inforce += @resigned_before_inforce.select{|o| o[:branch_id] == branch}.count
        @total_resigned_before_lapsed += @resigned_before_lapsed.select{|o| o[:branch_id] == branch}.count
        @total_resigned_before_dormant += @resigned_before_dormant.select{|o| o[:branch_id] == branch}.count
        @total_male += @male_members.where(branch_id: branch).count
        @total_gk += @gk_members.where(branch_id: branch).count
        # @total_inforce_male += @active_inforce_members.where(branch_id: branch, gender: "Male").count
        # @total_lapsed_male += @active_lapsed_members.where(branch_id: branch, gender: "Male").count
        # @total_resigned_male += @all_resigned_members.where(branch_id: branch, gender: "Male").count
        @total_female += @female_members.where(branch_id: branch).count
        # @total_inforce_female += @active_inforce_members.where(branch_id: branch, gender: "Female").count
        # @total_lapsed_female += @active_lapsed_members.where(branch_id: branch, gender: "Female").count
        # @total_resigned_female += @all_resigned_members.where(branch_id: branch, gender: "Female").count
        @total_with_spouse += @members_with_spouse.where(branch_id: branch).count
        # @total_inforce_with_spouse += @members_with_spouse.where(branch_id: branch, insurance_status: "inforce").count
        # @total_lapsed_with_spouse += @members_with_spouse.where(branch_id: branch, insurance_status: "lapsed").count
        # @total_resigned_with_spouse += @all_resigned_members.where("branch_id = ? AND data -> 'spouse' ->> 'first_name' = ?", branch, '').count
        # @total_female += @female_members.where(branch_id: branch).count
        @total_valid_dependent += LegalDependent.joins(:member).where("members.branch_id = ? AND members.data ->> 'recognition_date' <= ?", branch, @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        # @total_valid_dependent_inforce += LegalDependent.joins(:member).where("members.branch_id = ? AND members.insurance_status = ? AND members.data ->> 'recognition_date' <= ?", branch, "inforce", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        # @total_valid_dependent_lapsed += LegalDependent.joins(:member).where("members.branch_id = ? AND members.insurance_status = ? AND members.data ->> 'recognition_date' <= ?", branch, "lapsed", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        # @total_valid_dependent_resigned += LegalDependent.joins(:member).where("members.branch_id = ? AND members.status = ? AND members.date_resigned <= ?", branch, "resigned", @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        @total_single += @single_members.where(branch_id: branch).count
        @total_married += @married_members.where(branch_id: branch).count
        @total_maykinakasama += @maykinakasama_members.where(branch_id: branch).count
        @total_hiwalay += @hiwalay_members.where(branch_id: branch).count
        @total_biyuda += @biyuda_members.where(branch_id: branch).count
        @data[:members] << member
      end

      total = {}
      total[:total_gk] = @total_gk
      total[:total_resigned] = @total_resigned
      total[:total_all_resigned] = @total_all_resigned
      total[:total_new] = @total_new
      total[:total_active] = @total_active + @total_resigned_before_lapsed + @total_resigned_before_inforce + @total_resigned_before_dormant
      total[:total_active_lapsed] = @total_active_lapsed + @total_resigned_before_lapsed
      total[:total_active_inforce] = @total_active_inforce + @total_resigned_before_inforce
      total[:total_active_dormant] = @total_active_dormant + @total_resigned_before_dormant
      total[:total_pending] = @total_pending
      total[:total_active_resigned_insurance] = @total_active_resigned_insurance
      total[:total_male] = @total_male
      # total[:total_inforce_male] = @total_inforce_male
      # total[:total_lapsed_male] = @total_lapsed_male
      # total[:total_resigned_male] = @total_resigned_male
      total[:total_female] = @total_female
      # total[:total_inforce_female] = @total_inforce_female
      # total[:total_lapsed_female] = @total_lapsed_female
      # total[:total_resigned_female] = @total_resigned_female
      total[:total_with_spouse] = @total_with_spouse
      # total[:total_inforce_with_spouse] = @total_inforce_with_spouse
      # total[:total_lapsed_with_spouse] = @total_lapsed_with_spouse
      # total[:total_resigned_with_spouse] = @total_resigned_with_spouse
      total[:total_valid_dependent] = @total_valid_dependent
      # total[:total_valid_dependent_inforce] = @total_valid_dependent_inforce
      # total[:total_valid_dependent_lapsed] = @total_valid_dependent_lapsed
      # total[:total_valid_dependent_resigned] = @total_valid_dependent_resigned
      total[:total_single] = @total_single
      total[:total_married] = @total_married
      total[:total_maykinakasama] = @total_maykinakasama
      total[:total_hiwalay] = @total_hiwalay
      total[:total_biyuda] = @total_biyuda

      @data[:total_members] << total

      @data 
		end
	end
end
