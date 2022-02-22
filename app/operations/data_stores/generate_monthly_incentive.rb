module DataStores
  class GenerateMonthlyIncentive
     
    def initialize(config:)
      @config = config
      @data_store  = DataStore.find(@config[:id])
      @data   = @data_store.data.with_indifferent_access
      @branch = @config[:branch]
      @year   = @config[:year] || Date.today.year
      @month  = @config[:month] || Date.today.month
      @as_of  = Date.new(@year, @month, -1)
      @start_date = Date.new(@year, @month, 1)
      @end_date   = @as_of
      @incentive_table          = Settings.incentive_table
      @active_loaner_threshold  = Settings.active_loaner_threshold || 250
      month_prev = @as_of.beginning_of_month - 1.day
      @repayment_rate_prev  = DataStore.repayment_rates.where("meta->>'as_of' = ? and meta->>'branch_id' = ?","#{month_prev}",@branch.id).last
      @repayment_rate_as_of = DataStore.repayment_rates.where("meta->>'as_of' = ? and meta->>'branch_id' = ?","#{@as_of}",@branch.id).last
      @member_counts_as_of  = DataStore.member_counts.where("meta->>'as_of' = ? and meta->>'branch_id' = ?","#{@as_of}",@branch.id).last
      @member_counts_prev   = DataStore.member_counts.where("meta->>'as_of' = ? and meta->>'branch_id' = ?","#{month_prev}",@branch.id).first
      @loans_stat_officer_present  =  ::DataStores::BuildBranchLoanStatsPerOfficerFromRr.new(rr_data:  @repayment_rate_as_of.data.with_indifferent_access).execute!
      @loans_stat_officer_prev     =  ::DataStores::BuildBranchLoanStatsPerOfficerFromRr.new(rr_data:  @repayment_rate_prev.data.with_indifferent_access).execute!
      @member_counts_pres = ::DataStores::BuildMemberCountsPerOfficer.new(mc_data: @member_counts_as_of.data.with_indifferent_access).execute!
      @member_counts_prev = ::DataStores::BuildMemberCountsPerOfficer.new(mc_data: @member_counts_prev.data.with_indifferent_access).execute!
      @new_and_resigned_pres = DataStore.monthly_new_and_resigned.where("meta->>'branch_id' = ? and meta->>'as_of' = ?","#{@branch.id}", "#{@as_of}").last
    end

    def execute!

      @officers = @loans_stat_officer_present[:officers].map{|off| off[:officer]}.uniq
     
      @officers.each do |officers|
        @officers_data = {
        officer: officers,
        status: "",
        rr: 0.0,
        par_amount: 0.0,
        par_rate: 0.0,
        portfolio: 0.0,
        prev_rr: 0.0,
        prev_par_rate: 0,
        disbursed_amount: 0,
        loans_disbursed: 0,
        admitted_members: 0,
        pure_savers: 0,
        loaners: 0,
        outreached: 0,
        beg_outreached: 0,
        new_members: 0,
        resigned_members: 0,
        drop_out_rate: 0.0,
        incentive: 0.0,
        verbal_warning_demerits: 0.0,
        written_warning_demerits: 0.0,
        drop_out_demerits: 0.0,
        total_demerits: 0.0,
        final_incentive: 0.0
        }
        #LOANS STAT PRESENT
          @loans_stat_officer_present[:officers].each do |pres|
            if officers[:id] == pres[:officer][:id]
            @officers_data[:rr]= (pres[:rr].to_f * 100).round(2)
            @officers_data[:par_amount]= pres[:par_amount]
            @officers_data[:par_rate]= pres[:par_rate].to_f * 100
            @officers_data[:portfolio]= pres[:portfolio]
           end
          end
        #LOAN STAT PREV
          @loans_stat_officer_prev[:officers].each do |prev|
            if officers[:id] == prev[:officer][:id]
              @officers_data[:prev_rr] = (prev[:rr].to_f * 100)
              @officers_data[:prev_par_rate] =  prev[:par_rate].to_f * 100
            end
          end
        #LOAN STAT PRESENT DISBURSED AMOUNT AND COUNT
          @loans_stat_officer_present[:officers].each do |lp|
            if officers[:id] == lp[:officer][:id]
              lp[:loan_products].each do |loans|
                loans[:loans].each do |ll|
                  date_released = ll.fetch("date_released").try(:to_date)
                  if date_released.month == @month and date_released.year == @year
                    @officers_data[:disbursed_amount] += ll[:principal].to_f
                    @officers_data[:loans_disbursed] += 1
                  end
                end
              end
            end
          end
        
        #MEMBER COUNTS PRESENT
          @member_counts_pres[:officers].each do |mcp|
            if mcp[:id] == officers[:id]
              @officers_data[:admitted_members] = mcp[:counts][:active_members][:total]
              @officers_data[:pure_savers] = mcp[:counts][:pure_savers][:total]
              @officers_data[:loaners] = mcp[:counts][:loaners][:total]
              @officers_data[:outreached] = mcp[:counts][:active_members][:total] + mcp[:counts][:pure_savers][:total] + mcp[:counts][:loaners][:total]

            end
          end

        #MEMBER COUNTS PREV
          @member_counts_prev[:officers].each do |mcprev|
            if mcprev[:id] == officers[:id]
              @officers_data[:beg_outreached] =  mcprev[:counts][:loaners][:total].to_i
            end
          end

        #new and resigned
          @new_and_resigned_pres.data["new_members"].each do |nar|
            if nar["officer"]["id"] == officers[:id]
              @officers_data[:new_members] += 1
            end
          end

          @new_and_resigned_pres.data["resigned_members"].each do |res|
            if res["officer"]["id"] == officers[:id]
              @officers_data[:resigned_members] += 1
            end
          end
        #drop out
          drop_out_rate = ((((@officers_data[:beg_outreached].to_f + @officers_data[:new_members]) - @officers_data[:loaners]) / @officers_data[:beg_outreached]) * 100).round(2)
          @officers_data[:drop_out_rate] = drop_out_rate

        #incentive
         incentive = @incentive_table.select{ |o| (@officers_data[:rr]/100) >= o.min_rr and (@officers_data[:rr]/100) <= o.max_rr }.first
          if incentive.present?
            portfolio_settings  = incentive.portfolio_table.select{ |p|
                                     @officers_data[:portfolio] >= p.min and  @officers_data[:portfolio] <= p.max
                                  }.first
            if portfolio_settings.present?
              @officers_data[:incentive] = portfolio_settings.amount
            end
          end
        
        #demerits
          net_incentive = 0.0
          @officers_data[:total_demerits] = ((Settings.drop_out_demerits_per_member || 0.00) * @officers_data[:resigned_members])
          @officers_data[:drop_out_demerits] = @officers_data[:total_demerits]
          net_incentive                   = @officers_data[:incentive] -  @officers_data[:total_demerits]


          if net_incentive < 0.00
            net_incentive = 0.00
          end
          
          user = User.find(officers[:id])
          if user.is_regular and user.incentivized_date.present? and user.incentivized_date <= @as_of
            @officers_data[:status] = "Regular"
          else
            @officers_data[:status] = "Trainee / Probation"
          end
           
          if @officers_data[:status] != "Regular"
            net_incentive = 0.00
          end

          if @officers_data[:loaners] < @active_loaner_threshold
            net_incentive = 0.00
          end

          @officers_data[:final_incentive] = net_incentive
        ####
        @data[:records] << @officers_data
     end


     @data[:total_so_incentive] = 0.00
     @data[:total_regular_so] = 0
     @data[:total_average_so_incentive]=0.00
     @data[:som_incentive]= 0.00

     @data[:records].each do |dr|
      @data[:total_so_incentive] += dr[:final_incentive]
      if dr[:status] == "Regular"
        @data[:total_regular_so] += 1
      end
     end  

     @data[:total_average_so_incentive] = (@data[:total_so_incentive] / @data[:total_regular_so]).round(2) || 0.00
     @data[:som_incentive] = (@data[:total_average_so_incentive] * 0.75).round(2) || 0.00
     
     @data
    
       
    end

    

  end
end