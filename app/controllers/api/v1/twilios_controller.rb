class Api::V1::TwiliosController < Api::V1::ApplicationController
	@@account_sid = "ACe561da15ef8d3bc3329f8aceeff96ab9" # Your Test Account SID from www.twilio.com/console/settings
	@@auth_token = "a5b699bc42e207c0c39a73b6b5502ce8"   # Your Test Auth Token from www.twilio.com/console/settings

	# @@account_sid = "ACa101d200c74506c238f2f7bd016d9132" # Live
	# @@auth_token = "00b94f6add60f8e0e17b055142021e9c"	# Live
																											# https://www.twilio.com/console/voice/project/test-credentials
	
	@@api_key = "SKe712dbf5b8c48131c88a64bbb3c59c0c"
	@@secret_key = "1RwGI02T72CabDcjMTEZ7USi0sVh0ssP"  # API Secret key, generated and shown only once when we create the project on twilio, we need to save this in safe place
	@@outgoing_application_sid = "AP85e7c9f435eae913ebb5f6b9f89814fd"
	@@identity = 'user'

	before_action :clientPrepare

	def accessToken
		begin
			# Create Voice grant for our token
			grant = Twilio::JWT::AccessToken::VoiceGrant.new
			grant.outgoing_application_sid = @@outgoing_application_sid

			# Optional: add to allow incoming calls
			grant.incoming_allow = true

			token = Twilio::JWT::AccessToken.new(
			  @@account_sid,
			  @@api_key,
			  @@secret_key,
			  [grant],
			  identity: @@identity
			)

			# Generate the token
			puts token.to_jwt

			render json: {code: 200, token: token.to_jwt}
		rescue Exception => e
			render json: {code: 400, message: e}
		end
	end

	def sendMessage
		begin
			message = @client.messages.create(
		    body: "Hello from Ruby",
		    to: params[:contactNumber],    # Replace with your phone number
		    from: "+15005550006" # Test    # Use this Magic Number for creating SMS
		    # from: "+19175405556" #Live
		    )  
			render json: {code: 200, result: {account_sid: message.account_sid, sid: message.sid, to: message.to, from: message.from}}
		rescue Exception => e
			render json: {code: 400, message: e}
		end
	end

	def makeCall
		begin
			callObj = @client.calls.create(
		    to: params[:contactNumber],
		    from: "+15005550006", #Test
		    # from: "+19175405556", #Live
		    url: "http://demo.twilio.com/docs/voice.xml")
			render json: {code: 200, result: {account_sid: callObj.account_sid, sid: callObj.sid, to: callObj.to, from: callObj.from}}
		rescue Exception => e
			render json: {code: 400, message: e}
		end
	end

	private
	def clientPrepare
		@client = Twilio::REST::Client.new @@account_sid, @@auth_token
	end
end
