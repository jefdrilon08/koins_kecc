module BoardResolution
    class Approve
        def initialize(config:)
            @config = config
            @data_store = @config[:data_store]
            @user       = @config[:user]
            @date       = ::Utils::GetCurrentDate.new(
                            config: {
                            # branch: Branch.find(@data_store.meta["branch_id"])
                            }
                        ).execute!
        end
  
      def execute!
        update_members_board_resolution
  
        @data_store.meta[:date_approved]          = @date
        @data_store.meta[:approved_by]            = @user
        @data_store.update!(status: "approved")
        @data_store
      end
  
      private
  
        def update_members_board_resolution
            @data_store.data["record"].each do |record|
            next unless record["member_id"].present?
    
            member = Member.find_by(id: record["member_id"])
            next unless member
    
            member_data = member.data.with_indifferent_access
            member_data["board_resolution_number"] = record["board_resolution_number"]
            member.update!(data: member_data)
            end
        end
    end
  end
  