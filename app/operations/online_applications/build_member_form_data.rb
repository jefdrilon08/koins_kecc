module OnlineApplications
  class BuildMemberFormData
    include Rails.application.routes.url_helpers

    attr_accessor :online_application,
                  :data

    def initialize(online_application:)
      @online_application = online_application

      @data = {
        identification_number: "",
        branch: "",
        first_name: "",
        middle_name: "",
        last_name: "",
        mothers_first_name: "",
        mothers_middle_name: "",
        mothers_last_name: "",
        address_province: "",
        address_city: "",
        address_district: "",
        address_street: ""
      }

    end

    def set_children!
      @data[:children] = [
        {
          name: '',
          date_of_birth: '',
          age: '',
          education: '',
          course: ''
        },
        {
          name: '',
          date_of_birth: '',
          age: '',
          education: '',
          course: ''
        },
        {
          name: '',
          date_of_birth: '',
          age: '',
          education: '',
          course: ''
        },
        {
          name: '',
          date_of_birth: '',
          age: '',
          education: '',
          course: ''
        },
        {
          name: '',
          date_of_birth: '',
          age: '',
          education: '',
          course: ''
        }
      ]

      @online_application.data["legal_dependents"].each_with_index do |o, i|
        name          = "#{o["lastName"]}, #{o["firstName"]} #{o["middleName"]}"
        date_of_birth = "#{o["dateOfBirth"]}"
        age           = o["dateOfBirth"].present? ? Date.today.year - o["dateOfBirth"].to_date.year : 0
        education     = o["education"]
        course        = o["course"]

        @data[:children][i][:name]          = name
        @data[:children][i][:date_of_birth] = name
        @data[:children][i][:age]           = age
        @data[:children][i][:education]     = education
        @data[:children][i][:course]        = course
      end
    end

    def set_current_bank!
      if @online_application.data["banks"].any?
        current_bank = @online_application.data["banks"][0]

        @data[:current_bank_name] = current_bank["bank"]
        @data[:current_bank_type] = current_bank["type"]
      else
        @data[:current_bank_name] = ""
        @data[:current_bank_type] = ""
      end
    end

    def num_children_studying
      "(#{@online_application.data["num_children_elementary"]}) Elementary\u200B\t(#{@online_application.data["num_children_high_school"]}) High School\u200B\t(#{@online_application.data["num_children_college"]}) College / Vocational"
    end

    def build_housing_type
      test          = @online_application.data["housing"]["type"]
      housing_type  = "[ ] Pag-aari ang lupa at bahay (may titulo)\n[ ] Umuupa (sharer or renter)\n[ ] Nakikituloy (libre; mga magulang o extended family)\n[ ] Namana o na-award pero wala pang titulo\n[ ] Nagbabayad ng rights sa lupa, pag-aari ang bahay"

      if test == "Pag-aari ang lupa at bahay"
        housing_type  = "[x] Pag-aari ang lupa at bahay (may titulo)\n[ ] Umuupa (sharer or renter)\n[ ] Nakikituloy (libre; mga magulang o extended family)\n[ ] Namana o na-award pero wala pang titulo\n[ ] Nagbabayad ng rights sa lupa, pag-aari ang bahay"
      elsif test == "Umuupa"
        housing_type  = "[ ] Pag-aari ang lupa at bahay (may titulo)\n[x] Umuupa (sharer or renter)\n[ ] Nakikituloy (libre; mga magulang o extended family)\n[ ] Namana o na-award pero wala pang titulo\n[ ] Nagbabayad ng rights sa lupa, pag-aari ang bahay"
      elsif test == "Nakikituloy"
        housing_type  = "[ ] Pag-aari ang lupa at bahay (may titulo)\n[ ] Umuupa (sharer or renter)\n[x] Nakikituloy (libre; mga magulang o extended family)\n[ ] Namana o na-award pero wala pang titulo\n[ ] Nagbabayad ng rights sa lupa, pag-aari ang bahay"
      elsif test == "Namana o na-award pero wala pang titulo"
        housing_type  = "[ ] Pag-aari ang lupa at bahay (may titulo)\n[ ] Umuupa (sharer or renter)\n[ ] Nakikituloy (libre; mga magulang o extended family)\n[x] Namana o na-award pero wala pang titulo\n[ ] Nagbabayad ng rights sa lupa, pag-aari ang bahay"
      elsif test == "Nagbabayad ng Rights sa lupa, pag-aari ng bahay"
        housing_type  = "[ ] Pag-aari ang lupa at bahay (may titulo)\n[ ] Umuupa (sharer or renter)\n[ ] Nakikituloy (libre; mga magulang o extended family)\n[ ] Namana o na-award pero wala pang titulo\n[x] Nagbabayad ng rights sa lupa, pag-aari ang bahay"
      end

      housing_type
    end

    def execute!
      @data[:full_name]           = "#{@online_application.last_name}, #{@online_application.first_name} #{@online_application.middle_name}"
      @data[:control_number]      = @online_application.reference_number
      @data[:branch]              = @online_application.branch.try(:to_s)
      @data[:first_name]          = @online_application.first_name
      @data[:middle_name]         = @online_application.middle_name
      @data[:last_name]           = @online_application.last_name
      @data[:mothers_first_name]  = @online_application.data["mothers_first_name"]
      @data[:mothers_middle_name] = @online_application.data["mothers_middle_name"]
      @data[:mothers_last_name]   = @online_application.data["mothers_last_name"]
      @data[:address_province]    = @online_application.data["address"]["province"]
      @data[:address_district]    = @online_application.data["address"]["district"]
      @data[:address_city]        = @online_application.data["address"]["city"]
      @data[:address_street]      = @online_application.data["address"]["street"]
      @data[:housing_type]        = build_housing_type
      @data[:housing_stay]        = "#{@online_application.data["housing"]["num_years"]} yrs at #{@online_application.data["housing"]["num_months"]} mths"
      @data[:date_of_birth]       = @online_application.date_of_birth
      @data[:age]                 = @online_application.age
      @data[:place_of_birth]      = @online_application.place_of_birth
      @data[:gender]              = @online_application.gender
      @data[:civil_status]        = @online_application.civil_status
      @data[:religion]            = @online_application.religion
      @data[:num_children]        = @online_application.data["num_children"]
      @data[:reason_for_joining]  = @online_application.data["reason_for_joining"]
      @data[:previous_mfi_experience] = @online_application.data["previous_mfi_experience"]
      @data[:num_children_studying] = num_children_studying

      @data[:mobile_number]         = @online_application.mobile_number
      @data[:home_number]           = @online_application.home_number

      @data[:sss_number]        = @online_application.data["government_identification_numbers"]["sss_number"]
      @data[:pagibig_number]    = @online_application.data["government_identification_numbers"]["pagibig_number"]
      @data[:philhealth_number] = @online_application.data["government_identification_numbers"]["philhealth_number"]
      @data[:tin_number]        = @online_application.data["government_identification_numbers"]["tin_number"]

      @data[:spouse_first_name]     = @online_application.data["spouse"]["first_name"]
      @data[:spouse_last_name]      = @online_application.data["spouse"]["last_name"]
      @data[:spouse_middle_name]    = @online_application.data["spouse"]["middle_name"]
      @data[:spouse_occupation]     = @online_application.data["spouse"]["occupation"]
      @data[:spouse_date_of_birth]  = @online_application.data["spouse"]["date_of_birth"]
      @data[:spouse_age]            = @data[:spouse_date_of_birth].present? ? Date.today.year - @data[:spouse_date_of_birth].to_date.year : ""

      set_current_bank!
      set_children!

      @data[:logo]  = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/logo_titled.png").read)

      if @online_application.profile_picture.attached?
        #@data[:profile_picture] = Base64.strict_encode64(URI.open("#{ENV['BASE_URL']}#{rails_blob_path(@online_application.profile_picture, disposition: "attachment", only_path: true)}").read)
        @data[:profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
        #@data[:profile_picture] = @online_application.profile_picture
      else
        @data[:profile_picture] = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/1x1.png").read)
      end

      @data
    end
  end
end
