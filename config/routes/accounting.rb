namespace :accounting do
  resources :accounting_codes
  get "/print_chart_of_accounts", to: "accounting_codes#print"
  get "/accounting_codes/download/json", to: "accounting_codes#download", as: :download_accounting_codes
end
