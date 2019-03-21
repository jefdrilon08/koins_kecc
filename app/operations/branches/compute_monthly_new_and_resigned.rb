module Branches
  class ComputeMonthlyNewAndResigned
    def initialize(config:)
      @config = config
      @year   = @config[:year]
      @month  = @config[:month]
      @branch = @config[:branch]
      @as_of  = Date.new(@year, @month, -1)

      @members  = Member.active_and_resigned_and_pending.where(
                    branch_id: @branch.id
                  )

      @settings_default_membership = Settings.default_membership

      if @settings_default_membership.blank?
        raise "Settings.default_membership not found"
      else
        @membership_name  = @settings_default_membership.name
        @membership_type  = @settings_default_membership.type
      end

      @data = {
        year: @year,
        month: @month,
        as_of: @as_of,
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        new_members: [],
        resigned_members: [],
        num_new: 0,
        num_resigned: 0,
        settings_default_membership: @settings_default_membership
      }
    end

    def execute!
      # Get membership payment records
      @membership_payment_records = MembershipPaymentRecord.paid.where(
                                      "membership_type = ? AND membership_name = ? AND extract(month FROM date_paid) = ? AND extract(year FROM date_paid) = ?",
                                      @membership_type,
                                      @membership_name,
                                      @month,
                                      @year
                                    )

      @resigned_members = @members.where(
                            "(extract(month FROM date_resigned) = ? AND extract(year FROM date_resigned) = ?) OR (extract(month FROM previous_date_resigned) = ? AND extract(year FROM previous_date_resigned) = ?)",
                            @month,
                            @year,
                            @month,
                            @year
                          ).order("last_name ASC")

      @new_members  = @members.where(
                        id: @membership_payment_records.pluck(:member_id)
                      ).order("last_name ASC")


      # Compute resigned
      @data[:num_resigned]  = @resigned_members.count

      # Compute new
      @data[:num_new] = @new_members.count

      # Format resigned members
      @data[:resigned_members]  = @resigned_members.map{ |m|
                                    date_resigned = m.date_resigned

                                    if date_resigned.blank?
                                      date_resigned = m.previous_date_resigned
                                    end

                                    {
                                      id: m.id,
                                      first_name: m.first_name,
                                      middle_name: m.middle_name,
                                      last_name: m.last_name,
                                      identifiction_number: m.identification_number,
                                      date_resigned: date_resigned.strftime("%B %d, %Y"),
                                      center: {
                                        id: m.center.id,
                                        name: m.center.name
                                      },
                                      branch: {
                                        id: m.branch.id,
                                        name: m.branch.name
                                      }
                                    }
                                  }

      # Format new members
      @data[:new_members] = @new_members.map{ |m|
                              {
                                id: m.id,
                                first_name: m.first_name,
                                middle_name: m.middle_name,
                                last_name: m.last_name,
                                identifiction_number: m.identification_number,
                                center: {
                                  id: m.center.id,
                                  name: m.center.name
                                },
                                branch: {
                                  id: m.branch.id,
                                  name: m.branch.name
                                }
                              }
                            }

      @data
    end
  end
end
