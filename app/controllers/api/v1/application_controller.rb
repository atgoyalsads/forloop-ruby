class Api::V1::ApplicationController < Jets::Controller::Base
	skip_before_action :verify_authenticity_token 
	before_action :apiV1PreCheck

	def apiV1PreCheck
		@result = "This is API callback"
	end
end
