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
      get "check/contact", to: "profiles#checkContact"
      post "update/contact", to: "profiles#updateContact"
      post "update/role", to: "profiles#update_role"
      post "update/pic", to: "profiles#upload_pic"
      post "update/profile", to: "profiles#update_profile"
      post "update/links", to: "profiles#update_links"
      post "update/details", to: "profiles#update_details"
      post "update/subcategories", to: "profiles#update_subcategories"
      post "subcategories", to: "profiles#subcategories_list"
      post "pro/details", to: "profiles#proDetails"
      post "pro/ratings", to: "profiles#proRatings"

      # Dashboard Routes
      post "dashboard/seeker", to: "dashboards#seeker"
      post "dashboard/seeker/categories", to: "dashboards#dashboardCategories"
      post "dashboard/seeker/subcategories", to: "dashboards#dashboardSubCategories"
      post "dashboard/seeker/top", to: "dashboards#dashboardTop"
      post "dashboard/pro", to: "dashboards#proDashboard"
      post "dashboard/subcategory/pros", to: "dashboards#subcategoryUsers"
      post "search/pros", to: "dashboards#searchProUsers"

      # Call Twillio routes
      post "seeker/place/call", to: "twilios#placeCall"
      post "seeker/calling", to: "twilios#makeCall"
      post "twilio/call/response", to: "twilios#callResponseFromTwillio"

      # Server Twillio Routes
      get "/accessToken", to: "call_twillios#accessToken"
      
      # Call APIs
      post "call/history", to: "call_histories#callHistory"
      post "call/details", to: "call_histories#callDetails"
      post "call/rating", to: "call_histories#rateCall"

      # Favourites
      post "favourites/add", to: "favourites#create"
      post "favourites/list", to: "favourites#list"

      # Cards
      post "seeker/cards", to: "stripes#cardsList"
      post "seeker/add/card", to: "stripes#addCard"

  	end
  end

  # The jets/public#show controller can serve static utf8 content out of the public folder.
  # Note, as part of the deploy process Jets uploads files in the public folder to s3
  # and serves them out of s3 directly. S3 is well suited to serve static assets.
  # More info here: https://rubyonjets.com/docs/extras/assets-serving/
  any "*catchall", to: "jets/public#show"
end
