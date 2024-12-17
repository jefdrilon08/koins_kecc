module DataStores
  class GenerateMonthlyIncentivesExcel
    def initialize(config:)
      puts "helloy"
      puts "helloy uli"
      puts ReadOnlyDataStore.find(config)
      @record = ReadOnlyDataStore.find(config)
      @meta = @record.meta.try(:with_indifferent_access)
      @data = @record.data.with_indifferent_access
      @data_records = @record.data.with_indifferent_access[:records]
      @subheader_items = [
        { text: "Data Stores" },
        { text: "Monthly Incentives", is_link: true, path:  "/data_stores/monthly_incentives" }
      ]
      @p = Axlsx::Package.new
    end
    def execute!
      puts "hjello"
      puts @meta
  
      @list=[ "Satellite Officer", "Status", "Admitted Members", "Pure Savers", "Active Loaners", "Total Members",
              "Outreached - Active Loaners", "Beginning Active Loaners", "Additional Members", "Resigned Members", "Dropout Percentage", 
              "Present Month Repayment Rate", "Previous Month Repayment Rate", "PAR Amount", "Present PAR Rate", "Previous Month Repayment Rate",
                        "Portfolio", "Loan Amount Disbursed", "Loan Disbursed", "Incentive", "Verbal Warning Demerits",
                        "Written Warning Demerits", "Drop-out Demerits", "Total Demerits", "Final Incentives"   ]

      @list2=[:last_name,:status,:admitted_members,:pure_savers,:loaners,:outreached, :loaners,:beg_outreached,:new_members,
              :resigned_members,:drop_out_rate,:rr,:prev_rr,:par_amount,:par_rate,:prev_par_rate,:portfolio,:disbursed_amount,
              :loans_disbursed,:incentive,:verbal_warning_demerits,:written_warning_demerits,:drop_out_demerits, :total_demerits,
              :final_incentive]
      
      z=0
      @exportMIExcel=CSV.generate do |record1|
        record1<<["Incentive Period:","Branch:"]
        record1<<["#{(@meta[:as_of].to_date).at_beginning_of_month.strftime("%B %d, %Y")} - #{@meta[:as_of].to_date.strftime("%B %d, %Y")}",@meta[:branch_name].upcase]
        record1<<["\n"]
        @list.each do |x|
                    temp=[]
          temp.push(x)
          @data_records.each do |y|
            if y[:status]=="Regular" then
            case z
              when 0
                temp.push(y[:officer][:last_name].try(:upcase)+", "+y[:officer][:first_name].try(:upcase))
              when 1
                temp.push(y[@list2[z]])
              when 10,11,12,14,15
                temp.push("#{y[@list2[z]].try(:round, 2)|| 0.0}%")
              else
                temp.push(y[@list2[z]].try(:round, 2))
              end
            end
          end
          record1<<temp
          z+=1
        end
        record1<<["\n"]
        record1<<["Total SO Incentive",@data[:total_so_incentive].round(2)]
        record1<<["Total Regular SO",@data[:total_regular_so]]
        record1<<["Total Average SO Incentive",@data[:total_average_so_incentive]]
        record1<<["SOM Incentive",@data[:som_incentive]]
      end

      @exportMIExcel
    end
  end
end
