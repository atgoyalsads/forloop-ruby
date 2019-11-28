class Api::V1::RegistrationsController < Api::V1::ApplicationController
	def create
		render json: {result: @result, data: params}
	end
end
