class Api::V1::ApplicationController < Jets::Controller::Base
	skip_before_action :verify_authenticity_token 
	require 'will_paginate/array'
	
	def validateSession
		begin
			session = Session.find_by(sessionToken: request.headers["sessiontoken"])
			@user = session.user
		rescue Exception => e
			render :json =>  {code: 420, message: "Invalid Session Token"}         
		end
	end
end
