class Api::V1::RegistrationsController < Api::V1::ApplicationController
	def create
		user = User.create(fname: params[:fname], lname: params[:lname], email: params[:email])
		render json: {result: @result, data: user}
	end
end
