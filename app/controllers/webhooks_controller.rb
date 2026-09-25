class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "Webhook JSON parse error: #{e.message}"
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Webhook signature verification failed: #{e.message}"
      return head :bad_request
    end

    # Handle the event
    case event.type
    when 'checkout.session.completed'
      handle_checkout_completed(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end

    head :ok
  end

  private

  def handle_checkout_completed(session)
    # Check for duplicate processing (idempotency)
    return if Purchase.exists?(stripe_session_id: session.id)

    # Extract customer details
    customer_email = session.customer_details&.email || session.customer_email
    
    unless customer_email.present?
      Rails.logger.error "No customer email in session #{session.id}"
      return
    end

    # Verify payment was successful
    unless session.payment_status == 'paid'
      Rails.logger.warn "Payment not completed for session #{session.id}"
      return
    end

    # Create purchase record
    purchase = Purchase.create!(
      email: customer_email,
      product_name: session.metadata&.product_name || 'Ultimate Creator Bundle',
      stripe_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent,
      amount_paid: session.amount_total,
      currency: session.currency
    )

    # Send delivery email
    TemplateMailer.delivery_email(purchase).deliver_now

    Rails.logger.info "Purchase #{purchase.id} created for #{customer_email}"
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create purchase: #{e.message}"
  rescue StandardError => e
    Rails.logger.error "Error handling checkout: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
