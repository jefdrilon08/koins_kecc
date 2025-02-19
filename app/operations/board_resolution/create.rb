module BoardResolution
  class Create
    MONTHS_MAPPING = {
      "JANUARY" => 1, "FEBRUARY" => 2, "MARCH" => 3, "APRIL" => 4,
      "MAY" => 5, "JUNE" => 6, "JULY" => 7, "AUGUST" => 8,
      "SEPTEMBER" => 9, "OCTOBER" => 10, "NOVEMBER" => 11, "DECEMBER" => 12
    }.freeze

    def initialize(config:)
      @config = config
      # @branch = @config[:branch]
      @month = @config[:month].to_s.strip.upcase
      @year = @config[:year].to_i
      @user = @config[:current_user]
      @member_status = @config[:member_status].to_s
      @board_resolution_number = @config[:board_resolution_number]
      @data_store_type = "BOARD_RESOLUTION"
      @current_date = Date.today
      @records = []

      month_number = MONTHS_MAPPING[@month]
      raise "Invalid month: #{@month}" unless month_number

      @date_from = Date.new(@year, month_number, 1)
      @date_to = @date_from.end_of_month

    
      @data_store = DataStore.create!(
        meta: {
          data_store_type: @data_store_type,
          # branch_id: @branch.id,
          # branch_name: @branch.name,
          month: @month,
          year: @year,
          date_generated: @current_date,
          date_approved: "",
          member_status: @member_status,
          board_resolution_number: @board_resolution_number
        },
        data: { record: [] }
      )
    end

    def process_data_record!
      if @member_status == 'active'
        process_active_members
      elsif @member_status == 'resigned'
        process_resigned_members
      else
        raise "Invalid status: #{@member_status}"
      end
    end

    def process_active_members
      branch = Branch.where.not(id: 'b9659f7e-c4d5-4b8b-be3b-508bd7c6a583')
      members = Member.where(branch_id: branch.ids, status: 'active')
    
      members.each do |member|
        member_account = MembershipPaymentRecord.find_by(
          member_id: member.id,
          membership_type: 'Cooperative',
          date_paid: @date_from..@date_to

        )
    
        next unless member_account
    
        @records << {
          member_id: member.id,
          full_name: "#{member.last_name}, #{member.first_name} #{member.middle_name}".strip,
          branch_id: member.branch_id,
          center_id: member.center_id,
          center_name: member.center.try(:name) || "Unknown Center",
          member_status: member.status,
          board_resolution_number: @board_resolution_number,
          membership_date: member_account.date_paid
        }
      end
    end
    

    def process_resigned_members
      branch = Branch.where.not(id: 'b9659f7e-c4d5-4b8b-be3b-508bd7c6a583')
      members = Member.where(branch_id: branch.ids, status: 'resigned')

      members.each do |member|
        member_date_resigned = member.date_resigned

        next unless member_date_resigned.present? && member_date_resigned.between?(@date_from, @date_to)

        @records << {
          id: member.id,
          full_name: "#{member.last_name}, #{member.first_name} #{member.middle_name}",
          branch_id: member.branch_id,
          center_id: member.center_id,
          center_name: member.center&.name || "Unknown Center",
          member_status: member.status,
          date_resigned: member_date_resigned,
          board_resolution_number: @board_resolution_number
        }
      end
    end

    def execute!
      @data_store.update!(status: 'processing')  # Set the status to 'processing' before processing starts.
    
      process_data_record!
    
      @data_store.update!(
        data: { record: @records },
        status: 'pending'  # Update the status to 'pending' after processing is completed.
      )
    
      @data_store
    end
    
  end
end
