namespace :api do
  namespace :v1 do
    # Accounting Codes
    get "/accounting_codes", to: "accounting_codes#index"

    # Users
    post "/login", to: "users#login"
    get "/roles", to: "users#roles"

    # Dashboard
    get "/dashboard", to: "dashboard#index"

    # Monitoring
    get "/monitoring/accounting_entry_subsidiary_balancing", to: "monitoring#accounting_entry_subsidiary_balancing"

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

    # Member accounts
    get "/savings_accounts", to: "savings_accounts#index"

    # Accounting
    get "/accounting/fetch_trial_balance", to: "accounting#fetch_trial_balance"
    get "/accounting/fetch_general_ledger", to: "accounting#fetch_general_ledger"

    # Accounting Entries
    get "/accounting_entries/fetch", to: "accounting_entries#fetch"
    post "/accounting_entries/save", to: "accounting_entries#save"
    post "/accounting_entries/approve", to: "accounting_entries#approve"
    post "/accounting_entries/modify_date_posted", to: "accounting_entries#modify_date_posted"

    # Loans
    post "/loans/approve", to: "loans#approve"
    post "/loans/reage", to: "loans#reage"
    post "/loans/delete", to: "loans#delete"
    post "/loans/apply", to: "loans#apply"
    post "/loans/save", to: "loans#save"
    post "/loans/update_first_date_of_payment", to: "loans#update_first_date_of_payment"
    post "/loans/update_date_released", to: "loans#update_date_released"
    get "/loans/fetch", to: "loans#fetch"

    # Branches
    get "/branches", to: "branches#index"
    get "/branches/fetch_centers", to: "branches#fetch_centers"
    get "/branches/:id/stats", to: "branches#stats"

    # Print Services
    post "/print/generate_file", to: "print#generate_file"

    # Billing
    post "/billings", to: "billings#create"
    post "/billings/modify_transaction_record", to: "billings#modify_transaction_record"
    post "/billings/toggle_attendance", to: "billings#toggle_attendance"
    post "/billings/approve", to: "billings#approve"
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
    get "/deposit_collections/fetch", to: "deposit_collections#fetch"
    get "/deposit_collections/fetch_members", to: "deposit_collections#fetch_members"
    post "/deposit_collections/add_member", to: "deposit_collections#add_member"
    post "/deposit_collections/remove_member", to: "deposit_collections#remove_member"

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

    # Survey Answers
    post "/survey_answers", to: "survey_answers#create"
    post "/survey_answers/save", to: "survey_answers#save"

    namespace :data_stores do
      post "/branch_loans_stats/queue", to: "branch_loans_stats#queue"
      post "/branch_repayment_reports/queue", to: "branch_repayment_reports#queue"
      get "/branch_repayment_reports/fetch", to: "branch_repayment_reports#fetch"
      post "/member_counts/queue", to: "member_counts#queue"
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
  end
end
