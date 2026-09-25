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
