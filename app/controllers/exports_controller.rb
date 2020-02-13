class ExportsController < ApplicationController
  before_action :authenticate_user!

  def members
    @start_date = params[:start_date].try(:to_date)
    @end_date = params[:end_date].try(:to_date)
    @branch_id = params[:branch]

    if !@start_date.nil? && !@end_date.nil? && !@branch_id.nil?
      #@members = Member.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
      @members = Member.where("Date(members.updated_at) >= ? AND Date(members.updated_at) <= ? AND branch_id = ?", @start_date, @end_date, @branch_id)
      send_data Exports::GenerateMembersCsv.new(members: @members).execute!, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=members #{@start_date}_#{@end_date}.csv"
    elsif !@branch_id.nil?
      @members = Member.where(branch_id: @branch_id)
      send_data Exports::GenerateMembersCsv.new(members: @members).execute!, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=members.csv"
    else
      @members = Member.all
      send_data Exports::GenerateMembersCsv.new(members: @members).execute!, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=members.csv"
    end  
  end

  def beneficiaries
    @start_date = params[:start_date].try(:to_date)
    @end_date = params[:end_date].try(:to_date)
    @branch_id = params[:branch]

    if !@start_date.nil? && !@end_date.nil? && !@branch_id.nil?
      @beneficiaries = Beneficiary.joins(:member).where("Date(beneficiaries.updated_at) >= ? AND Date(beneficiaries.updated_at) <= ? AND members.branch_id = ?", @start_date, @end_date, @branch_id)
      send_data Exports::GenerateBeneficiariesCsv.new(beneficiaries: @beneficiaries).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=beneficiaries #{@start_date}_#{@end_date}.csv"
    elsif !@branch_id.nil?
      @beneficiaries = Beneficiary.joins(:member).where("members.branch_id = ?", @branch_id)
      send_data Exports::GenerateBeneficiariesCsv.new(beneficiaries: @beneficiaries).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=beneficiaries.csv"
    else
      @beneficiaries = Beneficiary.all
      send_data Exports::GenerateBeneficiariesCsv.new(beneficiaries: @beneficiaries).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=beneficiaries.csv"
    end
  end

  def legal_dependents
    @start_date = params[:start_date].try(:to_date)
    @end_date = params[:end_date].try(:to_date)
    @branch_id = params[:branch]

    if !@start_date.nil? && !@end_date.nil? && !@branch_id.nil?
      @legal_dependents = LegalDependent.joins(:member).where("Date(legal_dependents.updated_at) >= ? AND Date(legal_dependents.updated_at) <= ? AND members.branch_id = ?", @start_date, @end_date, @branch_id)
      send_data Exports::GenerateLegalDependentsCsv.new(legal_dependents: @legal_dependents).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=legal dependents #{@start_date}_#{@end_date}.csv"
    elsif !@branch_id.nil?
      @legal_dependents = LegalDependent.joins(:member).where("members.branch_id = ?", @branch_id)
      send_data Exports::GenerateLegalDependentsCsv.new(legal_dependents: @legal_dependents).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=legal dependents.csv"
    else
      @legal_dependents = LegalDependent.all
      send_data Exports::GenerateLegalDependentsCsv.new(legal_dependents: @legal_dependents).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=legal dependents.csv"
    end
  end

  def member_accounts
    @start_date = params[:start_date].try(:to_date)
    @end_date = params[:end_date].try(:to_date)
    @branch_id = params[:branch]

    if !@start_date.nil? && !@end_date.nil? && !@branch_id.nil?
      @member_accounts = MemberAccount.insurance.where("Date(member_accounts.updated_at) >= ? AND Date(member_accounts.updated_at) <= ? AND member_accounts.branch_id = ?", @start_date, @end_date, @branch_id)
      send_data Exports::GenerateMemberAccountsCsv.new(member_accounts: @member_accounts).execute!, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=insurance accounts  #{@start_date}_#{@end_date}.csv"
    elsif !@branch_id.nil?
      @member_accounts = MemberAccount.insurance.where(branch_id: @branch_id)
      send_data Exports::GenerateMemberAccountsCsv.new(member_accounts: @member_accounts).execute!, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=insurance accounts.csv"
    else
      @insurance_accounts = MemberAccount.insurance.all
      send_data Exports::GenerateMemberAccountsCsv.new(member_accounts: @member_accounts).execute!, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=insurance accounts.csv"
    end
  end

  def account_transactions
    @start_date = params[:start_date].try(:to_date)
    @end_date = params[:end_date].try(:to_date)
    @branch_id = params[:branch]
    
    if !@start_date.nil? && !@end_date.nil? && !@branch_id.nil?
      @member_accounts = MemberAccount.insurance.where(branch_id: @branch_id)
      @account_transactions = AccountTransaction.where("Date(account_transactions.updated_at) >= ? AND Date(account_transactions.updated_at) <= ? AND subsidiary_id IN (?)", @start_date, @end_date, @member_accounts.pluck(:id))
      send_data Exports::GenerateAccountTransactionsCsv.new(account_transactions: @account_transactions).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=insurance account transactions #{@start_date}_#{@end_date}.csv"
    elsif !@branch_id.nil?
      @member_accounts = MemberAccount.insurance.where(branch_id: @branch_id)
      @account_transactions = AccountTransaction.where(subsidiary_id: @member_accounts.pluck(:id))
      send_data Exports::GenerateAccountTransactionsCsv.new(account_transactions: @account_transactions).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=insurance account transactions #{@start_date}_#{@end_date}.csv"
    else
      @account_transactions = AccountTransaction.insurance.all
      send_data Exports::GenerateAccountTransactionsCsv.new(account_transactions: @account_transactions).execute!, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=insurance account transactions.csv"
    end   
  end

  def members_per_branch_excel
    branch        = Branch.where(id: params[:branch_id]).first
    members       = Member.where(branch_id: branch.id).order("created_at asc")
    excel         = Members::GenerateMembersPerBranchExcel.new(members: members, branch: branch).execute!
    filename      = "members_#{branch.try(:to_s)}.xlsx"
    
    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def members_with_beneficiaries_excel
    @start_date = params[:start_date].try(:to_date)
    @end_date   = params[:end_date].try(:to_date)
    @branch_id  = params[:branch]
    @branch     = Branch.where(id: @branch_id).first

    if !@start_date.nil? && !@end_date.nil? && !@branch_id.nil?
      members       = Member.insurance_active.where("branch_id = ? AND data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ?", @branch.id, @start_date, @end_date).order("created_at asc")
    elsif !@branch_id.nil?
      members       = Member.insurance_active.where("branch_id = ?", @branch.id).order("created_at asc")
    else
      members = Member.insurance_active
    end    

    excel         = Members::GenerateMembersWithBeneficiariesExcel.new(members: members, branch: @branch).execute!
    filename      = "#{@branch.try(:to_s)}_members_with_beneficiaries.xlsx"
    
    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def billing_per_center
    center        = Center.where(id: params[:center_id]).first
    members       = Member.active.where(center_id: center.id).order("last_name ASC")
    excel         = Exports::GenerateBillingPerCenterExcel.new(members: members, center: center).execute!
    filename      = "billing_of_#{center.name.try(:to_s)}.xlsx"
    
    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end
end
