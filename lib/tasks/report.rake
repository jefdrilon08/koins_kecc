namespace :report do
  task :member_age => :environment do
    br_name = ENV['SATO']
    br_id= Branch.where(name: br_name).ids

    member = Member.where(status: "active" , branch_id: br_id).order('date_of_birth DESC')
    puts "NAME|CENTER|DATE OF BIRTH|AGE|GENDER"
    member.each do |mem|
      puts "#{mem.full_name}|#{mem.center}|#{mem.date_of_birth}|#{mem.age}|#{mem.gender}"  

  end
    
    
  end

  task :midas_report => :environment do
    s_date= ENV['s_date']
    #mat_date = ENV['mat_date']
    br_name = ENV['SATO']
    rep_type = ENV['MIDAS']
    br_id= Branch.where(name: br_name).ids
    @data = [] 

    @data_store  = DataStore.where(
                                        "meta->>'branch_id' = ? AND 
                                         CAST(meta->>'as_of' AS date) = ? AND 
                                         meta->>'data_store_type' = ?", 
                                         br_id, 
                                         s_date,
                                         "MANUAL_AGING").last
   @data_store_data = @data_store.data.with_indifferent_access

   @data_store_data[:records].each.with_index do |l|
    loan_data = Loan.find(l[:id])

    #member_details
    mem = Member.find(loan_data.member_id)
      street      = mem.data["address"]["street"]
      brgy        = mem.data["address"]["district"]
      city        = mem.data["address"]["city"]
      bday        = mem.date_of_birth.to_date.strftime("%m/%d/%Y")
      sss         = mem.data["government_identification_numbers"]["sss_number"]
      pag_ibig    = mem.data["government_identification_numbers"]["pag_ibig_number"]
      phil_health = mem.data["government_identification_numbers"]["phil_health_number"]
      tin         = mem.data["government_identification_numbers"]["tin_number"] 
    if rep_type == 'PODs'
      m_type = 'POD'
    elsif rep_type == 'BARs'
      m_type = 'BAR'
    end
     #civil_status
      if mem.civil_status == 'May Kinakasama' or mem.civil_status == 'Single' or mem.civil_status == 'single'
        civil_stat = 1
      elsif mem.civil_status == 'Kasal' or mem.civil_status == 'married'
        civil_stat = 2
      elsif mem.civil_status == 'Hiwalay' or mem.civil_status == 'separated'
        civil_stat = 3
      elsif mem.civil_status == 'Biyudo/a' or mem.civil_status == 'widowed'
        civil_stat = 4
      end
      #gender
      if mem.gender == 'Female'
        gend = 'F'
      elsif mem.gender == 'Male'
        gend = 'M'
      end
      #LOAN PURPOSE
      loan_prod = l[:loan_product][:name]
      if loan_prod == 'K - EDUKASYON' or loan_prod == 'K - EDUKASYON W2'  or loan_prod == 'K - EDUKASYON W3' or loan_prod == 'K - KALUSUGAN W1'  or loan_prod == 'K - KALUSUGAN W2' or loan_prod == 'K - KALUSUGAN W3' or loan_prod == 'K - KALUSUGAN W4' or loan_prod == 'K - KALUSUGAN W5' or loan_prod == 'K - KALUSUGAN W6' or loan_prod == 'K - KALUSUGAN W7'  or loan_prod == 'K - BAHAY W1' or loan_prod == 'K - BAHAY W2' or loan_prod == 'K - BAHAY W3' or loan_prod == 'K - Noche Buena'         
        loan_purpose = 'NI'
      elsif loan_prod == 'K - KABUHAYAN' or loan_prod == 'K - PWD' or loan_prod == 'K - NHA W1' or loan_prod == 'K - NHA W2' or loan_prod == 'K-Toda' or loan_prod == 'K - MAGGAGAWA' or loan_prod == 'Alalay sa K (Business Disruption Loan)' or loan_prod == 'K - SAGIP'
        loan_purpose = 'ET'
      elsif loan_prod == 'K - BENEPISYO W1' or loan_prod == 'K - BENEPISYO W2' or loan_prod == 'K - BENEPISYO W3'  or loan_prod == 'K - KALAMIDAD' or loan_prod == 'K -KASAL' or loan_prod == 'K - TRABAHO' or loan_prod == 'K - BISIKLETA'
        loan_purpose = 'SE'
      end
      #CONTRACT TYPE
      if loan_prod == 'K - EDUKASYON' or loan_prod == 'K - EDUKASYON W2'  or loan_prod == 'K - EDUKASYON W3' or loan_prod == 'K - KALUSUGAN W1'  or loan_prod == 'K - KALUSUGAN W2' or loan_prod == 'K - KALUSUGAN W3' or loan_prod == 'K - KALUSUGAN W4' or loan_prod == 'K - KALUSUGAN W5' or loan_prod == 'K - KALUSUGAN W6' or loan_prod == 'K - KALUSUGAN W7'  or loan_prod == 'K - BAHAY W1' or loan_prod == 'K - BAHAY W2' or loan_prod == 'K - BAHAY W3' or loan_prod == 'K - Noche Buena'  or loan_prod == 'K -KASAL' or loan_prod == 'K - TRABAHO'
        contract_type = 12
      elsif loan_prod == 'K - KABUHAYAN' or loan_prod == 'K - PWD' or loan_prod == 'K - NHA W1' or loan_prod == 'K - NHA W2' or loan_prod == 'K-Toda' or loan_prod == 'K - MAGGAGAWA'or loan_prod == 'Alalay sa K (Business Disruption Loan)' or loan_prod == 'K - SAGIP'
        contract_type = 22
      elsif loan_prod == 'K - BENEPISYO W1' or loan_prod == 'K - BENEPISYO W2' or loan_prod == 'K - BENEPISYO W3'  or loan_prod == 'K - KALAMIDAD' 
        contract_type = 28
      elsif loan_prod == 'K - BISIKLETA'
        contract_type = 17
      end
      #POD TYPE
      if loan_data.maturity_date.to_date == loan_data.original_maturity_date.to_date
        pod_type = "50-01"  
      else
        pod_type = "54-02"
      end
      #mat_date
      mat_date = loan_data.maturity_date.to_date.strftime("%m/%d/%Y")      
      date_rel = loan_data.date_released.to_date.strftime("%m/%d/%Y")
      int_rate = (loan_data.monthly_interest_rate*12)*100

      no_days_par = l[:num_days_par]
      n = (s_date.to_date - no_days_par)
      outs_weeks = AmortizationScheduleEntry.where("loan_id = ? and due_date <= ? and due_date >= ?" , l[:id] , s_date , n).count
      last_payment = AmortizationScheduleEntry.where("loan_id = ?" , l[:id]).last.amount_due
      monthly_payment = last_payment * 4

      #Overdue_Days
      if mat_date <= s_date
        if l[:num_days_par] >= 0
          overdue_days = l[:num_days_par]
        else
          overdue_days = 0
        end  
      else
        overdue_days = 0
      end
    j = "#{mem.identification_number}|#{mem.last_name}|#{mem.first_name}|#{mem.middle_name}|#{street}|#{brgy}|#{city}|||#{bday}|#{mem.place_of_birth}|#{gend}|#{civil_stat}|#{mem.mobile_number}||||||#{sss}|#{pag_ibig}|#{phil_health}|#{tin}|#{l[:pn_number]}|#{contract_type}|AC|NA|#{l[:principal]}|#{l[:overall_principal_balance]}|#{date_rel}|#{mat_date}|#{int_rate}|#{loan_data.term}|#{loan_data.num_installments}|Php|#{loan_purpose}|#{pod_type}|#{l[:overall_balance]}|#{mat_date}|#{overdue_days}|#{monthly_payment}|#{outs_weeks}|#{last_payment}"
    @data << j
   end
   puts @data
  end
  task :mem_share => :environment do
    x = Member.where("status = 'active' and branch_id = '3726405b-777c-4b61-b6a5-7a4b48db62b6'")
    x.each do |y|
      total_share = MemberAccount.where(member_id: y.id , account_type: 'EQUITY' , account_subtype: 'Share Capital').sum(:balance)
      mem_cert = Member.joins(:member_shares).where("members.id = ? and member_shares.is_void IS NULL" , y.id).sum(:number_of_shares)
      total_share_count = (total_share/100).to_i
      if total_share_count > mem_cert
        puts y.full_name , mem_cert , total_share_count
      end
    end
  end
  
  task :pending_insurance => :environment do
    Member.where("insurance_status = 'pending' and status = 'active' and data->>'recognition_date' IS NOT NULL").each do |pi|
      Member.find(pi.id).update(insurance_status: 'inforce')
      puts "#{pi.last_name}|#{pi.first_name}|#{pi.middle_name}|#{pi.recognition_date}"
      #MembershipPaymentRecord.where("membership_type = 'Insurance' and member_id = ?" , pi.id).date_paid
    end
  end
