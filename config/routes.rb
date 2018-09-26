Rails.application.routes.draw do
  devise_for :users, skip: [:sessions]

  as :user do
    get 'login', to: 'pages#login', as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: "pages#index"

  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end

  get "/download_backup", to: "pages#download_backup"

  draw :administration
  draw :api
end
