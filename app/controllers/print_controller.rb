class PrintController < ApplicationController
  before_action :authenticate_user!

  def print
    #raise params[:type].inspect
    type  = params[:type]
    data  = {}

    errors = {
      messages: {},
      full_messages: []
    }

    if type == "print_monthly_incentives"
      monthly_incentive = params[:id]
      data = ::Print::BuildMonthlyIncentive.new(config: monthly_incentive).execute!

      @monthly_incentive = data
      render "print/monthly_incentive",layout: "print"
    elsif type == "print_second_involuntary_letter"
      data_str = params[:data]
      data = ::Print::BuildInvoluntarySecondLetter.new(config: JSON.parse(data_str)).execute!
      @data = data
      render "print/print_involuntary_second_letter", layout: "print"
    elsif type == "involuntary_members_list"
      id = params[:id]
      data = ::Print::BuildInvoluntaryMasterList.new(config: id).execute!
      @data = data
      render "print/involuntary_master_list", layout: "print"
    elsif type == "print_involuntary_members"
      data_str = params[:data]
      data = ::Print::BuildInvoluntaryLetter.new(config: JSON.parse(data_str)).execute!
      @data = data
      render "print/print_involuntary_letter",layout: "print"

    elsif type == "print_adjustment_record"

      adjustment_record = params[:id]
      data = ::Print::SubsidiaryPrint.new(config: adjustment_record).execute!
       @adjustment_record = data
       #raise @adjustment_record[:debit_journal_entries].inspect
       render "print/adjustment_record", layout: "print"

    elsif type == "accounting_entry"
      accounting_entry = AccountingEntry.find(params[:id])
      data  = ::Print::BuildAccountingEntry.new(
                accounting_entry: accounting_entry
              ).execute!
      @accounting_entry_data  = data
      render "print/accounting_entry", layout: "print"

    elsif type == "print_migs"
      migs = DataStore.find(params[:id])
      data = ::Print::BuildPrintMigs.new(
              migs: migs
              ).execute!
      @migs = data
      render "print/print_migs", layout: "print"

    elsif type == "print_pr"

      icpr = DataStore.find(params[:id])

      data  = ::Print::BuildPrintIcpr.new(
                icpr: icpr
              ).execute!

      @icpr  = data
      render "print/print_icpr", layout: "print"

    elsif type =="print_involuntary_tagging"
      print_involuntary = params[:id]
        data = ::Print::BuildPrintInvoluntaryTagging.new(
          config: print_involuntary
        ).execute!

      @print_involuntary = data
      render "print/print_involuntary_tagging", layout: "print"
    elsif type == "print_online_loan_application" 
      @online_application = LoanApplication.find(params[:id])
      @online_application_loan_product = LoanProduct.find(@online_application.loan_product_id).name
      @member_data = Member.find(@online_application.member_id)
      @cycle = Member.find(@online_application.member_id).data.with_indifferent_access
      @member_comaker = Member.find(@online_application.co_maker_member_id)
      @center = Center.find(@member_data.center_id).name
    
      @online_application_loan = Loan.where(member_id: @online_application.member_id, loan_product_id: @online_application.loan_product_id, status: ["active", "paid"]).last
     if @online_application_loan.nil?
      @cyc1 = 1
      @prev_loan = 0.0 
     else
      @cyc =  @online_application_loan.cycle += 1
     end
      
      @project_type = ProjectType.find(@online_application.data["project_type_id"])
      render "print/print_online_loan_application", layout: "print"

    elsif type == "print_entry"
      data_store_entry = DataStore.find(params[:id])
      data  = ::Print::BuildIcprAccountingEntry.new(
                data_entry: data_store_entry
              ).execute!
      @data_store_entry  = data
      render "print/print_entry", layout: "print"

    elsif type == "accrued_billing"
      accrued_billing = AccruedBilling.find(params[:id])
      data = ::Print::BuildAccruedBilling.new(accrued_billing: accrued_billing ).execute!
      @accrued_billing = data
      render "print/accrued_billing", layout: "print"

    elsif type == "print_ledger"
      savings_account = MemberAccount.find(params[:id])
      data= ::Print::PrintSavingsLedger.new(member_account: savings_account ).execute!
      @member_account = data
      render "print/print_ledger", layout: "print"

    elsif type == "claims_voucher"
      accounting_entry = AccountingEntry.find(params[:id])

      data  = ::Print::BuildAccountingEntry.new(
                accounting_entry: accounting_entry
              ).execute!

      @accounting_entry_data  = data
      @claim = Claim.find(params[:cid])

      render "print/claims_voucher", layout: "print"
    elsif type == "claims_daily_report"
      @date_today = Date.today

      @claims              = Claim.where("date_prepared >= ? AND date_prepared <= ?", @date_today, @date_today).order("status ASC")
      @posted_claims       = Claim.where("status = ? AND date_prepared >= ? AND date_prepared <= ?", "approved", @date_today, @date_today)
      @pending_claims      = Claim.where("status = ? AND date_prepared >= ? AND date_prepared <= ?", "pending", @date_today, @date_today)
      @for_approval_claims = Claim.where("status = ? AND date_prepared >= ? AND date_prepared <= ?", "for-approval", @date_today, @date_today)
      @for_posting_claims  = Claim.where("status = ? AND date_prepared >= ? AND date_prepared <= ?", "for-posting", @date_today, @date_today)

      render "print/claims_daily_report", layout: "print"
    elsif type == "deposit_collection_accounting_entry"
      deposit_collection = DepositCollection.find(params[:id])
      accounting_entry   = deposit_collection.approved_accounting_entry

      data  = ::Print::BuildAccountingEntry.new(
                accounting_entry: accounting_entry
              ).execute!

      @accounting_entry_data  = data

      render "print/accounting_entry", layout: "print"

    elsif type == "claims_copy"
      @member = Member.find(params[:member_id])
      @date_of_death = Date.today

      if params[:date_of_death].present?
        @date_of_death = params[:date_of_death].try(:to_date)
      end

      @lif_insurance_account = @member.member_accounts.where(account_subtype:"Life Insurance Fund").first
      @rf_insurance_account  = @member.member_accounts.where(account_subtype:"Retirement Fund").first

      config = {
                member: @member,
                lif_insurance_account: @lif_insurance_account,
                rf_insurance_account: @rf_insurance_account,
                date_of_death: @date_of_death
              }

      @payment_meta = Insurance::GenerateInsuranceAccountDetailsForLifAndRf.new(
                      config: config
                    ).execute!

      render "print/claims_copy", layout: "print"
    elsif type == "member_share"
      member_share = MemberShare.find(params[:id])

      data  = ::Print::BuildMemberShare.new(
                member_share: member_share
              ).execute!

      # Update printing information
      member_share.update!(
        data: {
          printed: true,
          date_printed: Date.today
        }
      )

      @member_share_data  = data

      render "print/member_share", layout: "print"
    elsif type == "member_share_for_mba"
      member_share = MemberShare.find(params[:id])

      data  = ::Print::BuildMemberShareForMba.new(
                member_share: member_share
              ).execute!

      # Update printing information
      member_share.update!(
        data: {
          printed: true,
          date_printed: Date.today
        }
      )

      @member_share_data  = data

      render "print/member_share_for_mba", layout: "print"
    elsif type == "billing"
      billing = Billing.find(params[:id])

      data  = ::Print::BuildBilling.new(
                billing: billing
              ).execute!

      @billing  = data

      render "print/billing", layout: "print"

    elsif type == "print_thermal"
      billing = Billing.find(params[:id])

      data = ::Print::BuildBilling.new(
        billing: billing
        ).execute!

      @billing = data
      render "print/print_thermal", layout:"print"

    elsif type == "wp"
      billing = Billing.find(params[:id])

      data  = ::Print::BuildBilling.new(
                billing: billing
              ).execute!

      @billing  = data

      render "print/wp", layout: "print"
    elsif type == "membership_payment_collection"
      membership_payment_collection = MembershipPaymentCollection.find(params[:id])

      data  = ::Print::BuildMembershipPaymentCollection.new(
                membership_payment_collection: membership_payment_collection
              ).execute!

      @membership_payment_collection = data

      render "print/membership_payment_collection", layout: "print"

    elsif type == "membership_payment_collection_thermal"
      membership_payment_collection = MembershipPaymentCollection.find(params[:id])
      member_data = membership_payment_collection.data.with_indifferent_access
      @members = member_data[:records].map do |member|
        insurance_subtypes = ["Life Insurance Fund", "Retirement Fund", "Hospital Income Insurance Plan", "K-BENTE", "K-KALINGA", "K-MBA"]
        kcoop_subtypes = ["Share Capital", "Maintaining Balance Savings", "K-KOOP", "ID"]
      
        insurance_total = member[:records].select { |record| insurance_subtypes.include?(record[:account_subtype]) }.sum { |record| record[:amount] }
        kcoop_total = member[:records].select { |record| kcoop_subtypes.include?(record[:account_subtype]) || record[:record_type] == "ID" }.sum { |record| record[:amount] }
      
        {
          full_name: member[:member][:full_name],
          insurance_total: insurance_total,
          kcoop_total: kcoop_total
        }
      end
      
      @grand_insurance_total = @members.sum { |member| member[:insurance_total] }
      @grand_kcoop_total = @members.sum { |member| member[:kcoop_total] }

      
      data  = ::Print::BuildMembershipPaymentCollection.new(
                membership_payment_collection: membership_payment_collection
              ).execute!

      @membership_payment_collection_thermal = data
      
      render "print/membership_payment_collection_thermal", layout: "print"

    elsif type == "general_ledger"
      data = DataStore.general_ledgers.find(params[:id]).data.with_indifferent_access

      @general_ledger = data

      render "print/general_ledger", layout: "print"
    elsif type == "trial_balance"
      trial_balance = DataStore.find(params[:id])

      start_date  = trial_balance[:start_date]
      end_date    = trial_balance[:end_date]
      branch = Branch.find(trial_balance.meta['branch_id'])

      config  = {
        start_date: start_date,
        end_date: end_date,
        branch:  branch
      }

      trial_balance_data  = ::Accounting::FetchTrialBalance.new(
                              config: config
                            ).execute!

      data  = ::Accounting::FetchTrialBalance.new(
                config: config
              ).execute!

      @trial_balance  = data

      render "print/trial_balance", layout: "print"
    elsif type == "book"
      start_date  = params[:start_date].try(:to_date)
      end_date    = params[:end_date].try(:to_date)
      book        = params[:book]
      branch      = Branch.where(id: params[:branch_id]).first

      config  = {
        start_date: start_date,
        end_date: end_date,
        book: book,
        branch: branch
      }

      data  = ::Print::BuildBook.new(
                config: config
              ).execute!

      @book = data

      render "print/book", layout: "print"
    elsif type == "deposit_collection"
      deposit_collection  = DepositCollection.find(params[:id])

      config  = {
        deposit_collection: deposit_collection
      }

      data  = ::Print::BuildDepositCollection.new(
                config: config
              ).execute!

      @deposit_collection = data

      render "print/deposit_collection", layout: "print"
    elsif type == "insurance_fund_transfer_collection"
      insurance_fund_transfer_collection  = InsuranceFundTransferCollection.find(params[:id])

      config  = {
        insurance_fund_transfer_collection: insurance_fund_transfer_collection
      }

      data  = ::Print::BuildFundTransferCollection.new(
                                            config: config
                                            ).execute!

      @insurance_fund_transfer_collection = data

      render "print/insurance_fund_transfer_collection", layout: "print"
    elsif type == "time_deposit_collection"
      time_deposit_collection = TimeDepositCollection.find(params[:id])

      config  = {
        time_deposit_collection: time_deposit_collection
      }

      data  = ::Print::BuildTimeDepositCollection.new(
                config: config
              ).execute!

      @deposit_collection = data

      render "print/deposit_collection", layout: "print"
    elsif type == "withdrawal_collection"
      withdrawal_collection = WithdrawalCollection.find(params[:id])

      config  = {
        withdrawal_collection: withdrawal_collection
      }

      data  = ::Print::BuildWithdrawalCollection.new(
                config: config
              ).execute!

      @withdrawal_collection = data

      render "print/withdrawal_collection", layout: "print"
    elsif type == "withdrawal_request"
      data_store = DataStore.find(params[:id])

      config  = {
        data_store: data_store
      }

      data  = ::Print::BuildWithdrawalRequest.new(
                config: config
              ).execute!

      @withdrawal_request = data

    elsif type == "repayment_rates"

      repayment_rate = DataStore.find(params[:id])

      if params[:center_id].present?
        repayment_rate.data["records"] = repayment_rate.data["records"].select { |rec| rec["center"]["id"] == params[:center_id] }
      end
      if params[:loan_product_id].present?
        repayment_rate.data["records"] = repayment_rate.data["records"].select { |rec| rec["loan_product"]["id"] == params[:loan_product_id] }
      end

      if params[:officer_id].present?
        repayment_rate.data["records"] = repayment_rate.data["records"].select { |rec| rec["officer"]["id"] == params[:officer_id] }
      end

      total_principal = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["principal"] }
      total_principal_paid = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["principal_paid"] }
      total_overall_principal_balance = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["overall_principal_balance"] }
      total_interest = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["interest"] }
      total_interest_paid = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["interest_paid"] }
      total_overall_balance = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["overall_balance"] }
      total_principal_paid_due = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["principal_paid_due"] }
      total_principal_balance = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["principal_balance"] }
      total_principal_due  = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["principal_due"] }

      total_total_paid = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["total_paid"] }
      total_overall_interest_balance = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["overall_interest_balance"] }



      total_interest_paid_due = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["interest_paid_due"] }
      total_paid_due = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["total_paid_due"] }
      total_total_due = repayment_rate.data["records"].inject(0) { |sum, hash| sum + hash["total_due"] }

      if total_total_due != 0
        total_rr = (total_paid_due / total_total_due) * 100
      else
        total_rr = 0
      end
      # total_rr = (total_rr * 100)/repayment_rate.data["records"].length.to_f

      if total_principal_due != 0
        total_principal_rr = (total_principal_paid_due / total_principal_due) * 100
      # total_principal_rr = (total_principal_rr  * 100 )/repayment_rate.data["records"].length.to_f
      else
        total_principal_rr = 0
      end


      repayment_rate.data["total_principal"] = total_principal
      repayment_rate.data["total_principal_paid"] = total_principal_paid
      repayment_rate.data["total_overall_principal_balance"] = total_overall_principal_balance
      repayment_rate.data["total_interest"] = total_interest
      repayment_rate.data["total_interest_paid"] = total_interest_paid
      repayment_rate.data["total_overall_balance"] = total_overall_balance
      repayment_rate.data["total_principal_paid_due"] = total_principal_paid_due
      repayment_rate.data["total_principal_balance"] = total_principal_balance
      repayment_rate.data["total_principal_due"] = total_principal_due
      repayment_rate.data["total_total_paid"] = total_total_paid
      repayment_rate.data["total_overall_interest_balance"] = total_overall_interest_balance


      repayment_rate.data["total_interest_paid_due"] = total_interest_paid_due
      repayment_rate.data["total_paid_due"] = total_paid_due
      repayment_rate.data["total_principal_rr"] = total_principal_rr
      repayment_rate.data["total_rr"] = total_rr

      # puts "DSAASSADSADSADSADSADAS".inspect
      # ap repayment_rate.data

      data = ::Print::BuildRepaymentRates.new(repayment_rate: repayment_rate).execute!

      @repayment_rate = data



     render "print/repayment_rate", layout:"print"

    elsif type == "print_kbente_bill"
      print_kbente_bill = SavingsInsuranceTransferCollection.find(params[:id])

      config  = {
        print_kbente_bill: print_kbente_bill
      }

      data  = ::Print::BuildPrintKbenteBill.new(
                config: config
              ).execute!

      @print_kbente_bill = data

      render "print/print_kbente_bill", layout: "print"

    elsif type == "print_kkalinga_bill"
      print_kkalinga_bill = SavingsInsuranceTransferCollection.find(params[:id])

      config  = {
        print_kkalinga_bill: print_kkalinga_bill
      }

      data  = ::Print::BuildPrintKkalingaBill.new(
                config: config
              ).execute!

      @print_kkalinga_bill = data

      render "print/print_kkalinga_bill", layout: "print"

    elsif type == "print_insurance_loan_bundle_enrollment"
      print_insurance_loan_bundle_enrollment  = InsuranceLoanBundleEnrollment.find(params[:id])

      @print_insurance_loan_bundle_enrollment = print_insurance_loan_bundle_enrollment
      # raise @print_insurance_loan_bundle_enrollment.inspect
      render "print/print_kok", layout: "print"

    elsif type == "print_share_certificate"

      # @member_shares  = MemberShare.printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id)).order(Arel.sql("member_shares.data->> 'date_printed' DESC"))

      @member_shares = MemberShare
        .printed
        .includes(member: [:branch, :center])
        .where(members: { branch_id: @branches.pluck(:id) })
        .order(Arel.sql("member_shares.data->>'date_printed' DESC"))

      if params[:branch_id].present?
        @branch_id  = params[:branch_id]
        #raise @branch_id.inspect
        @member_shares  = @member_shares.where("members.branch_id =  ?" , @branch_id)
      end
      if params[:center_id].present?
        @member_shares  = @member_shares.where("members.center_id =  ?" , params[:center_id])
      end
      if params[:start_date].present? and params[:end_date].present?
        #d = (params[:end_date].to_date + 1).to_s
        @member_shares = @member_shares.where("member_shares.data->> 'date_printed' >= ? and member_shares.data->> 'date_printed' <= ?  ", params[:start_date] , params[:end_date])
      end

      render "print/print_member_shares", layout: "print"

    else
      raise "Invalid type: #{type}"
    end
  end
end
