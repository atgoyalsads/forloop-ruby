class Api::V1::RegistrationsController < Api::V1::ApplicationController
	def create
		begin
			user = User.new(signup_params)
			if user.save
				session = user.sessions.create(deviceId: params[:deviceId], deviceType: params[:deviceType])
				render json: {code: 200, message: "Signup successful", user: user.as_json(except:[:created_at,:updated_at,:password_hash,:password_salt,:_id]).merge(sessionToken: session.sessionToken)}
			else
				render json: {code: 401, message: user.errors.full_messages.join(", ")}
			end
		rescue Exception => e
			render json: {code: 402, message: e}
		end	
	end

	private
	def signup_params
		params.require(:user).permit(:email,:password)	
	end
end
