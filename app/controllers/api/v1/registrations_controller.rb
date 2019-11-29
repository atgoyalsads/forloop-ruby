class Api::V1::RegistrationsController < Api::V1::ApplicationController
	def create
		begin
			user = User.new(params_permit)
			if user.save
				render json: {code: 200, message: "Signup successful", data: user}
			else
				render json: {code: 401, message: user.errors.full_messages.join(", ")}
			end
		rescue Exception => e
			render json: {code: 402, message: e}
		end	
	end

	def login
		user = User.authenticate(params[:email], params[:password])
	  if user
	    render json: {code: 200, message: "Login successful", data: user}
	  else
	  	render json: {code: 401, message: "Invalid email or password"}
	  end
	end

	private
	def params_permit
		params.require(:user).permit(:fname, :lname, :email,:password)	
	end
end
