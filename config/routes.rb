Jets.application.routes.draw do
  root 'welcomes#index'
  # root "jets/public#show"

  namespace :admin do
  	get  "login", to: "sessions#new"
  	post "login", to: "sessions#create"
  	get "logout", to: "sessions#destroy"
  end

  namespace :api do 
  	namespace :v1 do
  		post "signup", to: "registrations#create"
      post "login", to: "sessions#create"

      post "seed/data/insert", to: "sessions#seedData"
      # Profile Data routes
      get "session/details", to: "profiles#show"
      post "update/pic", to: "profiles#upload_pic"
      post "update/profile", to: "profiles#update_profile"
      post "update/links", to: "profiles#update_links"
      post "update/details", to: "profiles#update_details"
      post "update/subcategories", to: "profiles#update_subcategories"
      post "categories", to: "profiles#categories"
      post "subcategories", to: "profiles#subcategories_list"
  	end
  end

  # The jets/public#show controller can serve static utf8 content out of the public folder.
  # Note, as part of the deploy process Jets uploads files in the public folder to s3
  # and serves them out of s3 directly. S3 is well suited to serve static assets.
  # More info here: https://rubyonjets.com/docs/extras/assets-serving/
  any "*catchall", to: "jets/public#show"
end