##### LIST OF ADDITIONAL SHARE CAPITAL ver 2.0#####
  task :project_type => :environment do
    ProjectType.all.each do |pt|
      puts "#{pt.name}|#{pt.id}"
    end
  end
  task :generate_list_for_additional_share_capitalx => :environment do
    require 'csv'
    s_date= ENV['s_date']
    e_date= ENV['e_date']
    br_name= ENV['branch']
   br_id= Branch.where(name: br_name).ids
    @data = []
    #mem = Member.joins(:member_shares).where("members.status = 'active' and members.branch_id = ? and member_shares.date_of_issue >= ? and member_shares.date_of_issue <= ?", br_id , s_date , e_date).order(:center_id)
    mem = Member.joins(:member_accounts).where("members.status = 'active' and member_accounts.account_type = 'EQUITY' and member_accounts.account_subtype = 'Share Capital' and members.branch_id = ?", br_id).order(:center_id)

    puts "Member Name | Center | Status |Date of Membership | Equity Account Balance | Required Additional Share Capital | CBU Balance | Share Capital For Payment | Current Savings"
    mem.each do |mems|
      mem_acct        = MemberAccount.where("member_id = ? and account_type = 'EQUITY' and account_subtype = 'Share Capital'", mems.id)
      mem_sub_id      = mem_acct.ids
      at              = AccountTransaction.where("subsidiary_id = ?", mem_sub_id)
      mem_date_year   =  at.pluck(:transacted_at).last.year
      req_add_share   = (Time.now.year - mem_date_year) * 100
      mem_acc         = at.order(:transacted_at).last.transacted_at
      mem_center      = Center.find(mems.center_id).name
      mem_equity      = mem_acct.pluck(:balance).map(&:to_d).shift
      cbu_bal         = MemberAccount.where("member_id = ? and account_type = 'EQUITY' and account_subtype = 'CBU'", mems.id).pluck(:balance).map(&:to_d).shift
      sc_for_payment  = req_add_share - cbu_bal
      curr_savings    = MemberAccount.where("member_id = ? and account_type = 'SAVINGS' and account_subtype = 'K-IMPOK'", mems.id).pluck(:balance).map(&:to_d).shift
 
      if mem_acc >= s_date and mem_acc <= e_date 
      puts "#{mems.full_name}|#{mem_center}|#{mems.status}|#{mem_acc}|#{mem_equity}|#{req_add_share}|#{cbu_bal}|#{sc_for_payment}|#{curr_savings}"
      
        #@data << md   
      end
      #@data << md
      #md = "#{mems.full_name}|#{mem_center}|#{mems.status}|#{mem_date_of_issue}|#{mem_equity}|#{req_add_share}|#{cbu_bal}|#{sc_for_payment}|#{curr_savings}"
      
    end
    #puts @data
  end


