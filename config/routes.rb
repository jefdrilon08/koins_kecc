Rails.application.routes.draw do
  devise_for :users, skip: [:sessions]

  as :user do
    get 'login', to: 'pages#login', as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # export tools page
  get "/export_tools", to: "pages#export_tools"

  #billing
  get "/billing_per_center", to: "pages#billing_per_center"

   # import
  get "/import_members", to: "pages#import_members"
  get "/import_beneficiaries", to: "pages#import_beneficiaries"
  get "/import_legal_dependents", to: "pages#import_legal_dependents"
  get "/import_insurance_accounts", to: "pages#import_insurance_accounts"
  get "/import_insurance_account_transactions", to: "pages#import_insurance_account_transactions"

  # upload-deposit page
  get "/upload_deposit", to: "pages#upload_deposit"
  get "/upload_insurance_withdrawal", to: "pages#upload_insurance_withdrawal"
  get "/upload_fund_transfer", to: "pages#upload_fund_transfer"
  
  # Adjustments
  namespace :adjustments do
    get "/subsidiary_adjustments", to: "subsidiary_adjustments#index", as: :subsidiary_adjustments
    get "/subsidiary_adjustments/:id", to: "subsidiary_adjustments#show", as: :subsidiary_adjustment

    get "/batch_moratorium_adjustments", to: "batch_moratorium_adjustments#index", as: :batch_moratorium_adjustments
    get "/batch_moratorium_adjustments/:id", to: "batch_moratorium_adjustments#show", as: :batch_moratorium_adjustment
  end
  
  # EXPORTS
  get "/exports/members", to: "exports#members", as: :export_members
  get "/exports/beneficiaries", to: "exports#beneficiaries", as: :export_beneficiaries
  get "/exports/legal_dependents", to: "exports#legal_dependents", as: :export_legal_dependents
  get "/exports/member_accounts", to: "exports#member_accounts", as: :export_member_accounts
  get "/exports/account_transactions", to: "exports#account_transactions", as: :export_account_transactions
  get "/exports/billing_per_center", to: "exports#billing_per_center", as: :export_billing_per_center

  root to: "pages#index"
  
  #Microinsurance
  get "/insurance_exit_age_members", to: "pages#insurance_exit_age_members", as: :insurance_exit_age_members
  get "/validations", to: "pages#validations", as: :validations
  get "/pages/validations_report", to: "pages#validations_report", as: :pages_validations_report
  get "/seriatim", to: "pages#seriatim", as: :seriatim
  get "/pages/seriatim_report", to: "pages#seriatim_report", as: :pages_seriatim_report
  get "/daily_report_insurance_account_status", to: "pages#daily_report_insurance_account_status", as: :daily_report_insurance_account_status
  get "/pages/daily_report_insurance_account_status_excel", to: "pages#daily_report_insurance_account_status_excel", as: :daily_report_insurance_account_status_excel
  
  # Monitoring
  get "/monitoring/accounting_entry_subsidiary_balancing", to: "monitoring#accounting_entry_subsidiary_balancing", as: :monitoring_accounting_entry_subsidiary_balancing
  get "/monitoring/accounting_entry_precision", to: "monitoring#accounting_entry_precision", as: :monitoring_accounting_entry_precision
  get "/monitoring/no_membership_payments", to: "monitoring#no_membership_payments"

  # Members
  get "/members", to: "members#index"
  get "/members/:id/display", to: "members#show", as: :member
  get "/members/:id/form_resignation", to: "members#form_resignation", as: :member_form_resignation
  get "/members/:id/blip_form_pdf", to: "members#blip_form_pdf", as: :member_blip_form_pdf

  # app/controllers/members_controller.rb
  get "/members/form", to: "members#form", as: :member_form
  get "/members/:id/survey_answers/:survey_answer_id", to: "members#survey_answer", as: :member_survey_answer
  get "/members/:id/survey_answers/:survey_answer_id/form", to: "members#survey_answer_form", as: :member_survey_answer_form

  post "/new_claim_application", to: "claims#new_claim_application", as: :new_claim_application
  post "/new_clip_claim_application", to: "clip_claims#new_clip_claim_application", as: :new_clip_claim_application
  post "/new_hiip_claim_application", to: "hiip_claims#new_hiip_claim_application", as: :new_hiip_claim_application
  post "/new_kalinga_claim_application", to: "kalinga_claims#new_kalinga_claim_application", as: :new_kalinga_claim_application
  post "/new_kbente_claim_application", to: "kbente_claims#new_kbente_claim_application", as: :new_kbente_claim_application
  post "/new_kjsp_claim_application", to: "kjsp_claims#new_kjsp_claim_application", as: :new_kjsp_claim_application
  post "/new_calamity_claim_application", to: "calamity_claims#new_calamity_claim_application", as: :new_calamity_claim_application
          
  resources :claims do
    get "/claim_validation_pdf", to: "claims#claim_validation_pdf"
    get "/claim_loa_pdf", to: "claims#claim_loa_pdf"
  end

  resources :clip_claims do
    get "/clip_claim_validation_pdf", to: "clip_claims#clip_claim_validation_pdf"
    get "/clip_claim_loa_pdf", to: "clip_claims#clip_claim_loa_pdf"
  end
  
  resources :hiip_claims do
    get "/hiip_claim_validation_pdf", to: "hiip_claims#hiip_claim_validation_pdf"
    get "/hiip_claim_loa_pdf", to: "hiip_claims#hiip_claim_loa_pdf"
  end

  resources :kalinga_claims do
     get "/kalinga_claim_validation_pdf", to: "kalinga_claims#kalinga_claim_validation_pdf"
     get "/kalinga_claim_loa_pdf", to: "kalinga_claims#kalinga_claim_loa_pdf"
  end

  resources :kbente_claims do
     get "/kbente_claim_validation_pdf", to: "kbente_claims#kbente_claim_validation_pdf"
     get "/kbente_claim_loa_pdf", to: "kbente_claims#kbente_claim_loa_pdf"
  end

  resources :kjsp_claims do
     get "/kjsp_claim_validation_pdf", to: "kjsp_claims#kjsp_claim_validation_pdf"
     get "/kjsp_claim_loa_pdf", to: "kjsp_claims#kjsp_claim_loa_pdf"
     get "/kjsp_contract_highschool_pdf", to: "kjsp_claims#kjsp_contract_highschool_pdf"
     get "/kjsp_contract_college_pdf", to: "kjsp_claims#kjsp_contract_college_pdf"
  end

  resources :calamity_claims do
     get "/calamity_claim_validation_pdf", to: "calamity_claims#calamity_claim_validation_pdf"
     get "/calamity_claim_loa_pdf", to: "calamity_claims#calamity_claim_loa_pdf"
  end

  resources :members, only: [] do
    collection { post :import_members }
    collection { post :import_beneficiaries }
    collection { post :import_legal_dependents }
    resources :member_shares, except: [:index], controller: "members/member_shares" do
      get "/flag_as_printed", to: "members/member_shares#flag_as_printed"
    end

    resources :attachment_files, controller: 'members/attachment_files'
    resources :claims, controller: 'members/claims'
    resources :clip_claims, controller: 'members/clip_claims'
    resources :hiip_claims, controller: 'members/hiip_claims'
    resources :kalinga_claims, controller: 'members/kalinga_claims'
    resources :kbente_claims, controller: 'members/kbente_claims'
    resources :kjsp_claims, controller: 'members/kjsp_claims'
    resources :calamity_claims, controller: 'members/calamity_claims'
  end
  
  # Insurance Accounts
  resources :insurance_accounts do
    get "/claims_copy_pdf", to: "insurance_accounts#claims_copy_pdf"
    collection { post :import_insurance_accounts }
    collection { post :import_insurance_account_transactions }
  end

  # Loans
  resources :loans, only: [:index, :show] do  
    get "/adjustment/:adjustment_record_id", to: "loans#adjustment", as: :adjustment
  end

  resources :member_account_validations do
    get "approve", to: "member_account_validations#approve", as: :approve
    get "reverse", to: "member_account_validations#reverse", as: :reverse

    get "/:member_account_validation_record_id/withdrawal_pdf", to: "member_account_validations#withdrawal_pdf", as: :withdrawal_pdf
    get "/pdf", to: "member_account_validations#pdf", as: :pdf
  end

  get "/loans/form/display", to: "loans#form", as: :loan_application_form

  # Accounts
  get "/savings_accounts", to: "savings_accounts#index"
  get "/savings_accounts/:id", to: "savings_accounts#show", as: :savings_account
  get "/savings_accounts/:id/:data_store_id/time_deposit_withdrawal", to: "savings_accounts#time_deposit_withdrawal", as: :savings_account_time_deposit_withdrawal

  # get "/insurance_accounts", to: "insurance_accounts#index"
  # get "/insurance_accounts/:id", to: "insurance_accounts#show", as: :insurance_account

  get "/equity_accounts", to: "equity_accounts#index"
  get "/equity_accounts/:id", to: "equity_accounts#show", as: :equity_account

  # Membership payment records
  resources :membership_payment_records, only: [:destroy]

  # Accounting
  get "/accounting/trial_balance", to: "accounting#trial_balance"
  get "/accounting/general_ledger", to: "accounting#general_ledger"
  get "/accounting/general_ledger_excel_url", to: "accounting#general_ledger_excel_url"
  get "/accounting/general_ledger_excel", to: "accounting#general_ledger_excel", as: :general_ledger_excel_url
  get "/accounting/books/jvb", to: "accounting#jvb", as: :accounting_books_jvb
  get "/accounting/books/crb", to: "accounting#crb", as: :accounting_books_crb
  get "/accounting/books/cdb", to: "accounting#cdb", as: :accounting_books_cdb
  get "/accounting/books/misc", to: "accounting#misc", as: :accounting_books_misc
  get "/accounting/form", to: "accounting#form", as: :accounting_form
  
  #books
  get "/books/excel", to: "books#excel"
  get "/books/books_download_excel", to: "books#books_download_excel", as: :books_download_excel
  
  namespace :accounting do
    resources :year_end_closings, only: [:index, :show, :destroy]
    resources :balance_sheets, only: [:index, :show, :destroy]
    resources :income_statements, only: [:index, :show, :destroy]
  end
  

  
  # Billing
  get "/billings/excel", to: "billings#excel"
  get "/billings/billing_excel", to: "billings#billing_excel", as: :billing_download_excel
  resources :billings, only: [:index, :show, :destroy]
  
  ################################
  # CASH MANAGEMENT
  ################################

  # Deposits
  resources :deposit_collections, only: [:index, :show, :destroy] do
    collection { post :upload }
  end

  # Time Deposit
  resources :time_deposit_collections, only: [:index, :show, :destroy] do
  end

  # Withdrawals
  resources :withdrawal_collections, only: [:index, :show, :destroy]

  # Insurance Withdrawals
  resources :insurance_withdrawal_collections, only: [:index, :show, :destroy] do
    collection { post :upload }
  end

  # Insurance Fund Transfer
  resources :insurance_fund_transfer_collections, only: [:index, :show, :destroy] do
    collection { post :upload}
  end

  # Memberhsip Payment Collections
  resources :membership_payment_collections, only: [:index, :show, :destroy]

  # Monthly Closing Collections
  resources :monthly_closing_collections, only: [:index, :show, :destroy]

  # Printing
  get "/print", to: "print#print"
  get "/download_file", to: "pages#download_file"

  # Data Stores
  namespace :data_stores do
    get "/icpr", to: "icpr#index"
    get "/icpr/:id", to: "icpr#show"
    delete "/icpr/:id", to: "icpr#destroy"


    get "/patronage_refund", to: "patronage_refund#index"
    get "/patronage_refund/:id", to: "patronage_refund#show"
    delete "/patronage_refund/:id", to: "patronage_refund#destroy"

    get "/personal_funds", to: "personal_funds#index"
    get "/personal_funds/turkey", to: "personal_funds#turkey"
    get "/personal_funds/:id", to: "personal_funds#show"
    delete "/personal_funds/:id", to: "personal_funds#destroy"

    get "/member_counts", to: "member_counts#index"
    get "/member_counts/:id", to: "member_counts#show"
    delete "/member_counts/:id", to: "member_counts#destroy"

    get "/monthly_new_and_resigned", to: "monthly_new_and_resigned#index"
    get "/monthly_new_and_resigned/:id", to: "monthly_new_and_resigned#show"
    delete "/monthly_new_and_resigned/:id", to: "monthly_new_and_resigned#destroy"

    get "/monthly_incentives", to: "monthly_incentives#index"
    get "/monthly_incentives/:id", to: "monthly_incentives#show"
    delete "/monthly_incentives/:id", to: "monthly_incentives#destroy"

    get "/x_weeks_to_pay", to: "x_weeks_to_pay#index"
    get "/x_weeks_to_pay/:id", to: "x_weeks_to_pay#show"
    delete "/x_weeks_to_pay/:id", to: "x_weeks_to_pay#destroy"

    get "/branch_loans_stats", to: "branch_loans_stats#index"
    get "/branch_loans_stats/:id", to: "branch_loans_stats#show"
    delete "/branch_loans_stats/:id", to: "branch_loans_stats#destroy"

    get "/branch_with_centers_loans_stats", to: "branch_with_centers_loans_stats#index"
    get "/branch_with_centers_loans_stats/:id", to: "branch_with_centers_loans_stats#show"
    delete "/branch_with_centers_loans_stats/:id", to: "branch_with_centers_loans_stats#destroy"

    get "/branch_repayment_reports", to: "branch_repayment_reports#index"
    get "/branch_repayment_reports/:id", to: "branch_repayment_reports#show"
    delete "/branch_repayment_reports/:id", to: "branch_repayment_reports#destroy"

    get "/accounting_entries_summaries", to: "accounting_entries_summaries#index"
    get "/accounting_entries_summaries/:id", to: "accounting_entries_summaries#show"
    delete "/accounting_entries_summaries/:id", to: "accounting_entries_summaries#destroy"

    get "/soa_expenses", to: "soa_expenses#index"
    get "/soa_expenses/:id", to: "soa_expenses#show"
    delete "/soa_expenses/:id", to: "soa_expenses#destroy"

    get "/soa_loans", to: "soa_loans#index"
    get "/soa_loans/:id", to: "soa_loans#show"
    delete "/soa_loans/:id", to: "soa_loans#destroy"

    get "/soa_funds", to: "soa_funds#index"
    get "/soa_funds/turkey", to: "soa_funds#turkey"
    get "/soa_funds/:id", to: "soa_funds#show"
    delete "/soa_funds/:id", to: "soa_funds#destroy"

    get "/watchlists", to: "watchlists#index"
    get "/watchlists/:id", to: "watchlists#show"
    delete "/watchlists/:id", to: "watchlists#destroy"

    get "/repayment_rates", to: "repayment_rates#index"
    get "/repayment_rates/:id", to: "repayment_rates#show"
    delete "/repayment_rates/:id", to: "repayment_rates#destroy"

    get "/manual_aging", to: "manual_aging#index"
    get "/manual_aging/:id", to: "manual_aging#show"
    delete "/manual_aging/:id", to: "manual_aging#destroy"

    get "/branch_resignations", to: "branch_resignations#index"
    get "/branch_resignations/:id", to: "branch_resignations#show"
    delete "/branch_resignations/:id", to: "branch_resignations#destroy"
  end

  namespace :accounting do
    get "/accounting_entries", to: "acounting_entries#index", as: :accounting_entries
    get "/accounting_entries/:id", to: "accounting_entries#show", as: :accounting_entry
    delete "/accounting_entries/:id", to: "accounting_entries#destroy", as: :delete_accounting_entry
    get "/accounting_entry/form", to: "accounting_entries#form", as: :accounting_entry_form
    
  end

  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end

  get "/download_backup", to: "pages#download_backup"
  get "/download_exit_age", to: "pages#download_exit_age"
  draw :administration
  draw :accounting
  draw :api

  #reports
  get '/reports/monthly_remittance', to: 'reports#monthly_remittance', as: :monthly_remittance
  get '/reports/download_excel_monthly_remittance', to: 'reports#download_excel_monthly_remittance', as: :download_excel_monthly_remittance
  get '/reports/insured_loans', to: 'reports#insured_loans', as: :insured_loans
  get "/reports/print_insured_loans", to: "reports#print_insured_loans", as: :reports_print_insured_loans
  get '/reports/member_reports', to: 'reports#member_reports', as: :member_reports
  get "/reports/collections_clip_reports", to: "reports#collections_clip_reports", as: :collections_clip_reports
  get "/reports/collections_clip", to: "reports#collections_clip", as: :collections_clip
  get "/reports/collections_blip_reports", to: "reports#collections_blip_reports", as: :collections_blip_reports
  get "/reports/collections_blip", to: "reports#collections_blip", as: :collections_blip
  get "/reports/member_dependent_reports", to: "reports#member_dependent_reports", as: :member_dependent_reports
  get "/reports/member_dependent", to: "reports#member_dependent", as: :member_dependent
  get "/reports/cic_reports", to: "reports#cic_reports", as: :cic_reports
  get "/reports/cic", to: "reports#cic", as: :cic
  get '/insurance_accounts/:id/insurance_account_pdf', to: 'insurance_accounts#insurance_account_pdf', as: :insurance_account_pdf
  get "/reports/monthly_collection", to: "reports#monthly_collection", as: :monthly_collection
  get "/reports/monthly_collection_reports", to: "reports#monthly_collection_reports", as: :monthly_collection_reports
  get "/reports/member_quarterly_reports", to: "reports#member_quarterly_reports", as: :member_quarterly_reports
  get "/exports/members_per_branch_excel", to: "exports#members_per_branch_excel", as: :export_members_per_branch_excel
  get "/reports/summary_of_certificates_and_policies", to: "reports#summary_of_certificates_and_policies", as: :summary_of_certificates_and_policies
  get "/reports/personal_document", to: "reports#personal_document", as: :personal_document
  get "/reports/personal_document_reports", to: "reports#personal_document_reports", as: :personal_document_reports
  get "/reports/claims_blip", to: "reports#claims_blip", as: :claims_blip
  get "/reports/claims_blip_report", to: "reports#claims_blip_report", as: :claims_blip_report
  get "/reports/claims_clip", to: "reports#claims_clip", as: :claims_clip
  get "/reports/claims_clip_report", to: "reports#claims_clip_report", as: :claims_clip_report
  get "/reports/collections_hiip", to: "reports#collections_hiip", as: :collections_hiip
  get "/reports/collections_hiip_reports", to: "reports#collections_hiip_reports", as: :collections_hiip_reports
  
  resources :insurance_accounts do
    get "/claims_copy_pdf", to: "insurance_accounts#claims_copy_pdf"
  end

  # ACTIVITY LOGS
  resources :activity_logs, only: [:index]
end
