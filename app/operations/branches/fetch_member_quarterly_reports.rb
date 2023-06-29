module Branches
  class FetchMemberQuarterlyReports
    def initialize(config:)
      @config = config
      @as_of    = @config[:as_of].try(:to_date) || Date.today
      @start_date = Date.today.beginning_of_year
      @end_date = @start_date.end_of_quarter

      if @start_date.present? && @end_date.present?
        @active_members             = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status IN (?)", @end_date, ["inforce", "lapsed"])
        @resigned_before            = Member.where("data ->> 'recognition_date' <= ? AND insurance_date_resigned >= ?", @end_date, @end_date)
            
        @gk_members                 = Member.where("status = ? AND member_type = ?", "active", "GK")
        
        # inforce
        @active_inforce_members     = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "inforce")
        @resigned_before_inforce    = ::Members::FetchInsuranceMembers.new(config: {members: @resigned_before, as_of: @end_date, insurance_status: "inforce"}).execute!
        @all_inforce                = @active_inforce_members + @resigned_before_inforce

        #lapse
        @active_lapsed_members      = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "lapsed")
        @resigned_before_lapsed     = ::Members::FetchInsuranceMembers.new(config: {members: @resigned_before, as_of: @end_date, insurance_status: "lapsed"}).execute!
        @all_lapsed                 = @active_lapsed_members + @resigned_before_lapsed           

        # dormant
        @active_dormant_members     = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "dormant")
        @resigned_before_dormant    = ::Members::FetchInsuranceMembers.new(config: {members: @resigned_before, as_of: @end_date, insurance_status: "dormant"}).execute!
        @all_dormant                = @active_dormant_members + @resigned_before_dormant
        
        @all_active_members         = @all_inforce
        
        @resigned_members           = Member.insurance_resigned.where("insurance_date_resigned >= ? AND insurance_date_resigned <= ?", @start_date, @end_date)
        @all_resigned_members       = Member.insurance_resigned.where("insurance_date_resigned <= ?", @end_date)
        @active_resigned_insurance  = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "resigned")
        
        @resigned_old_members       = @all_resigned_members - @resigned_members

        #resigned MFI
        @resigned_inforce           = Member.where("status = ? AND insurance_status = ? AND date_resigned <= ?", "resigned", "inforce", @end_date)
        @resigned_lapsed            = Member.where("status = ? AND insurance_status = ? AND date_resigned <= ?", "resigned", "lapsed", @end_date)
        @resigned_dormant           = Member.where("status = ? AND insurance_status = ? AND date_resigned <= ?", "resigned", "dormant", @end_date)

        @pending                    = Member.active.where("created_at <= ? AND insurance_status = ? AND member_type = ?", @end_date, "pending", "Regular")
        @new_members                = Member.active.where("data ->> 'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND insurance_status IN (?)", @start_date, @end_date, ["inforce", "lapsed", "dormant"])
        
        @male_members               = @all_active_members.select{|o| o[:gender] == "Male"}
        @female_members             = @all_active_members.select{|o| o[:gender] == "Female"}

        @members_with_spouse        = @all_active_members.select{|o| o.data["spouse"]["first_name"] != nil}
        
        @single_members             = @all_active_members.select{|o| o[:civil_status] == "Single"}
        @single_male_members        = @all_active_members.select{|o| o[:civil_status] == "Single" && o[:gender] == "Male"}
        @single_female_members      = @all_active_members.select{|o| o[:civil_status] == "Single" && o[:gender] == "Female"}

        @married_members            = @all_active_members.select{|o| o[:civil_status] == "Kasal"}
        @married_male_members       = @all_active_members.select{|o| o[:civil_status] == "Kasal" && o[:gender] == "Male"}
        @married_female_members     = @all_active_members.select{|o| o[:civil_status] == "Kasal" && o[:gender] == "Female"}
        
        @maykinakasama_members      = @all_active_members.select{|o| o[:civil_status] == "May Kinakasama"}
        @maykinakasama_male_members      = @all_active_members.select{|o| o[:civil_status] == "May Kinakasama" && o[:gender] == "Male"}
        @maykinakasama_female_members      = @all_active_members.select{|o| o[:civil_status] == "May Kinakasama" && o[:gender] == "Female"}
        
        @hiwalay_members            = @all_active_members.select{|o| o[:civil_status] == "Hiwalay"}
        @hiwalay_male_members            = @all_active_members.select{|o| o[:civil_status] == "Hiwalay" && o[:gender] == "Male"}
        @hiwalay_female_members            = @all_active_members.select{|o| o[:civil_status] == "Hiwalay" && o[:gender] == "Female"}


        
        @biyuda_members             = @all_active_members.select{|o| o[:civil_status] == "Biyudo/a"}
        @biyuda_male_members             = @all_active_members.select{|o| o[:civil_status] == "Biyudo/a" && o[:gender] == "Male"}
        @biyuda_female_members             = @all_active_members.select{|o| o[:civil_status] == "Biyudo/a" && o[:gender] == "Female"}

      else
        @all_members                = Member.all.order("last_name ASC")
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
      @total_resigned_old = 0
      @total_pending = 0
      @total_active_resigned_insurance = 0
      #@total_resigned_before = 0
      @total_resigned_before_inforce = 0
      @total_resigned_before_lapsed = 0
      @total_resigned_before_dormant = 0
      @total_male = 0
      @total_female = 0
      @total_gk = 0
      @total_valid_dependent = 0
      @total_with_spouse = 0
      
      @total_single = 0
      @total_single_male = 0
      @total_single_female = 0
      
      @total_biyuda = 0
      @total_biyuda_male = 0
      @total_biyuda_female = 0
      
      @total_married = 0
      @total_married_male = 0
      @total_married_female = 0
      
      @total_maykinakasama = 0
      @total_maykinakasama_male = 0
      @total_maykinakasama_female = 0
      
      @total_hiwalay = 0
      @total_hiwalay_male = 0
      @total_hiwalay_female = 0

      @total_inforce_male = 0
      @total_inforce_female = 0
      
      @total_lapsed_male = 0
      @total_lapsed_female = 0
      
      @total_dormant_male = 0
      @total_dormant_female = 0

      @total_resigned_male = 0
      @total_resigned_female = 0
      
      @total_resigned_inforce = 0
      @total_resigned_lapsed = 0
      @total_resigned_dormant = 0

      Branch.all.order("cluster_id ASC").each do |branch|
        member = {}
        
        member[:branch] = branch.name
        
        member[:gk_count] = @gk_members.where(branch_id: branch).count
        member[:active_count] = @all_active_members.select{|o| o[:branch_id] == branch.id}.count
        member[:all_resigned_count] = @all_resigned_members.where(branch_id: branch).count
        member[:active_lapsed_count] = @all_lapsed.select{|o| o[:branch_id] == branch.id}.count
        member[:active_inforce_count] = @all_inforce.select{|o| o[:branch_id] == branch.id}.count
        member[:active_dormant_count] = @all_dormant.select{|o| o[:branch_id] == branch.id}.count
        member[:resigned_count] = @resigned_members.where(branch_id: branch).count
        member[:resigned_old_count] = @resigned_old_members.select{|o| o[:branch_id] == branch.id}.count
        member[:new_count] = @new_members.where(branch_id: branch).count
        member[:pending] = @pending.where(branch_id: branch).count
        member[:active_resigned_insurance] = @active_resigned_insurance.where(branch_id: branch).count
        
        member[:male_inforce_count] = @all_inforce.select{|o| o[:branch_id] == branch.id and o[:gender] == "Male"}.count
        member[:female_inforce_count] = @all_inforce.select{|o| o[:branch_id] == branch.id and o[:gender] == "Female"}.count

        member[:male_dormant_count] = @all_dormant.select{|o| o[:branch_id] == branch.id and o[:gender] == "Male"}.count
        member[:female_dormant_count] = @all_dormant.select{|o| o[:branch_id] == branch.id and o[:gender] == "Female"}.count
        
        member[:male_lapsed_count] = @all_lapsed.select{|o| o[:branch_id] == branch.id and o[:gender] == "Male"}.count
        member[:female_lapsed_count] = @all_lapsed.select{|o| o[:branch_id] == branch.id and o[:gender] == "Female"}.count

        member[:male_resigned_count] = @resigned_members.where(branch_id: branch, gender: "Male").count
        member[:female_resigned_count] = @resigned_members.where(branch_id: branch, gender: "Female").count
        
        member[:male_count] = @male_members.select{|o| o[:branch_id] == branch.id}.count
        member[:female_count] = @female_members.select{|o| o[:branch_id] == branch.id}.count
        member[:member_with_spouse_count] = @members_with_spouse.select{|o| o[:branch_id] == branch.id}.count
        member[:valid_dependent_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.data ->> 'recognition_date' <= ?", branch, @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count + member[:member_with_spouse_count]
        
        member[:resigned_inforce_count] = @resigned_inforce.where(branch_id: branch).count
        member[:resigned_lapsed_count] = @resigned_lapsed.where(branch_id: branch).count
        member[:resigned_dormant_count] = @resigned_dormant.where(branch_id: branch).count
        
        member[:single] = @single_members.select{|o| o[:branch_id] == branch.id}.count
        member[:single_male_members] = @single_male_members.select{|o| o[:branch_id] == branch.id}.count
        member[:single_female_members] = @single_female_members.select{|o| o[:branch_id] == branch.id}.count
        
        member[:married] = @married_members.select{|o| o[:branch_id] == branch.id}.count
        member[:married_male_members] = @married_male_members.select{|o| o[:branch_id] == branch.id}.count
        member[:married_female_members] = @married_female_members.select{|o| o[:branch_id] == branch.id}.count
        
        member[:maykinakasama] = @maykinakasama_members.select{|o| o[:branch_id] == branch.id}.count
        member[:maykinakasama_male_members] = @maykinakasama_male_members.select{|o| o[:branch_id] == branch.id}.count
        member[:maykinakasama_female_members] = @maykinakasama_female_members.select{|o| o[:branch_id] == branch.id}.count

        member[:hiwalay] = @hiwalay_members.select{|o| o[:branch_id] == branch.id}.count
        member[:hiwalay_male_members] = @hiwalay_male_members.select{|o| o[:branch_id] == branch.id}.count
        member[:hiwalay_female_members] = @hiwalay_female_members.select{|o| o[:branch_id] == branch.id}.count

        member[:biyuda] = @biyuda_members.select{|o| o[:branch_id] == branch.id}.count
        member[:biyuda_male_members] = @biyuda_male_members.select{|o| o[:branch_id] == branch.id}.count
        member[:biyuda_female_members] = @biyuda_female_members.select{|o| o[:branch_id] == branch.id}.count

        @total_resigned += @resigned_members.where(branch_id: branch).count
        @total_resigned_old += @resigned_old_members.select{|o| o[:branch_id] == branch.id}.count
        @total_all_resigned += @all_resigned_members.where(branch_id: branch).count
        @total_new += @new_members.where(branch_id: branch).count
        @total_active += @all_active_members.select{|o| o[:branch_id] == branch.id}.count
        @total_active_lapsed += @all_lapsed.select{|o| o[:branch_id] == branch.id}.count
        @total_active_inforce += @all_inforce.select{|o| o[:branch_id] == branch.id}.count
        @total_active_dormant += @all_dormant.select{|o| o[:branch_id] == branch.id}.count
        @total_pending += @pending.where(branch_id: branch).count
        @total_active_resigned_insurance += @active_resigned_insurance.where(branch_id: branch).count
        @total_male += @male_members.select{|o| o[:branch_id] == branch.id}.count
        @total_gk += @gk_members.where(branch_id: branch).count
        @total_female += @female_members.select{|o| o[:branch_id] == branch.id}.count
        @total_with_spouse += @members_with_spouse.select{|o| o[:branch_id] == branch.id}.count
        @total_valid_dependent += LegalDependent.joins(:member).where("members.branch_id = ? AND members.data ->> 'recognition_date' <= ?", branch, @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count

        @total_inforce_male += @all_inforce.select{|o| o[:branch_id] == branch.id and o[:gender] == "Male"}.count
        @total_inforce_female += @all_inforce.select{|o| o[:branch_id] == branch.id and o[:gender] == "Female"}.count

        @total_lapsed_male += @all_lapsed.select{|o| o[:branch_id] == branch.id and o[:gender] == "Male"}.count
        @total_lapsed_female += @all_lapsed.select{|o| o[:branch_id] == branch.id and o[:gender] == "Female"}.count

        @total_dormant_male += @all_dormant.select{|o| o[:branch_id] == branch.id and o[:gender] == "Male"}.count
        @total_dormant_female += @all_dormant.select{|o| o[:branch_id] == branch.id and o[:gender] == "Female"}.count
        
        @total_resigned_male += @resigned_members.where(branch_id: branch, gender: "Male").count
        @total_resigned_female += @resigned_members.where(branch_id: branch, gender: "Female").count
        
        @total_resigned_inforce += @resigned_inforce.where(branch_id: branch).count
        @total_resigned_lapsed += @resigned_lapsed.where(branch_id: branch).count
        @total_resigned_dormant += @resigned_dormant.where(branch_id: branch).count
        
        @total_single += @single_members.select{|o| o[:branch_id] == branch.id}.count
        @total_single_male += @single_male_members.select{|o| o[:branch_id] == branch.id}.count
        @total_single_female += @single_female_members.select{|o| o[:branch_id] == branch.id}.count

        @total_married += @married_members.select{|o| o[:branch_id] == branch.id}.count
        @total_married_male += @married_male_members.select{|o| o[:branch_id] == branch.id}.count
        @total_married_female += @married_female_members.select{|o| o[:branch_id] == branch.id}.count

        @total_maykinakasama += @maykinakasama_members.select{|o| o[:branch_id] == branch.id}.count
        @total_maykinakasama_male += @maykinakasama_male_members.select{|o| o[:branch_id] == branch.id}.count
        @total_maykinakasama_female += @maykinakasama_female_members.select{|o| o[:branch_id] == branch.id}.count

        @total_hiwalay += @hiwalay_members.select{|o| o[:branch_id] == branch.id}.count
        @total_hiwalay_male += @hiwalay_male_members.select{|o| o[:branch_id] == branch.id}.count
        @total_hiwalay_female += @hiwalay_female_members.select{|o| o[:branch_id] == branch.id}.count

        @total_biyuda += @biyuda_members.select{|o| o[:branch_id] == branch.id}.count
        @total_biyuda_male += @biyuda_male_members.select{|o| o[:branch_id] == branch.id}.count
        @total_biyuda_female += @biyuda_female_members.select{|o| o[:branch_id] == branch.id}.count

        @data[:members] << member
      end

      @total = {}
      @total[:total_gk] = @total_gk
      @total[:total_resigned] = @total_resigned
      @total[:total_resigned_old] = @total_resigned_old
      @total[:total_all_resigned] = @total_all_resigned
      @total[:total_new] = @total_new
      @total[:total_active] = @total_active
      @total[:total_active_lapsed] = @total_active_lapsed
      @total[:total_active_inforce] = @total_active_inforce
      @total[:total_active_dormant] = @total_active_dormant
      @total[:total_pending] = @total_pending
      @total[:total_active_resigned_insurance] = @total_active_resigned_insurance
      @total[:total_male] = @total_male
      @total[:total_inforce_male] = @total_inforce_male
      @total[:total_inforce_female] = @total_inforce_female
      @total[:total_dormant_male] = @total_dormant_male
      @total[:total_dormant_female] = @total_dormant_female
      @total[:total_lapsed_male] = @total_lapsed_male
      @total[:total_lapsed_female] = @total_lapsed_female
      @total[:total_resigned_male] = @total_resigned_male
      @total[:total_resigned_female] = @total_resigned_female
      @total[:total_female] = @total_female
      @total[:total_with_spouse] = @total_with_spouse
      @total[:total_valid_dependent] = @total_valid_dependent + @total_with_spouse
      
      @total[:total_single] = @total_single
      @total[:total_single_male] = @total_single_male
      @total[:total_single_female] = @total_single_female
      
      @total[:total_married] = @total_married
      @total[:total_married_male] = @total_married_male
      @total[:total_married_female] = @total_married_female

      @total[:total_maykinakasama] = @total_maykinakasama
      @total[:total_maykinakasama_male] = @total_maykinakasama_male
      @total[:total_maykinakasama_female] = @total_maykinakasama_female

      @total[:total_hiwalay] = @total_hiwalay
      @total[:total_hiwalay_male] = @total_hiwalay_male
      @total[:total_hiwalay_female] = @total_hiwalay_female

      @total[:total_biyuda] = @total_biyuda
      @total[:total_biyuda_male] = @total_biyuda_male
      @total[:total_biyuda_female] = @total_biyuda_female

      @total[:total_resigned_inforce] = @total_resigned_inforce
      @total[:total_resigned_lapsed] = @total_resigned_lapsed
      @total[:total_resigned_dormant] = @total_resigned_dormant
      
      @data[:total_members] << @total

      @data 
    end
  end
end