##### LIST OF ADDITIONAL SHARE CAPITAL ver 2.1#####
  task :generate_list_for_additional_share_capital => :environment do
    require 'csv'
    s_date= ENV['s_date']
    e_date= ENV['e_date']
    br_name= ENV['branch']
    br_id= Branch.where(name: br_name).ids
    @data = []
    mem = Member.joins(:member_shares).where("members.status = 'active' and members.branch_id = ? and member_shares.date_of_issue >= ? and member_shares.date_of_issue <= ?", br_id , s_date , e_date).order(:center_id)
      
    puts "Member Name | Center | Status |Date of Membership | Equity Account Balance | Required Additional Share Capital | CBU Balance | Share Capital For Payment | Current Savings"
    CSV.open("#{Rails.root}/tmp/#{br_name}_#{s_date}_to_#{e_date}_list_of_additioanl_shares.csv", "w",:write_headers=> true, :headers => [] ) do |csv|
    mem.each do |mems|
      mem_date_of_issue = MemberShare.where("member_id = ?" , mems.id).pluck(:date_of_issue).first
      mem_equity = MemberAccount.where("member_id = ? and account_type = 'EQUITY' and account_subtype = 'Share Capital'", mems.id).pluck(:balance).map(&:to_d).shift
      mem_center = Center.find(mems.center_id).name
      mem_date_year = MemberShare.where("member_id = ?" , mems.id).pluck(:date_of_issue).first.year
      req_add_share = (Time.now.year - mem_date_year) * 100
      cbu_bal = MemberAccount.where("member_id = ? and account_type = 'EQUITY' and account_subtype = 'CBU'", mems.id).pluck(:balance).map(&:to_d).shift
      sc_for_payment = req_add_share - cbu_bal
      curr_savings = MemberAccount.where("member_id = ? and account_type = 'SAVINGS' and account_subtype = 'K-IMPOK'", mems.id).pluck(:balance).map(&:to_d).shift
      md = "#{mems.full_name}|#{mem_center}|#{mems.status}|#{mem_date_of_issue}|#{mem_equity}|#{req_add_share}|#{cbu_bal}|#{sc_for_payment}"
      @data << md
    
    end
  end
    puts @data
  end




