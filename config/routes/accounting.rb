namespace :accounting do
  resources :accounting_codes
  get "/print_chart_of_accounts", to: "accounting_codes#print"
end
