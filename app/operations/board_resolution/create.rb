module BoardResolution
  class Create
    def initialize(config:)
      @config = config
      @branch = @config[:branch]
      @date_from = @config[:date_from]
      @date_to = @config[:date_to]
      @user = @config[:current_user]
      @status = @config[:status]
      @board_resolution_number = @config[:board_resolution_number]
      @data_store_type = "BOARD_RESOLUTION"
      @current_date = Date.today  
      @records = []

      @data_store = DataStore.create!(
        meta: {
          data_store_type: @data_store_type,
          branch_id: @branch.id,
          branch_name: @branch.name,
          date_from: @date_from,
          date_to: @date_to,
          date_generated: @current_date,
          date_approved: "",
          status: @status
        },
        data: { record: [] },
        status: "pending"
      )
    end

    def process_data_record!
      if @status == 'active'
        process_active_members
      elsif @status == 'resigned'
        process_resigned_members
      else
        raise "Invalid status: #{@status}"
      end
    end

    def process_active_members
      members = Member.where(branch_id: @branch.id, status: 'active')
    
      members.each do |member|
        member_account = MembershipPaymentRecord.find_by(
          member_id: member.id,
          membership_type: 'Cooperative',
          date_paid: @date_from..@date_to 
        )
    
        next unless member_account
    
        @records << {
          member_id: member.id,
          full_name: "#{member.last_name}, #{member.first_name} #{member.middle_name}",
          center_id: member.center_id,
          center_name: member.center&.name || "Unknown Center",
          member_status: member.status,
          board_resolution_number: @board_resolution_number,
          membership_date: member_account.date_paid
        }

      end
    end
    
  
    def process_resigned_members
      date_from = @date_from.to_date
      date_to = @date_to.to_date
    
      members = Member.where(branch_id: @branch.id, status: 'resigned')
    
      members.each do |member|
        member_date_resigned = member.date_resigned
    
        next unless member_date_resigned.present? && member_date_resigned.between?(date_from, date_to)
    
        @records << {
          id: member.id,
          full_name: "#{member.last_name}, #{member.first_name} #{member.middle_name}",
          center_id: member.center_id,
          center_name: member.center&.name || "Unknown Center",
          member_status: member.status,
          date_resigned: member_date_resigned,
          board_resolution_number: @board_resolution_number
        }

      end
    end
    
    def execute!
      process_data_record!

      @data_store.update!(
        data: {
          record: @records
        }
      )

      @data_store
    end
  end
end
