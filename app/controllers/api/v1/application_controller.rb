class Api::V1::ApplicationController < Jets::Controller::Base
	skip_before_action :verify_authenticity_token 
	require 'will_paginate/array'
	
	# @@account_sid = "ACe561da15ef8d3bc3329f8aceeff96ab9" # Your Test Account SID from www.twilio.com/console/settings
	# @@auth_token = "a5b699bc42e207c0c39a73b6b5502ce8"   # Your Test Auth Token from www.twilio.com/console/settings

	@@account_sid = "ACa101d200c74506c238f2f7bd016d9132" # Live
	@@auth_token = "00b94f6add60f8e0e17b055142021e9c"	# Live
																											# https://www.twilio.com/console/voice/project/test-credentials
	
	@@api_key = "SKe712dbf5b8c48131c88a64bbb3c59c0c"
	@@secret_key = "1RwGI02T72CabDcjMTEZ7USi0sVh0ssP"  # API Secret key, generated and shown only once when we create the project on twilio, we need to save this in safe place
	@@outgoing_application_sid = "AP85e7c9f435eae913ebb5f6b9f89814fd"
	@@push_credential_sid = "CR802929f7c6148fa47918dfd1f528cb2a"
	@@identity = 'alice'

	require "stripe"
	Stripe.api_key = "sk_test_MbmGpFYPoJf7QhzOFD3RNuUb"
	# loveyhtu21@gmail.com
	# sk_test_MbmGpFYPoJf7QhzOFD3RNuUb
	# pk_test_HD3Xrf74LFY1PUl8J3SeQ1Ej

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
			subcategories: user.subcategory_users.size>0
		}
	end
end
