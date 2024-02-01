module Members
  class GenerateMemberIdentificationNumber
    def initialize(member:)
      @member       = member
      @branch       = Branch.find(@member.branch.id)
      @branch_code  = @branch.short_name
      @cluster_code = @branch.cluster.short_name
    end

    def execute!
      current_counter = @branch.member_counter || 1
      
      next_member_counter           = current_counter + 1
      member_identification_number  = @cluster_code + @branch_code + next_member_counter.to_s.rjust(5, "0")

      while Member.where(username: member_identification_number).count >= 1 do
        next_member_counter = next_member_counter + 1
        member_identification_number  = @cluster_code + @branch_code + next_member_counter.to_s.rjust(5, "0")
      end

      member_identification_number
    end
  end
end
