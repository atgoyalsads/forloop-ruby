class Api::V1::TwiliosController < Api::V1::ApplicationController
	before_action :validateSession, only: [:placeCall]
	before_action :clientPrepare, except: [:makeCall, :twiml, :callResponseFromTwillio]
	require 'twilio-ruby'

	def placeCall
		begin
			deployedURL = "https://ekye3h3x7g.execute-api.us-west-2.amazonaws.com/dev"
			receiver = User.find_by(_id: params[:proId])
			callObj = @client.calls.create(
		    to: "#{receiver.countryCode}#{receiver.contact}",
		    # from: "+15005550006", #Test
		    from: "+19175405556", #Live
		    url: "#{deployedURL}/api/v1/seeker/twiml?contact=#{receiver.countryCode}#{receiver.contact}",
		    status_callback: "#{deployedURL}/api/v1/twilio/call/response",
       	status_callback_event: ['initiated','ringing', 'answered', 'completed'],
       	status_callback_method: 'POST',
		    )
		    call = CallHistory.create(dialerUserId: @user._id, receiverUserId: receiver._id, pricePerHour: receiver.pricePerHour.to_f, totalPrice: 0.0, callCategory: params[:callCategory], callId: callObj.sid)
				render json: {code: 200, callObjId: callObj.sid, call: call.as_json({except: [:_id, :dialerUserId, :receiverUserId], methods: [:id] }) }
		rescue Exception => e
			render json: {code: 404, message: e}
			# render plain: e
		end
	end

	def twiml
		response = "<Response> <Dial callerId=\"+19175405556\"> <Number> +#{params[:contact].to_s.gsub("+","")} </Number> </Dial> </Response>"
		# response = Twilio::TwiML::VoiceResponse.new
		# response.dial(number: "+917834821711")
		render xml: response.to_s
	end

	def makeCall
		# response = Twilio::TwiML::VoiceResponse.new
		# response.say(message: 'Hello. Hope you are doing good! by the way thanks for being there to help me, I have couple of questions to discuss with you over this call. Nice to talk to you. I would also rate you after this call.')
		response = "<Response> </Response>"
		
		render xml: response.to_s
	end

	def callResponseFromTwillio
		begin
			call = CallHistory.find_by(callId: params[:CallSid])
			case params[:CallStatus]
			when "initiated"
				call.set(callStatus: "initiated", updated_at: Time.current)
			when "ringing"
				call.set(callStatus: "connected", connectedAt: Time.current, updated_at: Time.current)
			when "in-progress"
				call.set(callStatus: "in-progress", pickedAt: Time.current, updated_at: Time.current)
			when "completed"
				endAt = Time.current
				durationMinutes = call.pickedAt.present? ? ((endAt-call.pickedAt)/60).round(1) : 0
				totalPrice = durationMinutes*(call.pricePerHour/60)
				
				call.set(callStatus: "completed", completedAt: endAt, updated_at: Time.current, totalPrice: totalPrice, durationMinutes: durationMinutes)
			else
				call.set(callStatus: params[:CallStatus], updated_at: Time.current)
			end
			render json: {code: 200}	
		rescue Exception => e
			render json: {code: 404, message: "Call not found"}	
		end
		
	end

	private
	def clientPrepare
		@client = Twilio::REST::Client.new @@account_sid, @@auth_token
	end
end
