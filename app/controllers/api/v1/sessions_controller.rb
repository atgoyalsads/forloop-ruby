class Api::V1::SessionsController < Api::V1::ApplicationController
	# def create
	# 	user = User.authenticate(params[:email], params[:password])
	#   if user
	#   	session = Session.create(user_id: user, deviceId: params[:deviceId], deviceType: params[:deviceType])
	#     render json: {code: 200, message: "Login successful", user: user.as_json(except:[:created_at,:updated_at,:password_hash,:password_salt,:_id]).merge({sessionToken: session.sessionToken})}
	#   else
	#   	render json: {code: 401, message: "Invalid email or password"}
	#   end
	# end

	def registerToken
		user = User.find_by(email: params[:email])
	  if user and params[:sessionToken].present?
	  	user.set({"deactivated": false}) if user.deactivated
	  	begin
	  		session = Session.find_by(sessionToken: params[:sessionToken])
	  		# find_by will cause exception in case of record not found 
		  	render json: {code: 402, message: "Another session is already exists with this token"}
	  	rescue Exception => e
	  		session = Session.create(user_id: user, sessionToken: params[:sessionToken], deviceId: params[:deviceId], deviceType: params[:deviceType])
	    	render json: {code: 200, message: "Login successful", user: user.as_json(except:[:created_at,:updated_at,:password_hash,:password_salt,:_id]).merge({sessionToken: session.sessionToken})}
	  	end
	  else
	  	render json: {code: 401, message: user ? "session token missing" : "Invalid email or password"}
	  end
	end

	def logout
		begin
			@session.destroy
			render :json =>  {code: 200, message: "Signout successful"}         
		rescue Exception => e
			render :json =>  {code: 420, message: "Invalid Session Token"}         
		end
	end

	def seedData
		# cats = ["Server","Programming","Mobile Apps","Web Apps","Javascript"]
		# subcats = [ ["aws","atlassian.net","digital Ocian","heroku"],
		# 			["C++","Java", "Ruby", "Python", "NodeJs", "Objective C", "Swift", "React Native"],
		# 			["iOS- Swift", "iOS- Objective C" "Android", "React Native"],
		# 			["HTML", "Boostrap", "PHP", "AngularJs", "ReactJs", "Wordpress"],
		# 			["NodeJs","AngularJs","ReactJs","JQuery", "Ajax"]
		# 		]
		# cats.each_with_index do |c, index|
		# 	cat = Category.create(title: c)
		# 	subcats[index].each do |s|
		# 		cat.subcategories.create(title: s)
		# 	end
		# end
		render json: {code: 200, message: "done"}
	end
end
