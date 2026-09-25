class CheckoutsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price: ENV.fetch('STRIPE_PRICE_ID'),
        quantity: 1,
      }],
      mode: 'payment',
      success_url: success_checkout_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: root_url,
      client_reference_id: SecureRandom.uuid,
      metadata: {
        product_name: 'Ultimate Creator Bundle'
      }
    )

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe error: #{e.message}"
    redirect_to root_path, alert: "Payment processing error. Please try again."
  end

  def success
    if params[:session_id].present?
      @session_id = params[:session_id]
      begin
        @session = Stripe::Checkout::Session.retrieve(@session_id)
        @purchase = Purchase.find_by(stripe_session_id: @session_id)
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe error: #{e.message}"
      end
    end
  end
end
