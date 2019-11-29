class Api::V1::SessionsController < Api::V1::ApplicationController
	def create
		user = User.authenticate(params[:email], params[:password])
	  if user
	  	session = user.sessions.create(deviceId: params[:deviceId], deviceType: params[:deviceType])
	    render json: {code: 200, message: "Login successful", user: user.as_json(except:[:created_at,:updated_at,:password_hash,:password_salt,:_id]).merge(sessionToken: session.sessionToken)}
	  else
	  	render json: {code: 401, message: "Invalid email or password"}
	  end
	end

	def seedData
		cats = ["Server","Programming","Mobile Apps","Web Apps","Javascript"]
		subcats = [ ["aws","atlassian.net","digital Ocian","heroku"],
					["C++","Java", "Ruby", "Python", "NodeJs", "Objective C", "Swift", "React Native"],
					["iOS- Swift", "iOS- Objective C" "Android", "React Native"],
					["HTML", "Boostrap", "PHP", "AngularJs", "ReactJs", "Wordpress"],
					["NodeJs","AngularJs","ReactJs","JQuery", "Ajax"]
				]
		cats.each_with_index do |c, index|
			cat = Category.create(title: c)
			subcats[index].each do |s|
				cat.subcategories.create(title: s)
			end
		end
		render json: {code: 200, message: "done"}
	end
end
