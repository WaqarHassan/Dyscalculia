Rails.application.routes.draw do
  devise_for :admins
  devise_for :users, controllers: { registrations: "registrations" }
  get 'login/index'

  match "/403", to: "errors#error_403", via: :all
  match "/404", to: "errors#error_404", via: :all
  match "/422", to: "errors#error_422", via: :all
  match "/500", to: "errors#error_500", via: :all

  get :ie_warning, to: 'errors#ie_warning'
  get :javascript_warning, to: 'errors#javascript_warning'

  root to: "user_overview#index"

  scope '/users' do
    get '/account_details', to: 'user_overview#show_details', as: 'account_details'
  end

  scope '/tests' do
    get '/', to: 'user_overview#index', as: 'tests'
    get '/enrol', to:'tests#enrol', as: 'enrol'
    post '/enrol', to:'tests#process_enrol'

    scope '/:test_code' do
      get '/', to: 'tests#show', as: 'test'
      get '/start', to: 'tests#start', as: 'start_test'
      get '/completed', to: 'tests#completed', as: 'completed_test'
      scope '/:question_no' do
        get '/', to: 'question#show', as: 'question'
        post '/', to: 'question#submit_response', as: 'submit_response'
        put '/submit_time', to: 'question#submit_time'
        put '/extend_time', to: 'question#extend_time'
      end
    end
  end

  # All admin routes
  # post 'tests', to: 'tests#create', as: 'create_test'
  delete 'tests/:test_code', to: 'tests#destroy', as: 'delete_test'
  patch 'tests/:test_id', to: 'tests#update', as: 'edit_test_form'

  scope '/admin' do
    get '/', to: 'test_results#index', as: 'admin_overview'
    get '/account_details', to: 'user_overview#show_details_admin', as: 'admin_user_details'
    get '/edit_details', to: 'tests#edit_details_admin', as: 'edit_admin_details'
    get '/users/account_details/:user_id', to: 'tests#show_details', as: 'user_details'

    scope '/users' do
      get '/', to: 'user#index', as: 'search_users'
      get '/search', to: 'user#search', as: 'search_users_results'
      get '/search/:test_id', to: 'user#search', as: 'search_users_test_results'
    end

    # Routes for admin tests
    scope '/tests' do
      get '/', to: 'test_results#index', as: 'test_results'
      get '/new', to: 'tests#new', as: 'new_test'
      post '/new', to: 'tests#create', as: 'create_test'

      # Routes for a specific test
      scope '/:test_code' do
        get '/preview', to: 'tests#preview', as: 'preview_test'
        get '/edit', to: 'tests#edit', as: 'edit_test'
        get '/new', to: 'question#new', as: 'new_question'
        put '/', to: 'tests#update', as: 'put_update_test'
        post '/duplicate', to: 'tests#duplicate', as: "duplicate_test"
        post '/make_live', to: 'tests#make_live', as: 'make_test_live'
        post '/new', to: 'question#create', as: 'create_question'
        patch '/edit', to: 'tests#update', as: 'update_test'

        scope '/results' do
          # get '/', to: 'test_results#show', as: 'test_result'
          get '/users', to: 'test_results#show_per_user', as: 'show_per_user'
          get '/questions', to: 'test_results#show_per_question', as: 'show_per_question'
          get '/:user_id', to: 'test_results#show', as: 'user_result'
          get '/questions/:question_id', to: 'test_results#question_breakdown', as: 'question_breakdown'
          get '/questions/:question_id/preview', to: 'question#preview', as: 'question_preview'
          post '/questions/:question_id/:user_answer_id', to: 'test_results#toggle_question', as: 'answer_update_question'
          post '/:user_id/:user_answer_id', to: 'test_results#toggle_user', as: 'answer_update_user'


          # scope '/questions' do
          #   get '/', to: 'test_results#show_per_question', as: 'show_per_question'
          #   get '/:question_id', to: 'test_results#question_breakdown', as: 'question_breakdown'
          # end
        end


        # Routes for a specific question on a test
        scope '/:question_no' do
          post '/edit', to: 'question#update'
          get '/edit', to: 'question#edit', as: 'edit_question'
          delete '/', to: 'question#destroy', as: 'delete_question'
        end
      end
    end
  end

  # Test routes have to be specified manually because navigating to them directly using
  # id is not as friendly as test_code and question_no

  get "#{Rails.root}/uploads/:question_id/picture/:name", to: 'question#show_picture'
  get "#{Rails.root}/uploads/:question_id/reading/:name", to: 'question#show_reading'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
