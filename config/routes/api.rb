namespace :api do
  namespace :v1 do
    # Accounting Codes
    get "/accounting_codes", to: "accounting_codes#index"

    # Adjustments
    namespace :adjustments do
      post "/subsidiary_adjustments/create", to: "subsidiary_adjustments#create"
      post "/subsidiary_adjustments/approve", to: "subsidiary_adjustments#approve"
      post "/subsidiary_adjustments/destroy", to: "subsidiary_adjustments#destroy"
      post "/subsidiary_adjustments/add_member", to: "subsidiary_adjustments#add_member"
      post "/subsidiary_adjustments/delete_member", to: "subsidiary_adjustments#delete_member"
      post "/subsidiary_adjustments/add_accounting_code", to: "subsidiary_adjustments#add_accounting_code"
      post "/subsidiary_adjustments/delete_accounting_code", to: "subsidiary_adjustments#delete_accounting_code"
      post "/subsidiary_adjustments/update_accounting_entry_particular", to: "subsidiary_adjustments#update_accounting_entry_particular"

      post "/batch_moratorium_adjustments/create", to: "batch_moratorium_adjustments#create"
      post "/batch_moratorium_adjustments/approve", to: "batch_moratorium_adjustments#approve"
      post "/batch_moratorium_adjustments/destroy", to: "batch_moratorium_adjustments#destroy"
    end

    # Users
    post "/login", to: "users#login"
    get "/roles", to: "users#roles"

    # Dashboard
    get "/dashboard", to: "dashboard#index"

    # Monitoring
    get "/monitoring/accounting_entry_subsidiary_balancing", to: "monitoring#accounting_entry_subsidiary_balancing"
    get "/monitoring/accounting_entry_precision", to: "monitoring#accounting_entry_precision"

    # Members
    get "/members", to: "members#index"
    get "/members/fetch", to: "members#fetch"
    get "/members/fetch_survey_answer", to: "members#fetch_survey_answer"
    get "/members/fetch_resignation_details", to: "members#fetch_resignation_details"
    post "/members/process_resignation", to: "members#process_resignation"
    get "/members/member_co_makers", to: "members#member_co_makers"
    get "/members/member_loan_products", to: "members#member_loan_products"
    post "/members/create_survey", to: "members#create_survey"
    post "/members/delete_survey_answer", to: "members#delete_survey_answer"
    post "/members/generate_access_token", to: "members#generate_access_token"
    post "/members/save_signature", to: "members#save_signature"
    post "/members/save", to: "members#save"
    post "/members/save_survey_answer", to: "members#save_survey_answer"
    post "/members/delete", to: "members#delete"
    post "/members/unlock", to: "members#unlock"
    post "/members/restore", to: "members#restore"
    post "/members/generate_missing_accounts", to: "members#generate_missing_accounts"
    post "/members/change_member_type", to: "members#change_member_type"
    post "/members/change_recognition_date", to: "members#change_recognition_date"

    # Member accounts
    get "/savings_accounts", to: "savings_accounts#index"
    post "/savings_accounts/sync_maintaining_balance", to: "savings_accounts#sync_maintaining_balance"

    # /api/
    # Member Parameter
    # 
    get "/insurance_accounts/fetch_insurance_status", to: "insurance_accounts#fetch_insurance_status"

    # Accounting
    get "/accounting/fetch_trial_balance", to: "accounting#fetch_trial_balance"
    get "/accounting/fetch_general_ledger", to: "accounting#fetch_general_ledger"

    # Accounting Entries
    get "/accounting_entries/fetch", to: "accounting_entries#fetch"
    post "/accounting_entries/save", to: "accounting_entries#save"
    post "/accounting_entries/approve", to: "accounting_entries#approve"
    post "/accounting_entries/modify_date_posted", to: "accounting_entries#modify_date_posted"

    # Loans
    post "/loans/change_book", to: "loans#change_book"
    post "/loans/approve", to: "loans#approve"
    post "/loans/reage", to: "loans#reage"
    post "/loans/delete", to: "loans#delete"
    post "/loans/apply", to: "loans#apply"
    post "/loans/save", to: "loans#save"
    post "/loans/update_first_date_of_payment", to: "loans#update_first_date_of_payment"
    post "/loans/update_date_released", to: "loans#update_date_released"
    post "/loans/delay_amort", to: "loans#delay_amort"
    post "/loans/new_adjustment", to: "loans#new_adjustment"
    post "/loans/delete_adjustment", to: "loans#delete_adjustment"
    post "/loans/approve_adjustment", to: "loans#approve_adjustment"
    get "/loans/fetch", to: "loans#fetch"

    # Branches
    get "/branches", to: "branches#index"
    get "/branches/fetch_centers", to: "branches#fetch_centers"
    get "/branches/:id/stats", to: "branches#stats"

    # Accounting Funds
    get "/accounting_funds", to: "accounting_funds#index"

    # Centers
    get "/centers", to: "centers#index"
  
    # Print Services
    post "/print/generate_file", to: "print#generate_file"

    # Billing
    post "/billings", to: "billings#create"
    post "/billings/modify_transaction_record", to: "billings#modify_transaction_record"
    post "/billings/toggle_attendance", to: "billings#toggle_attendance"
    post "/billings/toggle_attendance_on", to: "billings#toggle_attendance_on"
    post "/billings/toggle_attendance_off", to: "billings#toggle_attendance_off"
    post "/billings/approve", to: "billings#approve"
    post "/billings/zero_out", to: "billings#zero_out"
    post "/billings/check", to: "billings#check"
    post "/billings/update_or_number", to: "billings#update_or_number"
    post "/billings/update_ar_number", to: "billings#update_ar_number"
    post "/billings/update_particular", to: "billings#update_particular"
    post "/billings/update_book", to: "billings#update_book"
    get "/billings/fetch", to: "billings#fetch"

    # Monthly Closing Collection
    get "/monthly_closing_collections/fetch", to: "monthly_closing_collections#fetch"
    post "/monthly_closing_collections", to: "monthly_closing_collections#create"
    post "/monthly_closing_collections/update", to: "monthly_closing_collections#update"
    post "/monthly_closing_collections/approve", to: "monthly_closing_collections#approve"

    # Membership Payment Collection
    post "/membership_payment_collections", to: "membership_payment_collections#create"
    post "/membership_payment_collections/modify_transaction_record", to: "membership_payment_collections#modify_transaction_record"
    post "/membership_payment_collections/approve", to: "membership_payment_collections#approve"
    post "/membership_payment_collections/update_or_number", to: "membership_payment_collections#update_or_number"
    post "/membership_payment_collections/update_ar_number", to: "membership_payment_collections#update_ar_number"
    post "/membership_payment_collections/update_particular", to: "membership_payment_collections#update_particular"
    get "/membership_payment_collections/fetch", to: "membership_payment_collections#fetch"
    get "/membership_payment_collections/fetch_members", to: "membership_payment_collections#fetch_members"
    post "/membership_payment_collections/add_member", to: "membership_payment_collections#add_member"
    post "/membership_payment_collections/remove_member", to: "membership_payment_collections#remove_member"

    # Deposit Collection
    post "/deposit_collections", to: "deposit_collections#create"
    post "/deposit_collections/modify_transaction_record", to: "deposit_collections#modify_transaction_record"
    post "/deposit_collections/approve", to: "deposit_collections#approve"
    post "/deposit_collections/update_or_number", to: "deposit_collections#update_or_number"
    post "/deposit_collections/update_ar_number", to: "deposit_collections#update_ar_number"
    post "/deposit_collections/update_particular", to: "deposit_collections#update_particular"
    post "/deposit_collections/update_accounting_fund", to: "deposit_collections#update_accounting_fund"
    get "/deposit_collections/fetch", to: "deposit_collections#fetch"
    get "/deposit_collections/fetch_members", to: "deposit_collections#fetch_members"
    get "/deposit_collections/fetch_accounting_funds", to: "deposit_collections#fetch_accounting_funds"
    post "/deposit_collections/add_member", to: "deposit_collections#add_member"
    post "/deposit_collections/remove_member", to: "deposit_collections#remove_member"
    post "/deposit_collections/modify_cash_management_template", to: "deposit_collections#modify_cash_management_template"
    post "/deposit_collections/modify_book", to: "deposit_collections#modify_book"
    post "/deposit_collections/load_branch", to: "deposit_collections#load_branch"
    post "/deposit_collections/load_center", to: "deposit_collections#load_center"

    # Time Deposit Collection
    post "/time_deposit_collections", to: "time_deposit_collections#create"
    post "/time_deposit_collections/approve", to: "time_deposit_collections#approve"
    get "/time_deposit_collections/fetch", to: "time_deposit_collections#fetch"
    get "/time_deposit_collections/fetch_members", to: "time_deposit_collections#fetch_members"
    post "/time_deposit_collections/update_or_number", to: "time_deposit_collections#update_or_number"
    post "/time_deposit_collections/update_ar_number", to: "time_deposit_collections#update_ar_number"
    post "/time_deposit_collections/update_particular", to: "time_deposit_collections#update_particular"
    post "/time_deposit_collections/modify_cash_management_template", to: "time_deposit_collections#modify_cash_management_template"
    post "/time_deposit_collections/modify_book", to: "time_deposit_collections#modify_book"
    post "/time_deposit_collections/add_member", to: "time_deposit_collections#add_member"
    post "/time_deposit_collections/remove_member", to: "time_deposit_collections#remove_member"

    # Withdrawal Collection
    post "/withdrawal_collections", to: "withdrawal_collections#create"
    post "/withdrawal_collections/modify_transaction_record", to: "withdrawal_collections#modify_transaction_record"
    post "/withdrawal_collections/approve", to: "withdrawal_collections#approve"
    post "/withdrawal_collections/update_or_number", to: "withdrawal_collections#update_or_number"
    post "/withdrawal_collections/update_ar_number", to: "withdrawal_collections#update_ar_number"
    post "/withdrawal_collections/update_particular", to: "withdrawal_collections#update_particular"
    get "/withdrawal_collections/fetch", to: "withdrawal_collections#fetch"
    get "/withdrawal_collections/fetch_members", to: "withdrawal_collections#fetch_members"
    post "/withdrawal_collections/add_member", to: "withdrawal_collections#add_member"
    post "/withdrawal_collections/remove_member", to: "withdrawal_collections#remove_member"

    # Insurance Withdrawal Collection
    post "/insurance_withdrawal_collections", to: "insurance_withdrawal_collections#create"
    post "/insurance_withdrawal_collections/modify_transaction_record", to: "insurance_withdrawal_collections#modify_transaction_record"
    post "/insurance_withdrawal_collections/approve", to: "insurance_withdrawal_collections#approve"
    post "/insurance_withdrawal_collections/update_particular", to: "insurance_withdrawal_collections#update_particular"
    get "/insurance_withdrawal_collections/fetch", to: "insurance_withdrawal_collections#fetch"
    get "/insurance_withdrawal_collections/fetch_members", to: "insurance_withdrawal_collections#fetch_members"
    post "/insurance_withdrawal_collections/add_member", to: "insurance_withdrawal_collections#add_member"
    post "/insurance_withdrawal_collections/remove_member", to: "insurance_withdrawal_collections#remove_member"

    #Member Account Validations
    post 'member_account_validations/generate_transaction', to: 'member_account_validations#generate_transaction'
    post 'member_account_validations/add_member', to: 'member_account_validations#add_member'
    post 'member_account_validations/delete_member_account_validation_record', to: 'member_account_validations#delete_member_account_validation_record'
    post 'member_account_validations/approve', to: 'member_account_validations#approve'
    post 'member_account_validations/validate', to: 'member_account_validations#validate'
    post 'member_account_validations/check', to: 'member_account_validations#check'
    post 'member_account_validations/reverse', to: 'member_account_validations#reverse'
    post 'member_account_validations/cancel', to: 'member_account_validations#cancel'
    post 'member_account_validations/cancel_member', to: 'member_account_validations#cancel_member'

    # Survey Answers
    post "/survey_answers", to: "survey_answers#create"
    post "/survey_answers/save", to: "survey_answers#save"

    namespace :data_stores do
      post "/icpr/queue", to: "icpr#queue"
      get "/icpr/fetch", to: "icpr#fetch"
      post "/icpr/approve", to: "icpr#approve"
      post "/patronage_refund/queue", to: "patronage_refund#queue"
      get "/patronage_refund/fetch", to: "patronage_refund#fetch"
      post "/patronage_refund/approve", to: "patronage_refund#approve"
      post "/personal_funds/queue", to: "personal_funds#queue"
      get "/personal_funds/fetch", to: "personal_funds#fetch"
      post "/branch_loans_stats/queue", to: "branch_loans_stats#queue"
      post "/accounting_entries_summaries/queue", to: "accounting_entries_summaries#queue"
      post "/soa_expenses/queue", to: "soa_expenses#queue"
      get "/soa_expenses/fetch", to: "soa_expenses#fetch"
      post "/soa_loans/queue", to: "soa_loans#queue"
      get "/soa_loans/fetch", to: "soa_loans#fetch"
      post "/soa_funds/queue", to: "soa_funds#queue"
      get "/soa_funds/fetch", to: "soa_funds#fetch"
      post "/watchlists/queue", to: "watchlists#queue"
      get "/watchlists/fetch", to: "watchlists#fetch"
      post "/repayment_rates/queue", to: "repayment_rates#queue"
      get "/repayment_rates/fetch", to: "repayment_rates#fetch"
      post "/branch_repayment_reports/queue", to: "branch_repayment_reports#queue"
      get "/branch_repayment_reports/fetch", to: "branch_repayment_reports#fetch"
      post "/member_counts/queue", to: "member_counts#queue"
      post "/monthly_new_and_resigned/queue", to: "monthly_new_and_resigned#queue"
      post "/monthly_incentives/queue", to: "monthly_incentives#queue"
      post "/x_weeks_to_pay/queue", to: "x_weeks_to_pay#queue"
      get "/x_weeks_to_pay/fetch", to: "x_weeks_to_pay#fetch"
      post "/year_end_closings/queue", to: "year_end_closings#queue"
      post "/year_end_closings/approve", to: "year_end_closings#approve"
    end

    namespace :epassbook do
      get "/members/show", to: "members#show"
      get "/active_loans", to: "loans#active_loans"
      get "/savings", to: "savings#index"
      get "/savings/show", to: "savings#transactions"
      get "/insurances", to: "insurances#index"
      get "/insurances/show", to: "insurances#transactions"
      get "/equities", to: "equities#index"
      get "/equities/show", to: "equities#transactions"
      get "/loans/show", to: "loans#show"
      get "/loans/payments", to: "loans#payments"
    end

    namespace :administration do
      get "/user_branches", to: "user_branches#index"
      post "/user_branches/toggle", to: "user_branches#toggle"
      
      # Surveys
      post "/surveys/save", to: "surveys#save"
      post "/surveys/delete", to: "surveys#delete"
      get "/surveys/fetch", to: "surveys#fetch"

      # Survey Question
      get "/survey_questions/fetch", to: "survey_questions#fetch"
      post "/survey_questions/save", to: "survey_questions#save"
      post "/survey_questions/delete", to: "survey_questions#delete"

      # Loan Product
      post "/loan_products/delete", to: "loan_products#delete"
      post "/loan_products/modify_prerequisite", to: "loan_products#modify_prerequisite"
      post "/loan_products/modify_maintaining_balance", to: "loan_products#modify_maintaining_balance"
    end
    get 'reports/member_reports', to: 'reports#member_reports'
    get 'reports/collections_clip_reports', to: 'reports#collections_clip_reports'
    get 'reports/collections_blip_reports', to: 'reports#collections_blip_reports'
    get 'reports/member_dependent_reports', to: 'reports#member_dependent_reports'
    get 'reports/cic_reports', to: 'reports#cic_reports'
  end
end
