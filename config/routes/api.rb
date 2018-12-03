namespace :api do
  namespace :v1 do
    # Accounting Codes
    get "/accounting_codes", to: "accounting_codes#index"

    # Users
    post "/login", to: "users#login"
    get "/roles", to: "users#roles"

    # Members
    get "/members", to: "members#index"
    get "/members/fetch", to: "members#fetch"
    get "/members/fetch_survey_answer", to: "members#fetch_survey_answer"
    get "/members/member_co_makers", to: "members#member_co_makers"
    get "/members/member_loan_products", to: "members#member_loan_products"
    post "/members/create_survey", to: "members#create_survey"
    post "/members/delete_survey_answer", to: "members#delete_survey_answer"
    post "/members/generate_access_token", to: "members#generate_access_token"
    post "/members/save_signature", to: "members#save_signature"
    post "/members/save", to: "members#save"
    post "/members/save_survey_answer", to: "members#save_survey_answer"
    post "/members/delete", to: "members#delete"

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
    post "/billings/update_or_number", to: "billings#update_or_number"
    post "/billings/update_ar_number", to: "billings#update_ar_number"
    post "/billings/update_particular", to: "billings#update_particular"
    post "/billings/update_book", to: "billings#update_book"
    get "/billings/fetch", to: "billings#fetch"

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

    # Survey Answers
    post "/survey_answers", to: "survey_answers#create"
    post "/survey_answers/save", to: "survey_answers#save"

    namespace :data_stores do
      post "/branch_loans_stats/queue", to: "branch_loans_stats#queue"
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
    end
  end
end
