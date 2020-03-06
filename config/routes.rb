Jets.application.routes.draw do
  root 'welcomes#index'
  # root "jets/public#show"

  namespace :admin do
  	get  "login", to: "sessions#new"
  	# post "login", to: "sessions#create"
  	get "logout", to: "sessions#destroy"
  end

  namespace :api do 
  	namespace :v1 do
      #Auth Routes
  		post "signup", to: "registrations#create"
      # post "login", to: "sessions#create"
      post "register/token", to: "sessions#registerToken"
      get "logout", to: "sessions#logout"

      # Profile Data routes
      get "session/details", to: "profiles#show"
      post "update/role", to: "profiles#update_role"
      post "update/pic", to: "profiles#upload_pic"
      post "update/profile", to: "profiles#update_profile"
      post "update/links", to: "profiles#update_links"
      post "update/details", to: "profiles#update_details"
      post "update/subcategories", to: "profiles#update_subcategories"
      post "subcategories", to: "profiles#subcategories_list"

      # Dashboard Routes
      post "dashboard/seeker", to: "dashboards#seeker"
      post "dashboard/subcategory/pros", to: "dashboards#subcategoryUsers"
      post "search/pros", to: "dashboards#searchProUsers"

      # Call Twillio routes
      post "twilio/access/token", to: "twilios#accessToken"
      get "twilio/access/token", to: "twilios#accessToken"
      post "twilio/capability/token", to: "twilios#capabilityToken"
      post "seeker/place/call", to: "twilios#placeCall"
      post "seeker/calling", to: "twilios#makeCall"
      
      # Call APIs
      post "call/initiated", to: "call_histories#callInitiated"
      post "call/connected", to: "call_histories#callConnected"
      post "call/picked", to: "call_histories#callPicked"
      post "call/ended", to: "call_histories#callEnded"
      post "call/history", to: "call_histories#callHistory"

      # Favourites
      post "favourites/add", to: "favourites#create"
      post "favourites/list", to: "favourites#list"

  	end
  end

  # The jets/public#show controller can serve static utf8 content out of the public folder.
  # Note, as part of the deploy process Jets uploads files in the public folder to s3
  # and serves them out of s3 directly. S3 is well suited to serve static assets.
  # More info here: https://rubyonjets.com/docs/extras/assets-serving/
  any "*catchall", to: "jets/public#show"
end
