class Api::V1::CallHistoriesController < Api::V1::ApplicationController
	before_action :validateSession
	before_action :findCall, except: [:callInitiated, :callHistory]
	def callInitiated
		@receiver = User.where(:_id.in => [params[:receiverId]]).first
		if @receiver
			@call = CallHistory.create(dialerUserId: @user._id, receiverUserId: @receiver._id, callStatus: "initiated", pricePerHour: @receiver.pricePerHour.to_f, totalPrice: 0.0)
			callJson
		else
			render :json =>  {code: 404, message: "Receiver does not exists"}
		end
	end

	def callConnected
		@call.set(callStatus: "connected", connectedAt: Time.current, updated_at: Time.current)
		callJson
	end

	def callPicked
		@call.set(callStatus: "picked", pickedAt: Time.current, updated_at: Time.current)
		callJson
	end

	def callEnded
		@call.set(callStatus: "ended", endedAt: Time.current, updated_at: Time.current)
		callJson
	end

	def callHistory
		history = @user.callHistories.order(updated_at: "DESC").paginate(page: params[:page], per_page: params[:per_page])
		render json: {code: 200, history: history.as_json(except: [:_id, :dialerUserId, :receiverUserId], methods: [:id]) }
	end

	private
	def findCall
		begin
			@call = @user.callHistories.find_by(_id: params[:callId])
		rescue Exception => e
			render :json =>  {code: 404, message: "Call does not exists"}         
		end
	end

	def callJson
		render json: {code: 200, call: @call.as_json(except: [:_id, :dialerUserId, :receiverUserId], methods: [:id])}
	end
end




