OpenActiveDemocracy::Application.routes.draw do
  resources :partners do
    member do
      get :email
      post :picture_save
      get :picture
    end
  end

  resources :users do
    resources :messages
    resources :followings do
      collection do
        put :multiple
      end
    end

    resources :contacts do
      collection do
        get :not_invited
        get :invited
        get :members
        get :following
        put :multiple
      end
    end
  end

  resources :settings do
    collection do
      get :legislators
      get :signups
      get :branch_change
      post :legislators_save
      get :delete
      post :picture_save
      get :picture
    end
  end

  resources :priorities do
    resources :changes do
      resources :votes
    end
    resources :points
    resources :documents
    resources :ads do
      collection do
        post :preview
      end
      member do
        post :skip
      end
    end
  end

  resources :activities do
    resources :followings
    resources :comments do
      collection do
        get :more
      end
      member do
        post :abusive
        get :unhide
        post :not_abusive
        get :flag
      end
    end
  end

  resources :points do
    resources :revisions do
      member do
        get :clean
      end
    end
  end

  resources :documents do
    resources :revisions do
      member do
        get :clean
      end
    end
  end

  resources :legislators do
    resources :constituents do
      collection do
        get :priorities
      end
    end
  end

  resources :blurbs do
    collection do
      put :preview
    end
  end

  resources :email_templates do
    collection do
      put :preview
    end
  end

  resources :color_schemes do
    collection do
      put :preview
    end

  end

  resources :governments do
    member do
      get :apis
    end
  end

  resources :widgets do
    collection do
      get :points
      get :preview_iframe
      get :discussions
      post :preview
      get :priorities
    end
  end

  resources :bulletins do
    member do
      post :add_inline
    end
  end

  resources :branches do
    resources :priorities do
      collection do
        get :rising
        get :top
        get :falling
        get :controversial
        get :random
        get :newest
        get :finished
      end
    end

    resources :users do
      collection do
        get :talkative
        get :twitterers
        get :ambassadors
        get :newest
      end
    end
  end

  resources :searches do
    collection do
      get :points
      get :documents
    end
  end

  resources :signups
  resources :endorsements
  resources :passwords
  resources :unsubscribes
  resources :notifications
  resources :pages
  resources :about
  resources :tags
  resource :session
  resources :delayed_jobs do
    member do
      get :top
      get :clear
    end
  end

  resources :priority_processes
  resources :process_speech_master_videos
  resources :process_speech_videos
  resources :process_discussions
  resources :process_documents
  resources :process_types
  resources :process_document_elements
  resources :process_documents
  resources :process_document_types
  resources :process_document_states
  
  match '/' => 'priorities#index'
  match '/activate/:activation_code' => 'users#activate', :as => :activate, :activation_code => nil
  match '/signup' => 'users#new', :as => :signup
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/unsubscribe' => 'unsubscribes#new', :as => :unsubscribe
  match '/yours' => 'priorities#yours'
  match '/hot' => 'priorities#hot'
  match '/cold' => 'priorities#cold'
  match '/new' => 'priorities#new'
  match '/controversial' => 'priorities#controversial'
  match '/vote/:action/:code' => 'vote#index'
  match '/splash' => 'splash#index'
  match '/issues' => 'issues#index'
  match '/issues.:format' => 'issues#index'
  match '/issues/:slug' => 'issues#show'
  match '/issues/:slug.:format' => 'issues#show'
  match '/issues/:slug/:action' => 'issues#index'
  match '/issues/:slug/:action.:format' => 'issues#index'
  match '/portal' => 'portal#index'
  match '/pictures/:short_name/:action/:id' => 'pictures#index'
  match ':controller' => '#index'
  match ':controller/:action' => '#index'
  match ':controller/:action.:format' => '#index'
  match '/:controller(/:action(/:id))'
end
