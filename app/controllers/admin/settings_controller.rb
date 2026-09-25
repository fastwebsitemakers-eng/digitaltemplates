class Admin::SettingsController < Admin::BaseController
  def edit; end

  def update
    params.fetch(:s, {}).permit(SiteSetting::DEFAULTS.keys).to_h.each { |k, v| SiteSetting.store(k, v) }
    redirect_to edit_admin_settings_path, notice: 'Settings saved'
  end

  def export
  send_data JSON.pretty_generate(SiteExport.to_hash), filename: 'site-config.json', type: 'application/json'
end

def import
  file = params[:file]
  return redirect_to(edit_admin_settings_path, alert: 'Choose a JSON file first') unless file
  SiteExport.apply(JSON.parse(file.read))
  redirect_to edit_admin_settings_path, notice: 'Import complete'
rescue JSON::ParserError, ActiveRecord::RecordInvalid => e
  redirect_to edit_admin_settings_path, alert: "Import failed: #{e.message}"
end

  def destroy
    SiteSetting.delete_all
    redirect_to edit_admin_settings_path, notice: 'Settings reset to defaults'
  end
end
