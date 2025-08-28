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
          city: "",
          province: "",
          region: "",
          old_district: "",
          old_city: ""
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
        # legal_dependents: [],
        beneficiaries: [],
        project_types: []
      }

      legal_dependents  = @member.legal_dependents.map{ |o|
                            {
                              id: o.id,
                              first_name: o.first_name,
                              last_name: o.last_name,
                              date_of_birth: o.date_of_birth,
                              relationship: o.relationship,
                              age: o.age,
                              data: o.data.with_indifferent_access
                            }
                          }

      branch                  = @member.branch
      center                  = @member.center
      membership_arrangement  = @member.membership_arrangement
      membership_type         = @member.membership_type
      referrer                = @member.referrer
      coordinator             = Referrer.where(id: @member.coordinator_id).first
  
      @member_data  = {
        id: @member.id || "",
        identification_number: @member.identification_number || "",
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
        data: @member.new_record? ? data : @member.data.with_indifferent_access,
        branch_id: branch.try(:id) || "",
        branch_name: branch.try(:name) || "",
        center_id: center.try(:id) || "",
        center_name: center.try(:name) || "",
        membership_arrangement_id: membership_arrangement.try(:id) || "",
        membership_arrangement_name: membership_arrangement.try(:name) || "",
        membership_type_id: membership_type.try(:id) || "",
        membership_type_name: membership_type.try(:name) || "",
        beneficiaries: @member.beneficiaries,
        legal_dependents: legal_dependents,
        referrer_id: referrer.try(:id) || "",
        referrer_name: referrer.try(:full_name) || "",
        coordinator_id: coordinator.try(:id) || "",
        coordinator_name: coordinator.try(:full_name) || "",
      }

      # Setup old values
      @member_data[:data][:address]["old_district"]  = @member_data[:data][:address]["district"]

      @member_data[:data][:address]["old_city"]  = @member_data[:data][:address]["city"]

      @member_data
    end
  end
end
