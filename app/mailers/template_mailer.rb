class TemplateMailer < ApplicationMailer
  default from: ENV.fetch('MAILER_FROM_ADDRESS', 'noreply@digitaltemplates.onrender.com')

  def delivery_email(purchase)
    @purchase = purchase
    @download_url = download_url(token: purchase.token)
    
    mail(
      to: purchase.email,
      subject: 'Your Ultimate Creator Bundle is Ready! 🎉'
    )
  end
end
