module OnlineApplications
  class Process
    attr_accessor :online_application,
                  :member_data,
                  :member,
                  :branch,
                  :center,
                  :user

    def initialize(online_application:, user:)
      @online_application = online_application
      @branch             = online_application.branch
      @center             = online_application.center
      @user               = user
    end

    def execute!
      @member_data = {
        branch_id:                  @branch.id,
        center_id:                  @center.id,
        first_name:                 @online_application.first_name,
        middle_name:                @online_application.middle_name,
        last_name:                  @online_application.last_name,
        gender:                     @online_application.gender,
        date_of_birth:              @online_application.date_of_birth,
        civil_status:               @online_application.civil_status,
        home_number:                @online_application.home_number,
        mobile_number:              @online_application.mobile_number,
        place_of_birth:             @online_application.place_of_birth,
        membership_type_id:         @online_application.membership_type_id,
        membership_arrangement_id:  @online_application.membership_arrangement_id,
        religion:                   @online_application.religion,
        data:                       @online_application.data,
        legal_depedents:            [],
        beneficiaries:              []
      }

      @member_data[:legal_dependents]  = @online_application.data["legal_dependents"].map{ |o|
                                        {
                                          first_name:     o["firstName"],
                                          middle_name:    o["middleName"],
                                          last_name:      o["lastName"],
                                          date_of_birth:  o["dateOfBirth"],
                                          relationship:   o["relationship"],
                                          data:           {
                                                            educational_attainment: o["education"],
                                                            course: o["course"],
                                                            is_deceased: false,
                                                            is_tpd: false
                                                          }
                                        }
                                      }

      @online_application.data["beneficiaries"].each_with_index{ |o, i|
        @member_data[:beneficiaries] << {
          first_name:     o["firstName"],
          middle_name:    o["middleName"],
          last_name:      o["lastName"],
          date_of_birth:  o["dateOfBirth"],
          relationship:   o["relationship"],
          is_primary:     i == 0
        }
      }

      save_member!
      flag_processed!

      ActivityLog.create!(
        content: "#{@user.full_name} processed online_application for member #{@member.full_name}",
        activity_type: "create",
        data: {
          user_id:      @user.id,
          member_id:    @member.id,
          member_data:  @member_data
        }
      )

      @online_application
    end

    def save_member!
      config = {
        member_data: @member_data,
        user: @user
      }

      @member = ::Members::Save.new(
                  config: config
                ).execute!

      @online_application.online_application_documents.each do |o|
        @member.attachment_files.build(
          file_name: o.file_name,
          file: o.file.blob
        )
      end

      @member.online_application  = @online_application

      if @online_application.profile_picture.attached?
        @member.profile_picture.attach(@online_application.profile_picture.blob)
      end

      @member.save!

      @member
    end

    def flag_processed!
      @online_application.data["approved_by"] = {
        id: @user.id,
        name: @user.full_name
      }

      @online_application.data["date_processed"]  = Date.today

      @online_application.status = "processed"

      @online_application.save!
    end
  end
end
