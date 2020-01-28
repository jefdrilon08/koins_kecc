module Reports
	class MemberQuarterlyReports
		def initialize(start_date:, end_date:)
      @start_date       =  start_date.to_date
      @end_date         =  end_date.to_date
      
      if @start_date.present? && @end_date.present?
        @active_members         = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status != ?", @end_date, "dormant")
        @active_lapsed_members  = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "lapsed")
        @active_inforce_members = Member.active.where("data ->> 'recognition_date' <= ? AND insurance_status = ?", @end_date, "inforce")
        @resigned_members       = Member.resigned.where("date_resigned >= ? AND date_resigned <= ?", @start_date, @end_date)
        @new_members            = Member.active.where("data ->> 'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND insurance_status != ?", @start_date, @end_date, "dormant")
        @male_members           = @active_members.where(gender: "Male")
        @female_members         = @active_members.where(gender: "Female")
        @members_with_spouse    = @active_members.where("data -> 'spouse' ->> 'first_name' = ?", '')
        @single_members         = @active_members.where(civil_status: "Single")
        @married_members        = @active_members.where(civil_status: "Kasal") 
        @maykinakasama_members  = @active_members.where(civil_status: "May Kinakasama")
        @hiwalay_members        = @active_members.where(civil_status: 'Hiwalay')
        @biyuda_members         = @active_members.where(civil_status: "Biyudo/a")

      else
        @all_members            = Member.all.order("last_name ASC")
      end
    end

		def execute!
			@data = {}
      @data[:members] = []
      @data[:total_members] = []

      @total_active = 0
      @total_active_lapsed = 0
      @total_active_inforce = 0
      @total_new = 0
      @total_resigned = 0
      @total_female = 0
      @total_male = 0
      @total_with_spouse = 0
      @total_valid_dependent = 0
      @total_single = 0
      @total_married = 0
      @total_maykinakasama = 0
      @total_hiwalay = 0
      @total_biyuda = 0

      Branch.all.order("cluster_id ASC").each do |branch|
        member = {}
        
        member[:branch] = branch.name
        member[:active_count] = @active_members.where(branch_id: branch).count
        member[:active_lapsed_count] = @active_lapsed_members.where(branch_id: branch).count
        member[:active_inforce_count] = @active_inforce_members.where(branch_id: branch).count
        member[:resigned_count] = @resigned_members.where(branch_id: branch).count
        member[:new_count] = @new_members.where(branch_id: branch).count
        member[:male_count] = @male_members.where(branch_id: branch).count
        member[:female_count] = @female_members.where(branch_id: branch).count
        member[:member_with_spouse_count] = @members_with_spouse.where(branch_id: branch).count
        member[:valid_dependent_count] = LegalDependent.joins(:member).where("members.branch_id = ? AND members.data ->> 'recognition_date' <= ?", branch, @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        member[:single] = @single_members.where(branch_id: branch).count
        member[:married] = @married_members.where(branch_id: branch).count
        member[:maykinakasama] = @maykinakasama_members.where(branch_id: branch).count
        member[:hiwalay] = @hiwalay_members.where(branch_id: branch).count
        member[:biyuda] = @biyuda_members.where(branch_id: branch).count

        @total_resigned += @resigned_members.where(branch_id: branch).count
        @total_new += @new_members.where(branch_id: branch).count
        @total_active += @active_members.where(branch_id: branch).count
        @total_active_lapsed += @active_lapsed_members.where(branch_id: branch).count
        @total_active_inforce += @active_inforce_members.where(branch_id: branch).count
        @total_male += @male_members.where(branch_id: branch).count
        @total_female += @female_members.where(branch_id: branch).count
        @total_with_spouse += @members_with_spouse.where(branch_id: branch).count
        # @total_female += @female_members.where(branch_id: branch).count
        @total_valid_dependent += LegalDependent.joins(:member).where("members.branch_id = ? AND members.data ->> 'recognition_date' <= ?", branch, @end_date).where("legal_dependents.date_of_birth::date >= ?",20.years.ago).count
        @total_single += @single_members.where(branch_id: branch).count
        @total_married += @married_members.where(branch_id: branch).count
        @total_maykinakasama += @maykinakasama_members.where(branch_id: branch).count
        @total_hiwalay += @hiwalay_members.where(branch_id: branch).count
        @total_biyuda += @biyuda_members.where(branch_id: branch).count
        @data[:members] << member
      end

      total = {}
      total[:total_resigned] = @total_resigned
      total[:total_new] = @total_new
      total[:total_active] = @total_active
      total[:total_active_lapsed] = @total_active_lapsed
      total[:total_active_inforce] = @total_active_inforce
      total[:total_male] = @total_male
      total[:total_female] = @total_female
      total[:total_with_spouse] = @total_with_spouse
      total[:total_valid_dependent] = @total_valid_dependent
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
