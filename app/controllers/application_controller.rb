class ApplicationController < Jets::Controller::Base
	before_action :websitePreCheck

	def websitePreCheck
		@title =  "This is Website callback"
	end
end
