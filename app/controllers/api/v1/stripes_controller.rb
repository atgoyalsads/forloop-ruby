class Api::V1::StripesController < Api::V1::ApplicationController
	before_action :validateSession

	def cardsList
		# begin
			customer = Stripe::Customer.retrieve(@user.stripeCustomerId)
			cards = customer.sources
		# rescue => e
		# 	cards = []
		# end
		render :json =>  {code: 200, cards: cards}
	end

	def addCard
		begin
			if @user.stripeCustomerId.present?
				customer = Stripe::Customer.retrieve(@user.stripeCustomerId)
				card = customer.sources.create({:source => params[:stripeToken]})
				customer.default_source = card.id
				customer.save
			else
				customer = createStripeCustomer(params[:stripeToken])
			end
			@user.set(stripeCustomerId: customer.id)
			savedCard = customer.sources.data[0]
			render :json =>  {code: 200, card: savedCard}
		rescue => e
			render :json =>  {code: 501, message: e}
		end
	end

	private
	def createStripeCustomer stripeToken
		newCustomer = Stripe::Customer.create(
      :description => "#{@user.countryCode} #{@user.contact} - forloop",
      :email=> @user.email,
      :source => stripeToken # obtained with Stripe.js
    )
    newCustomer
	end
end



# module SynergiiStripe
	
# 	Stripe.api_key = ENV['SYNERGII_STRIPE_TEST_SECRET_KEY']

# 	# APIs in which this method is using "Add Card" and in this module methods "add_card_to_customer"
# 	def createStripeCustomer email,stripeToken
# 		newCustomer = Stripe::Customer.create(
#       :description => "#{email} is going to subscription a plan Synergii , request domain #{root_url}",
#       :email=> email,
#       :source => stripeToken # obtained with Stripe.js
#     )
#     return newCustomer
# 	end

# 	def chargeCustomer description,token,amount
# 		begin
# 			chargeAmount = (amount.to_f*100).to_i
# 			charge = Stripe::Charge.create({
# 			    amount: chargeAmount,
# 			    currency: 'usd',
# 			    description: description,
# 			    customer: token,
# 			})
# 			{:code=>200, charge: charge}
# 		rescue => e
# 			p "xxxxxxxx #{e}"
# 			{:code=> 400, errors: e}
# 		end
# 	end
# 	# APIs in which this method is using "add_card_to_default" and  in same module methods like: 	add_card_on_stripe, add_stripe_card, list_customer_cards
# 	def retrieveCustomer stripeCustomerId
# 		Stripe::Customer.retrieve(stripeCustomerId)
# 	end

#   # APIs in which this method is using "add_card"
# 	def add_card_on_stripe user,stripeToken
# 		stripeCustomerId = user.stripe_customer_id.present? ? user.stripe_customer_id : createTipntapStripeCustomer(user,stripeToken)
# 		customer = retrieveCustomer(stripeCustomerId)
# 		# newCard = customer.sources.create({:source => stripeToken})
# 		# card = Card.save_card(user,newCard,false)
# 		# make_card_as_default(user,customer,card)
# 		card = checkDuplicateCard(stripeToken,customer,user)
# 		return card
# 	end

# 	# APIs in which this method is using "make_payment"
# 	def add_card_to_customer user,stripeToken
# 		is_saved = true
# 		logger.info "---- saving source to customer (Adding card)"
# 		begin
# 			customer_uid = user.stripe_customer_id
# 			if customer_uid.present? 
# 				logger.info "... stripe customer id found---"
# 			  logger.info "...Now saving card---"
# 			  customer = retrieveCustomer(customer_uid)
# 			  checkDuplicateCard(stripeToken,customer,user)
# 			  customer_uid = user.stripe_customer_id
# 			else
# 				logger.info "--- stripe-customer id not found, going to add new customer id-----"
# 				customer_uid = createTipntapStripeCustomer(user,stripeToken)
# 			end
# 		rescue => e
# 			{:code=> 400, errors: e}
# 		end
# 	end
  
#   # Not using any API but using in same module methods like: add_card_on_stripe, add_card_to_customer
#   def checkDuplicateCard source, customer, user
#   	#Retrieve the card fingerprint using the stripe_card_token  
#   	begin
# 	    newcard = Stripe::Token.retrieve(source)
# 	    card_fingerprint = newcard.try(:card).try(:fingerprint) 
# 	    card_exp_month = newcard.try(:card).try(:exp_month) 
# 	    card_exp_year = newcard.try(:card).try(:exp_year) 
# 	    card_stripe_id = newcard.try(:card).try(:id)
# 	    card_last4 = newcard.try(:card).try(:last4)
# 	    card_brand = newcard.try(:card).try(:brand)
# 	    card_funding = newcard.try(:card).try(:funding)
# 	    # check whether a card with that fingerprint already exists
# 	    p "======= Card retrieved now checking for dublicate...."
# 	    mainCard = customer.sources.all(:object => "card").data.select{|card| ((card.fingerprint==card_fingerprint)and(card.exp_month==card_exp_month)and(card.exp_year==card_exp_year))}.last 
# 	    p "====================#{mainCard}"
# 	    if !mainCard
# 	      p "=====Card is new going to add new card"
# 	      mainCard = customer.sources.create(source: source)
# 	    else
# 	      p "==== Card is already in the customer list "
# 	    end

# 	    p "====================#{mainCard}"
# 	    # card = Card.save_card(user,mainCard,false)
# 	    # p "======hgdhfdhgsfdgdsdgdhsagd==============#{card}"
# 	    make_card_as_default(user,customer,mainCard)

# 	    #set the default card of the customer to be this card, as this is the last card provided by User and probably he want this card to be used for further transactions
# 	    customer.default_card = mainCard.id 
# 	    p "===This Card has been set to default for this customer"
# 	    # save the customer
# 	    customer.save 
# 	  	logger.info "*** stripe card added to customer"
# 	  	user.update(stripe_customer_id: customer.id)
# 	  	return mainCard
# 	  rescue => e
# 			{:code=> 400, errors: e}
# 		end 	
#   end

#   # APIs in which this method is using cards_list, add_card
# 	def list_customer_cards user,counts
# 		stripeCustomer = retrieveCustomer(user.stripe_customer_id)
# 		begin
# 			cards = stripeCustomer.sources
# 		rescue 'Exception' => e
# 			cards = []
# 		end
# 		cards
# 	end
  
#   # APIs in which this method is using "add_card_to_default" and  in same module methods like: 	add_card_on_stripe, checkDuplicateCard
# 	def make_card_as_default user,customer,card
# 		p "-----------------card-....-------------------------#{card}"
# 		p "------customer---cust---#{customer}"
# 		customer.default_source = card.id
# 		customer.save
# 		# Card.updateDefaultCard(card,user)
# 	end

# 	# APIs in which this method is using "removeCard"
# 	def removeStripeCard user,card_id
# 		p card_id
# 		stripeCustomer = Stripe::Customer.retrieve(user.stripe_customer_id)
# 		stripeCustomer.sources.retrieve(card_id).delete
# 		# card.destroy
# 	end

# 	def StripeTransactionDetail source
# 		transaction = Stripe::BalanceTransaction.retrieve(source)
# 		p transaction
# 	end

# end