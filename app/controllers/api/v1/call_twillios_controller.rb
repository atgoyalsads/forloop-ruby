class Api::V1::CallTwilliosController < Api::V1::ApplicationController
	require 'twilio-ruby'
	
	def accessToken
		begin
			# Create Voice grant for our token
			identity =  params[:identity].present? ?  params[:identity] : "alice"
			grant = Twilio::JWT::AccessToken::VoiceGrant.new
			grant.outgoing_application_sid = @@outgoing_application_sid
			grant.push_credential_sid = @@push_credential_sid
			# Optional: add to allow incoming calls
			grant.incoming_allow = true

			token = Twilio::JWT::AccessToken.new(
			  @@account_sid,
			  @@api_key,
			  @@secret_key,
			  [grant],
			  identity: identity
			)

			# Generate the token
			render plain: token.to_jwt
		rescue Exception => e
			render plain: ""
		end
	end
end

