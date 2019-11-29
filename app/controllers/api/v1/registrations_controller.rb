class Api::V1::RegistrationsController < Api::V1::ApplicationController
	def create
		user = User.new(fname: params[:fname], lname: params[:lname], email: params[:email])
		if user.save
			render json: {code: 200, message: "Signup successful", data: user}
		else
			render json: {code: 401, message: user.errors.full_messages.join(", ")}
		end
	end
end
