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
  	end
  end

  # The jets/public#show controller can serve static utf8 content out of the public folder.
  # Note, as part of the deploy process Jets uploads files in the public folder to s3
  # and serves them out of s3 directly. S3 is well suited to serve static assets.
  # More info here: https://rubyonjets.com/docs/extras/assets-serving/
  any "*catchall", to: "jets/public#show"
end
