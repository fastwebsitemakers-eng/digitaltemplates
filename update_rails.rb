#!/usr/bin/env ruby
# frozen_string_literal: true

# update_rails.rb - TemplateBar Stripe Integration Installer
# 
# This script safely adds Stripe checkout, webhooks, and secure downloads
# to your existing Rails application without breaking current functionality.
#
# Usage: ruby update_rails.rb

require 'fileutils'
require 'time'

class TemplateBarStripeInstaller
  BACKUP_DIR = "backups/#{Time.now.strftime('%Y%m%d_%H%M%S')}"
  
  def initialize
    @root = Dir.pwd
    validate_rails_app!
  end

  def run
    puts "\n🚀 TemplateBar Stripe Integration Installer"
    puts "=" * 70
    puts "This installer will add Stripe checkout and secure downloads"
    puts "to your TemplateBar application without breaking existing code."
    puts "=" * 70
    
    create_backup_directory
    add_stripe_gem
    add_dotenv_gem
    create_purchase_migration
    create_purchase_model
    create_checkouts_controller
    create_webhooks_controller
    create_downloads_controller
    create_template_mailer
    create_mailer_views
    create_checkout_views
    create_stripe_initializer
    update_routes
    create_env_example
    create_downloads_directory
    create_gitignore_entries
    
    print_success_message
  end

  private

  def validate_rails_app!
    unless File.exist?('config/application.rb')
      puts "❌ Error: This doesn't appear to be a Rails application root directory."
      puts "   Please run this script from your Rails project root."
      exit 1
    end
    
    puts "✓ Rails application detected"
  end

  def create_backup_directory
    FileUtils.mkdir_p(BACKUP_DIR)
    puts "\n📁 Created backup directory: #{BACKUP_DIR}"
  end

  def backup_file(file_path)
    return unless File.exist?(file_path)
    
    backup_path = File.join(BACKUP_DIR, file_path)
    FileUtils.mkdir_p(File.dirname(backup_path))
    FileUtils.cp(file_path, backup_path)
    puts "   ✓ Backed up #{file_path}"
  end

  def create_file(path, content)
    if File.exist?(path)
      puts "   ⚠  #{path} already exists, skipping..."
      return false
    end

    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    puts "   ✓ Created #{path}"
    true
  end

  def add_stripe_gem
    puts "\n📦 Adding Stripe gem to Gemfile..."
    
    gemfile_path = 'Gemfile'
    backup_file(gemfile_path)
    
    gemfile_content = File.read(gemfile_path)
    
    if gemfile_content.match?(/gem\s+['"]stripe['"]/)
      puts "   ⚠  Stripe gem already in Gemfile"
    else
      # Find a good place to add the gem
      insertion_point = gemfile_content.match(/^group :development/)
      
      if insertion_point
        position = insertion_point.begin(0)
        updated_content = gemfile_content.insert(position, 
          "\n# Stripe payment processing\ngem \"stripe\", \"~> 10.0\"\n\n")
      else
        # Add before the last line
        updated_content = gemfile_content.sub(/\z/, "\n# Stripe payment processing\ngem \"stripe\", \"~> 10.0\"\n")
      end
      
      File.write(gemfile_path, updated_content)
      puts "   ✓ Added stripe gem to Gemfile"
    end
  end

  def add_dotenv_gem
    puts "\n📦 Adding dotenv-rails gem to Gemfile..."
    
    gemfile_path = 'Gemfile'
    gemfile_content = File.read(gemfile_path)
    
    if gemfile_content.match?(/gem\s+['"]dotenv-rails['"]/)
      puts "   ⚠  dotenv-rails gem already in Gemfile"
    else
      # Add to development and test group
      if gemfile_content.match?(/group :development, :test do/)
        updated_content = gemfile_content.sub(
          /(group :development, :test do\n)/,
          "\\1  gem \"dotenv-rails\"\n"
        )
      else
        updated_content = gemfile_content.sub(/\z/, 
          "\ngroup :development, :test do\n  gem \"dotenv-rails\"\nend\n")
      end
      
      File.write(gemfile_path, updated_content)
      puts "   ✓ Added dotenv-rails gem to Gemfile"
    end
    
    puts "   ℹ️  Run 'bundle install' after this script completes"
  end

  def create_purchase_migration
    puts "\n🗄️  Creating Purchase migration..."
    
    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    migration_path = "db/migrate/#{timestamp}_create_purchases.rb"
    
    # Detect Rails version for migration class
    rails_version = detect_rails_version
    
    create_file(migration_path, <<~RUBY)
      class CreatePurchases < ActiveRecord::Migration#{rails_version}
        def change
          create_table :purchases do |t|
            t.string :email, null: false
            t.string :product_name, null: false
            t.string :token, null: false
            t.string :stripe_session_id, null: false
            t.string :stripe_payment_intent_id
            t.integer :amount_paid, null: false
            t.string :currency, null: false, default: "usd"
            t.string :status, null: false, default: "paid"
            t.datetime :download_expires_at
            t.integer :download_count, null: false, default: 0
            t.timestamps
          end

          add_index :purchases, :token, unique: true
          add_index :purchases, :stripe_session_id, unique: true
          add_index :purchases, :email
        end
      end
    RUBY
  end

  def detect_rails_version
    return "[7.0]" unless File.exist?('config/application.rb')
    
    app_content = File.read('config/application.rb')
    if app_content.match?(/Rails::Application/)
      # Try to detect version from Gemfile
      gemfile_content = File.read('Gemfile')
      if match = gemfile_content.match(/gem ['"]rails['"],\s*['"]~>\s*(\d+\.\d+)/)
        return "[#{match[1]}]"
      end
    end
    
    "[7.0]" # Default to 7.0
  end

  def create_purchase_model
    puts "\n📊 Creating Purchase model..."
    
    create_file('app/models/purchase.rb', <<~RUBY)
      require 'securerandom'

      class Purchase < ApplicationRecord
        # Validations
        validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
        validates :product_name, presence: true
        validates :token, presence: true, uniqueness: true
        validates :stripe_session_id, presence: true, uniqueness: true
        validates :amount_paid, presence: true, numericality: { greater_than: 0 }
        validates :currency, presence: true
        validates :status, presence: true

        # Callbacks
        before_validation :generate_token, on: :create
        before_validation :set_download_expiry, on: :create

        # Scopes
        scope :valid_downloads, -> { where('download_expires_at IS NULL OR download_expires_at > ?', Time.current) }
        scope :by_email, ->(email) { where(email: email) }

        # Class methods
        def self.find_by_valid_token(token)
          valid_downloads.find_by(token: token)
        end

        # Instance methods
        def download_expired?
          download_expires_at.present? && download_expires_at < Time.current
        end

        def increment_download_count!
          increment!(:download_count)
        end

        def download_url
          Rails.application.routes.url_helpers.download_url(token: token)
        end

        private

        def generate_token
          self.token ||= SecureRandom.urlsafe_base64(32)
        end

        def set_download_expiry
          # Set download link to expire in 30 days (optional)
          # Uncomment the line below to enable expiry:
          # self.download_expires_at ||= 30.days.from_now
        end
      end
    RUBY
  end

  def create_checkouts_controller
    puts "\n🛒 Creating CheckoutsController..."
    
    create_file('app/controllers/checkouts_controller.rb', <<~RUBY)
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
          Rails.logger.error "Stripe error: \#{e.message}"
          redirect_to root_path, alert: "Payment processing error. Please try again."
        end

        def success
          if params[:session_id].present?
            @session_id = params[:session_id]
            begin
              @session = Stripe::Checkout::Session.retrieve(@session_id)
              @purchase = Purchase.find_by(stripe_session_id: @session_id)
            rescue Stripe::StripeError => e
              Rails.logger.error "Stripe error: \#{e.message}"
            end
          end
        end
      end
    RUBY
  end

  def create_webhooks_controller
    puts "\n🔗 Creating WebhooksController..."
    
    create_file('app/controllers/webhooks_controller.rb', <<~RUBY)
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
            Rails.logger.error "Webhook JSON parse error: \#{e.message}"
            return head :bad_request
          rescue Stripe::SignatureVerificationError => e
            Rails.logger.error "Webhook signature verification failed: \#{e.message}"
            return head :bad_request
          end

          # Handle the event
          case event.type
          when 'checkout.session.completed'
            handle_checkout_completed(event.data.object)
          else
            Rails.logger.info "Unhandled event type: \#{event.type}"
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
            Rails.logger.error "No customer email in session \#{session.id}"
            return
          end

          # Verify payment was successful
          unless session.payment_status == 'paid'
            Rails.logger.warn "Payment not completed for session \#{session.id}"
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
          TemplateMailer.delivery_email(purchase).deliver_later

          Rails.logger.info "Purchase \#{purchase.id} created for \#{customer_email}"
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Failed to create purchase: \#{e.message}"
        rescue StandardError => e
          Rails.logger.error "Error handling checkout: \#{e.message}"
          Rails.logger.error e.backtrace.join("\\n")
        end
      end
    RUBY
  end

  def create_downloads_controller
    puts "\n⬇️  Creating DownloadsController..."
    
    create_file('app/controllers/downloads_controller.rb', <<~RUBY)
      class DownloadsController < ApplicationController
        def show
          @purchase = Purchase.find_by_valid_token(params[:token])

          unless @purchase
            render_error("Invalid or expired download link")
            return
          end

          if @purchase.download_expired?
            render_error("This download link has expired")
            return
          end

          file_path = download_file_path
          
          unless File.exist?(file_path)
            render_error("Download file not found. Please contact support.")
            return
          end

          # Track download
          @purchase.increment_download_count!

          # Send file
          send_file file_path,
                    filename: 'Ultimate-Creator-Bundle.zip',
                    type: 'application/zip',
                    disposition: 'attachment'
        end

        private

        def download_file_path
          # SECURE: File is stored outside the public directory
          # It can only be accessed through this controller with a valid token
          Rails.root.join('storage', 'downloads', 'ultimate-creator-bundle.zip')
        end

        def render_error(message)
          render plain: message, status: :not_found
        end
      end
    RUBY
  end

  def create_template_mailer
    puts "\n📧 Creating TemplateMailer..."
    
    create_file('app/mailers/template_mailer.rb', <<~RUBY)
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
    RUBY
  end

  def create_mailer_views
    puts "\n📄 Creating mailer views..."
    
    create_file('app/views/template_mailer/delivery_email.html.erb', <<~ERB)
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
              line-height: 1.6;
              color: #333;
              background-color: #f4f4f4;
              margin: 0;
              padding: 0;
            }
            .container {
              max-width: 600px;
              margin: 40px auto;
              background: white;
              border-radius: 8px;
              overflow: hidden;
              box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }
            .header {
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white;
              padding: 40px 20px;
              text-align: center;
            }
            .header h1 {
              margin: 0;
              font-size: 28px;
            }
            .content {
              padding: 40px 30px;
            }
            .button {
              display: inline-block;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white !important;
              text-decoration: none;
              padding: 15px 40px;
              border-radius: 6px;
              font-weight: 600;
              margin: 20px 0;
            }
            .footer {
              background: #f8f8f8;
              padding: 20px;
              text-align: center;
              font-size: 14px;
              color: #666;
            }
            .info-box {
              background: #f8f9fa;
              border-left: 4px solid #667eea;
              padding: 15px;
              margin: 20px 0;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>🎉 You're All Set!</h1>
            </div>
            
            <div class="content">
              <h2>Thank you for your purchase!</h2>
              
              <p>Your <strong>Ultimate Creator Bundle</strong> with 300+ premium templates is ready to download.</p>
              
              <div style="text-align: center;">
                <a href="<%= @download_url %>" class="button">Download Your Templates</a>
              </div>
              
              <div class="info-box">
                <strong>What's included:</strong>
                <ul>
                  <li>300+ Premium Social Media Templates</li>
                  <li>Instagram, Facebook, TikTok, and more</li>
                  <li>Fully customizable designs</li>
                  <li>Commercial license included</li>
                </ul>
              </div>
              
              <p><strong>Download Link:</strong><br>
              <a href="<%= @download_url %>"><%= @download_url %></a></p>
              
              <p>This link is unique to your purchase. Please keep it safe for future downloads.</p>
              
              <p>Need help? Just reply to this email and we'll be happy to assist you.</p>
              
              <p>Happy creating!<br>
              The TemplateBar Team</p>
            </div>
            
            <div class="footer">
              <p>TemplateBar - Premium Templates for Content Creators</p>
              <p>This email was sent because you purchased the Ultimate Creator Bundle.</p>
            </div>
          </div>
        </body>
      </html>
    ERB

    create_file('app/views/template_mailer/delivery_email.text.erb', <<~ERB)
      You're All Set! 🎉

      Thank you for your purchase!

      Your Ultimate Creator Bundle with 300+ premium templates is ready to download.

      Download Your Templates:
      <%= @download_url %>

      What's included:
      - 300+ Premium Social Media Templates
      - Instagram, Facebook, TikTok, and more
      - Fully customizable designs
      - Commercial license included

      This link is unique to your purchase. Please keep it safe for future downloads.

      Need help? Just reply to this email and we'll be happy to assist you.

      Happy creating!
      The TemplateBar Team

      ---
      TemplateBar - Premium Templates for Content Creators
      This email was sent because you purchased the Ultimate Creator Bundle.
    ERB
  end

  def create_checkout_views
    puts "\n🎨 Creating checkout views..."
    
    create_file('app/views/checkouts/success.html.erb', <<~ERB)
      <div class="success-container" style="max-width: 600px; margin: 60px auto; padding: 40px 20px; text-align: center;">
        <div class="success-icon" style="font-size: 64px; margin-bottom: 20px;">
          🎉
        </div>
        
        <h1 style="font-size: 32px; margin-bottom: 10px; color: #333;">You're All Set!</h1>
        
        <p style="font-size: 18px; color: #666; margin-bottom: 30px;">
          Your Ultimate Creator Bundle is ready.
        </p>
        
        <% if @purchase %>
          <div style="margin: 30px 0;">
            <a href="<%= download_path(token: @purchase.token) %>" 
               class="download-button"
               style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-decoration: none; padding: 15px 40px; border-radius: 6px; font-weight: 600; font-size: 18px;">
              Download Your Templates
            </a>
          </div>
          
          <p style="color: #666; margin-top: 30px;">
            A copy of your download link has also been sent to:<br>
            <strong><%= @purchase.email %></strong>
          </p>
        <% else %>
          <div style="background: #f8f9fa; border-radius: 8px; padding: 20px; margin: 20px 0;">
            <p style="color: #666; margin: 0;">
              Your purchase is being processed. You'll receive an email with your download link shortly.
            </p>
          </div>
        <% end %>
        
        <div style="margin-top: 40px; padding-top: 30px; border-top: 1px solid #e0e0e0;">
          <p style="color: #999; font-size: 14px;">
            Need help? Contact us at support@templatebar.com
          </p>
        </div>
      </div>
    ERB
  end

  def create_stripe_initializer
    puts "\n🔧 Creating Stripe initializer..."
    
    create_file('config/initializers/stripe.rb', <<~RUBY)
      # Stripe configuration
      Rails.configuration.stripe = {
        publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
        secret_key: ENV['STRIPE_SECRET_KEY']
      }

      Stripe.api_key = Rails.configuration.stripe[:secret_key]
    RUBY
  end

  def update_routes
    puts "\n🛣️  Updating routes..."
    
    routes_path = 'config/routes.rb'
    backup_file(routes_path)
    
    routes_content = File.read(routes_path)
    
    # Check if routes already exist
    if routes_content.include?('checkouts') && routes_content.include?('webhooks/stripe')
      puts "   ⚠  Routes already configured"
      return
    end
    
    # Add routes before the final 'end'
    routes_to_add = <<~RUBY.chomp.split("\n").map { |line| "  #{line}" }.join("\n")

  # Stripe checkout and webhooks
  resources :checkouts, only: [:create]
  get '/checkout/success', to: 'checkouts#success', as: :success_checkout
  
  post '/webhooks/stripe', to: 'webhooks#stripe'
  
  # Secure downloads
  get '/downloads/:token', to: 'downloads#show', as: :download
    RUBY
    
    updated_routes = routes_content.sub(/^end\s*\z/, "#{routes_to_add}\nend")
    File.write(routes_path, updated_routes)
    puts "   ✓ Added Stripe and download routes"
  end

  def create_env_example
    puts "\n🔐 Creating environment configuration..."
    
    env_example_content = <<~ENV
      # Stripe Configuration
      # Get these from https://dashboard.stripe.com/apikeys
      STRIPE_SECRET_KEY=sk_test_your_secret_key_here
      STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
      
      # Stripe Webhook Secret
      # For local testing: Run `stripe listen --forward-to localhost:3000/webhooks/stripe`
      # For production: Get from https://dashboard.stripe.com/webhooks
      STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
      
      # Stripe Price ID for Ultimate Creator Bundle ($79)
      # Create a product and price at https://dashboard.stripe.com/products
      STRIPE_PRICE_ID=price_your_price_id_here
      
      # Mailer Configuration
      MAILER_FROM_ADDRESS=noreply@digitaltemplates.onrender.com
    ENV
    
    create_file('.env.example', env_example_content)
    
    # Also create a .env file if it doesn't exist
    unless File.exist?('.env')
      create_file('.env', env_example_content)
      puts "   ✓ Created .env (remember to update with your actual keys)"
    end
  end

  def create_downloads_directory
    puts "\n📁 Creating secure downloads directory..."
    
    # Create SECURE storage directory (outside public/)
    downloads_dir = 'storage/downloads'
    FileUtils.mkdir_p(downloads_dir)
    puts "   ✓ Created #{downloads_dir} (SECURE - not publicly accessible)"
    
    readme_path = File.join(downloads_dir, 'README.md')
    create_file(readme_path, <<~MD)
      # Secure Downloads Directory

      Place your `ultimate-creator-bundle.zip` file in this directory.

      ## Security ✅

      This directory is **OUTSIDE** the `public/` folder, which means:
      - Files here are NOT directly accessible via URL
      - Downloads are ONLY available through the DownloadsController
      - Each download requires a valid, secure token from a paid purchase
      - Download counts are tracked per purchase

      ## Why This Matters

      ❌ BAD (publicly accessible):
      ```
      public/downloads/ultimate-creator-bundle.zip
      → Anyone can access: https://yourdomain.com/downloads/ultimate-creator-bundle.zip
      ```

      ✅ GOOD (secure, token-protected):
      ```
      storage/downloads/ultimate-creator-bundle.zip
      → Only accessible via: https://yourdomain.com/downloads/:secure_token
      ```

      ## File Requirements

      - **Filename:** `ultimate-creator-bundle.zip`
      - **Format:** ZIP archive
      - **Contents:** Your 300+ premium templates
      - **Location:** Place in this `storage/downloads/` directory

      ## How It Works

      1. Customer pays via Stripe
      2. Webhook creates Purchase record with unique token
      3. Customer gets email with secure download link
      4. Link format: `https://yourdomain.com/downloads/8f7a2c...`
      5. DownloadsController verifies token
      6. If valid, serves file from this secure directory
      7. Download is tracked

      ## Deployment Note

      When deploying to Render:
      1. Upload your ZIP file to this directory
      2. Or use cloud storage (S3, Google Cloud Storage) for better scalability
      3. Update `DownloadsController#download_file_path` if using cloud storage
    MD
    
    # Also create a .keep file to ensure the directory is tracked by Git
    keep_file = File.join(downloads_dir, '.keep')
    FileUtils.touch(keep_file) unless File.exist?(keep_file)
    
    puts "   ⚠️  IMPORTANT: Place your ultimate-creator-bundle.zip in storage/downloads/"
    puts "   ✓ This location is SECURE (not publicly accessible)"
  end

  def create_gitignore_entries
    puts "\n🔒 Updating .gitignore..."
    
    return unless File.exist?('.gitignore')
    
    gitignore_content = File.read('.gitignore')
    entries_to_add = []
    
    entries_to_add << '.env' unless gitignore_content.include?('.env')
    entries_to_add << '.env.local' unless gitignore_content.include?('.env.local')
    entries_to_add << 'storage/downloads/*.zip' unless gitignore_content.include?('storage/downloads/*.zip')
    
    if entries_to_add.any?
      File.open('.gitignore', 'a') do |f|
        f.puts "\n# Environment variables and downloads (added by TemplateBar installer)"
        entries_to_add.each { |entry| f.puts entry }
      end
      puts "   ✓ Added #{entries_to_add.join(', ')} to .gitignore"
    else
      puts "   ⚠  .gitignore already configured"
    end
  end

  def print_success_message
    puts "\n" + "=" * 70
    puts "✅ Installation Complete!"
    puts "=" * 70
    
    puts <<~INSTRUCTIONS

    📋 Next Steps:

    1️⃣  Install dependencies:
       $ bundle install

    2️⃣  Run the migration:
       $ rails db:migrate

    3️⃣  Configure your Stripe environment variables in .env:
       
       a) Get your API keys from: https://dashboard.stripe.com/apikeys
          STRIPE_SECRET_KEY=sk_test_...
          STRIPE_PUBLISHABLE_KEY=pk_test_...
       
       b) Create a Product in Stripe Dashboard:
          - Name: Ultimate Creator Bundle
          - Price: $79.00 USD (one-time payment)
          - Copy the Price ID (price_xxxxx) to:
            STRIPE_PRICE_ID=price_xxxxx
       
       c) For local testing, run Stripe CLI:
          $ stripe listen --forward-to localhost:3000/webhooks/stripe
          
          Copy the webhook secret it provides:
          STRIPE_WEBHOOK_SECRET=whsec_xxxxx

    4️⃣  Add your bundle file (IMPORTANT - SECURE LOCATION):
       - Place ultimate-creator-bundle.zip in storage/downloads/
       - NOT in public/ (that would make it publicly accessible)
       - The file is protected by token-based authentication

    5️⃣  Update your CTA buttons to use the checkout:
       
       Option A - Using button_to (recommended):
       <%= button_to "Get 300+ Templates", checkouts_path, 
           method: :post, class: "your-button-class" %>
       
       Option B - Using form_with:
       <%= form_with url: checkouts_path, method: :post do %>
         <%= submit_tag "Get 300+ Templates", class: "your-button-class" %>
       <% end %>
       
       Option C - Using JavaScript/Fetch:
       <button onclick="checkout()">Get 300+ Templates</button>
       <script>
         function checkout() {
           fetch('/checkouts', {
             method: 'POST',
             headers: {
               'X-CSRF-Token': document.querySelector('[name=csrf-token]').content,
               'Content-Type': 'application/json'
             }
           }).then(response => {
             if (response.redirected) {
               window.location.href = response.url;
             }
           });
         }
       </script>

    6️⃣  Test the complete flow locally:
       
       $ rails server
       $ stripe listen --forward-to localhost:3000/webhooks/stripe
       
       Then:
       a) Visit your site and click "Get 300+ templates"
       b) Use Stripe test card: 4242 4242 4242 4242
       c) Any future expiration, any CVC, any ZIP
       d) Complete the checkout
       e) Verify webhook is received (check Stripe CLI output)
       f) Check Rails logs for Purchase creation
       g) Check for delivery email in logs
       h) Test the download link

    7️⃣  Configure email delivery:
       
       For local testing, check logs:
       $ tail -f log/development.log
       
       For production (Render), configure Action Mailer:
       - Use a service like SendGrid, Mailgun, or Postmark
       - Add SMTP settings to config/environments/production.rb
       - Or use Render's environment variables

    8️⃣  For production deployment on Render:
       
       a) Add environment variables in Render Dashboard:
          STRIPE_SECRET_KEY=sk_live_...
          STRIPE_PUBLISHABLE_KEY=pk_live_...
          STRIPE_PRICE_ID=price_... (your live price)
          MAILER_FROM_ADDRESS=support@yourdomain.com
       
       b) Configure webhook in Stripe Dashboard:
          URL: https://digitaltemplates.onrender.com/webhooks/stripe
          Events to send: checkout.session.completed
          Copy webhook signing secret to Render:
          STRIPE_WEBHOOK_SECRET=whsec_...
       
       c) Upload your bundle file to storage/downloads/

    📚 Files Created:
       ✓ app/models/purchase.rb (with require 'securerandom')
       ✓ app/controllers/checkouts_controller.rb (uses success_checkout_url)
       ✓ app/controllers/webhooks_controller.rb
       ✓ app/controllers/downloads_controller.rb (secure storage/ location)
       ✓ app/mailers/template_mailer.rb
       ✓ app/views/template_mailer/delivery_email.html.erb
       ✓ app/views/template_mailer/delivery_email.text.erb
       ✓ app/views/checkouts/success.html.erb
       ✓ config/initializers/stripe.rb
       ✓ db/migrate/*_create_purchases.rb
       ✓ .env.example
       ✓ .env (if it didn't exist)
       ✓ storage/downloads/README.md (SECURE location)

    📦 Backups stored in: #{BACKUP_DIR}

    🔒 Security Improvements Applied:
       ✅ Files stored in storage/ (not public/)
       ✅ Token-based download authentication
       ✅ Webhook signature verification
       ✅ Idempotent webhook processing
       ✅ Price controlled by Stripe (not client)
       ✅ Download count tracking
       ✅ Optional download expiry

    🔗 Helpful Resources:
       - Stripe Testing Cards: https://stripe.com/docs/testing
       - Stripe CLI Install: https://stripe.com/docs/stripe-cli
       - Webhook Testing: https://stripe.com/docs/webhooks/test
       - Stripe Dashboard: https://dashboard.stripe.com

    ⚠️  Important Security Notes:
       - Never commit .env to Git
       - Use test keys (sk_test_) for local development
       - Use live keys (sk_live_) only in production
       - The Price ID controls what customers are charged
       - Customers cannot manipulate the price
       - Downloads are stored outside public/ for security

    💡 Need Help?
       - Check the README in storage/downloads/
       - Review Rails logs: tail -f log/development.log
       - Check Stripe Dashboard for webhook logs
       - Verify your .env file has all required variables

    🎉 You're ready to start accepting payments!

    INSTRUCTIONS
  end
end

# Run the installer
if __FILE__ == $0
  begin
    installer = TemplateBarStripeInstaller.new
    installer.run
  rescue StandardError => e
    puts "\n❌ Error: #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  end
end