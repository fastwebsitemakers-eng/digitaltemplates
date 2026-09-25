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
