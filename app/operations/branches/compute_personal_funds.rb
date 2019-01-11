module Branches
  class ComputePersonalFunds
    def initialize(config:)
      @config = config

      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today
      @cluster  = @branch.cluster
      @area     = @cluster.area

      @members  = Member.active.where(branch_id: @branch.id).order("last_name ASC")

      @default_member_accounts  = Settings.default_member_accounts

      if @default_member_accounts.blank?
        raise "Settings not found: default_member_accounts"
      end

      @data = {
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        cluster: {
          id: @cluster.id,
          name: @cluster.name
        },
        area: {
          id: @area.id,
          name: @area.name
        },
        as_of: @as_of,
        member_records: [],
        records: [],
        total: 0.00
      }
    end

    def execute!
      @data[:records] = @members.map{ |o| 
                          ::Members::ComputePersonalFunds.new(
                            config: {
                              member: o,
                              as_of: @as_of
                            }
                          ).execute!
                        }

#      @data[:officers]  = @data[:member_records].map{ |mr| mr[:officer] }.uniq.map{ |officer|
#                            {
#                              officer:  officer,
#                              centers:  @data[:member_records].select{ |temp|
#                                          temp[:officer][:id] == officer[:id]
#                                        }.pluck(:center).uniq.map{ |center|
#                                          {
#                                            center:   center,
#                                            records:  @data[:member_records].select{ |mr|
#                                                        mr[:center][:id] == center[:id]
#                                                      }
#                                          }
#                                        }
#                            }
#                          }
      @data
    end
  end
end
