module Members
  class Fetch
    def initialize(config:)
      @config = config

      @member = Member.where(id: @config[:id]).first

      if @member.blank?
        @member = Member.new
      end
    end

    def execute!
      data  = {
        address: {
          street: "",
          district: "",
          city: ""
        },
        spouse: {
          first_name: "",
          middle_name: "",
          last_name: "",
          date_of_birth: "",
          occupation: ""
        },
        government_identification_numbers: {
          sss_number: "",
          pag_ibig_number: "",
          phil_health_number: "",
          tin_number: ""
        },
        num_children_elementary: 0,
        num_children_high_school: 0,
        num_children_college: 0,
        num_children: 0,
        reason_for_joining: "",
        housing: {
          type: "",
          num_months: 0,
          num_years: 0,
          proof: ""
        },
        banks: [],
        legal_dependents: [],
        beneficiaries: []
      }

      @member_data  = {
        id: @member.id || "",
        first_name: @member.first_name || "",
        middle_name: @member.middle_name || "",
        last_name: @member.last_name || "",
        gender: @member.gender || "Female",
        date_of_birth: @member.date_of_birth,
        civil_status: @member.civil_status || "Single",
        home_number: @member.home_number || "",
        mobile_number: @member.mobile_number || "",
        place_of_birth: @member.place_of_birth || "",
        member_type: @member.member_type || "Regular",
        religion: @member.religion || "",
        data: @member.new_record? ? data : @member.data,
        branch_id: @member.branch.try(:id) || "",
        branch_name: @member.branch.try(:name) || "",
        center_id: @member.center.try(:id) || "",
        center_name: @member.center.try(:name) || "",
        legal_dependents: @member.legal_dependents,
        beneficiaries: @member.beneficiaries
      }

      @member_data
    end
  end
end
