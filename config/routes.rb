Rails3BootstrapDeviseCancan::Application.routes.draw do

  devise_for :admin_users

  authenticated :user do
    root :to => 'users#index'
  end
  root :to => "users#index"
  devise_for :users
  resources :users

  match 'webhooks', :to=> 'webhooks#index', :via=> [:get, :post]


  #resources :webhooks, :only => [:index] do
  #  collection do
  #    post :abc
  #  end
  #end
  resources :mandrill_settings

  resources :smtp_settings
  resources :key_mandrills
  resources :manages do
    collection do
      post :search_subscriber
      get :unsubscribe
    end
  end
  resources :upload_csvs do
    collection do
      get :send_email
    end
    collection do
      post :upload_all_pdf
      post :create_all_pdf
    end
  end

  resources :csvs, :only=> [:new, :create, :show]do
    collection do
      post :import
    end
    member do
      get :approved
    end
  end

  resources :apisettings do
    collection do
      get :load_list
      get :load_template
    end
  end

  resources :upload_csvs do
    resources :csvs do
    end
  end

  resources :users do
    collection do
      post :create_user
    end
  end

end