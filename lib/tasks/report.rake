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
    br_name = ENV['SATO']
    rep_type = ENV['MIDAS']
    br_id= Branch.where(name: br_name).ids
    @data = []    
    if rep_type == 'PODs'
      loan_data = Loan.joins(:member , :center).where("loans.status = 'active' and loans.branch_id = ? and date_released <= ? and maturity_date >=?", br_id , s_date , s_date).order("members.identification_number").uniq
    elsif rep_type == 'BARs'
      loan_data = Loan.joins(:member , :center).where("loans.status = 'active' and loans.branch_id = ? and date_released <= ? and maturity_date <=?", br_id , s_date , s_date).order("members.identification_number").uniq
    end
    
    if rep_type == 'PODs'
      m_type = 'POD'
    elsif rep_type == 'BARs'
      m_type = 'BAR'
    end
 
    loan_count = loan_data.count 
    puts "#{rep_type} Template"
    puts "Institution|midas"
    puts "Cut Off Date | #{s_date.to_date.strftime("%m/%d/%Y")}"
    puts "No. Of Clients| #{loan_count}"
    puts "BEGIN"
    puts "CLIENT_REFERENCE|LAST_NAME|FIRST_NAME|MIDDLE_NAME|NO_STREET_SITIO_PUROK|BARANGAY_DISTRICT|CITY_MUNICIPALITY|PROVINCE|ZIP_CODE|BIRTHDATE|GENDER|CONTACT_NO|MOTHER'S MAIDEN FIRST NAME|MOTHER'S MAIDENMIDDLE NAME|MOTHER'S MAIDEN LAST NAME|ID_TYPE|ID_NO|SSS/GSIS|PAGIBIG|PHILHEALTH|TIN|LOAN_REFERENCE|CONTRACT_TYPE|CONTRACT_PHASE|TRANSACTION_TYPE|LOAN_PRINCIPAL|LOAN_BALANCE|DATE_GRANTED|DUE_DATE|INTEREST_RATE|PAY_FREQ|TERM|CURRENCY|LOAN_PURPOSE|#{m_type}_TYPE|TOTAL_LOAN_BALANCE|CONTRACT_ACTUAL_END_DATE|OVERDUE_DAYS|MONTHLY_PAYMENT_AMOUNT|NO_OF_OUTSTANDING_PAYMENT|AMOUNT_OF_LAST_PAYMENT|REMARKS"
      
    loan_data.each do |y|
      
      street = y.member.data["address"]["street"]
      brgy = y.member.data["address"]["district"]
      city = y.member.data["address"]["city"]
      bday = y.member.date_of_birth.to_date.strftime("%m/%d/%Y")
      sss = y.member.data["government_identification_numbers"]["sss_number"]
      pag_ibig =  y.member.data["government_identification_numbers"]["pag_ibig_number"]
      phil_health =  y.member.data["government_identification_numbers"]["phil_health_number"]
      tin =  y.member.data["government_identification_numbers"]["tin_number"] 
      loan_prod = LoanProduct.find(y.loan_product_id).name
      date_rel = y.date_released.to_date.strftime("%m/%d/%Y")
      mat_date = y.maturity_date.to_date.strftime("%m/%d/%Y")
      int_rate = (y.monthly_interest_rate*12)*100
      #pod_type = "50-01"
      tot_loan_balance = y.principal_balance + y.interest_balance
      over_due_days = ( s_date.to_date - y.maturity_date.to_date).to_i
      amort = AmortizationScheduleEntry.where(loan_id: y.id)
      monthly_payment = amort.first.amount_due * 4
      outs_payment = amort.where("is_paid IS NULL").count
      last_payment = amort.last.amount_due

      #gender
      if y.member.gender == 'Female'
        gend = 'F'
      elsif y.member.gender == 'Male'
        gend = 'M'
      end
      #POD TYPE
      if y.maturity_date.to_date == y.original_maturity_date.to_date
        pod_type = "50-01"  
      else
        pod_type = "54-02"
      end
      #OVER DUE DAYS
      if over_due_days >= -1
        over_due_days = over_due_days
      else
        over_due_days = 0
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
      end

      #LOAN PURPOSE
      if loan_prod == 'K - EDUKASYON' or loan_prod == 'K - EDUKASYON W2'  or loan_prod == 'K - EDUKASYON W3' or loan_prod == 'K - KALUSUGAN W1'  or loan_prod == 'K - KALUSUGAN W2' or loan_prod == 'K - KALUSUGAN W3' or loan_prod == 'K - KALUSUGAN W4' or loan_prod == 'K - KALUSUGAN W5' or loan_prod == 'K - KALUSUGAN W6' or loan_prod == 'K - KALUSUGAN W7'  or loan_prod == 'K - BAHAY W1' or loan_prod == 'K - BAHAY W2' or loan_prod == 'K - BAHAY W3' or loan_prod == 'K - Noche Buena'         
        loan_purpose = 'NI'
      elsif loan_prod == 'K - KABUHAYAN' or loan_prod == 'K - PWD' or loan_prod == 'K - NHA W1' or loan_prod == 'K - NHA W2' or loan_prod == 'K-Toda' or loan_prod == 'K - MAGGAGAWA' or loan_prod == 'Alalay sa K (Business Disruption Loan)' or loan_prod == 'K - SAGIP'
        loan_purpose = 'ET'
      elsif loan_prod == 'K - BENEPISYO W1' or loan_prod == 'K - BENEPISYO W2' or loan_prod == 'K - BENEPISYO W3'  or loan_prod == 'K - KALAMIDAD' or loan_prod == 'K -KASAL' or loan_prod == 'K - TRABAHO' or loan_prod == 'K - BISIKLETA'
        loan_purpose = 'SE'
      end

      j = "#{y.member.identification_number}|#{y.member.last_name}|#{y.member.first_name}|#{y.member.middle_name}|#{street}|#{brgy}|#{city}|||#{bday}|#{gend}|#{y.member.mobile_number}||||||#{sss}|#{pag_ibig}|#{phil_health}|#{tin}|#{y.pn_number}|#{contract_type}|AC|NA|#{y.principal}|#{y.principal_balance}|#{date_rel}|#{mat_date}|#{int_rate}|#{y.term}|#{y.num_installments}|Php|#{loan_purpose}|#{pod_type}|#{tot_loan_balance}|#{mat_date}|#{over_due_days}|#{monthly_payment}|#{outs_payment}|#{last_payment}"
    @data << j
    end
    puts @data
  puts "END"
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
