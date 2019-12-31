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

	def proScreensStatus user
		{
			displayName: (user.displayName.present? or user.image.present?) ,
			details: (user.fname.present? and user.lname.present? and user.countryCode.present? and user.contact.present? and user.zipcode.present? and user.dob.present? and user.gender.present?) ,
			links: (user.linkBlogger.present? or user.linkLinkedin.present? or user.linkInstagram.present? or user.linkPinterest.present?) , 
			subcategories: user.subcategory_users.count>0
		}
	end
end
