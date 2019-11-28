class Admin::ApplicationController < Jets::Controller::Base
	before_action :adminPreCheck

	def adminPreCheck
		@title = "This is Admin panel callback"
	end
end