##### LIST OF ADDITIONAL SHARE CAPITAL #####
  task :generate_list_for_additional_share_cap => :environment do
    require 'csv'
    s_date= ENV['s_date']
    e_date= ENV['e_date']
    br_name= ENV['branch']
    br_id= Branch.where(name: br_name).ids

    CSV.open("#{Rails.root}/tmp/#{br_name}_#{s_date}_to_#{e_date}_list_of_additioanl_shares.csv", "w",:write_headers=> true, :headers => ["IDENTIFICATION_NUMBER","NAMES", "DATE OF MAMBERSHIP", "STATUS" , "EQUITY ACCOUNT BALANCE"] ) do |csv|
      mem = Member.joins(:member_shares).where("members.status = 'active' and members.branch_id = ? and member_shares.date_of_issue >= ? and member_shares.date_of_issue <= ?", br_id , s_date , e_date).pluck(:identification_number , "CONCAT_WS(', ',members.last_name,members.first_name,members.middle_name)" , "member_shares.date_of_issue" , "members.status" )
      mem.each do |mems|
        csv << mems
      end
    end
  end

##### LIST OF RESIGNED #####
  task :generate_resigned_members => :environment do
    require 'csv'
    req_date= ENV['r_date']  
    br_name= ENV['branch']
    br_id= Branch.where(name: br_name).ids

    CSV.open("#{Rails.root}/tmp/from_#{req_date}_#{br_name}_list_of_resigned_members.csv", "w",:write_headers=> true, :headers => ["IDENTIFICATION_NUMBER","NAMES", "DATE RESIGNED"] ) do |csv|
      mem = ap Member.where("status = 'resigned' and branch_id = ? and date_resigned >= ?" , br_id , req_date).pluck(:identification_number , "CONCAT_WS(', ',last_name,first_name)" , "date_resigned" )
    
      mem.each do |mems|
        csv << mems
      end
    end
  end
##### LIST OF 400 EQUITY #####
  task :equity_data => :environment do
    require 'csv'
    br_name= ENV['branch']
    br_id= Branch.where(name: br_name).ids

    CSV.open("#{Rails.root}/tmp/equity_data.csv", "w",:write_headers=> true, :headers => ["ID NUMBER" , "NAME" , "DATE OF MEMBERSHIP" , "CENTER" , "EQUITY"] ) do |csv|
      mem = Member.joins(:member_accounts , :center , :membership_payment_records).where("members.status = 'active' and member_accounts.account_type = 'EQUITY' and member_accounts.account_subtype = 'Share Capital' and members.branch_id = ? and member_accounts.balance = 400 and membership_payment_records.status = 'paid'" , br_id).order("membership_payment_records.date_paid").pluck(:identification_number , "CONCAT_WS(', ',members.last_name,members.first_name,members.middle_name)" , "membership_payment_records.date_paid" ,"centers.name" , "member_accounts.balance").uniq
      mem.each do |mems|
        csv << mems
      end
    end
  end




end
