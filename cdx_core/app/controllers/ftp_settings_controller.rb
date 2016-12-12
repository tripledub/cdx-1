# FTP info for institutions
class FtpSettingsController < ApplicationController
  respond_to :html

  before_action :check_permissions

  def edit
  end

  def update
    if @navigation_context.institution.update(institution_params)
      redirect_to settings_path, notice: I18n.t('ftp_settings_controller.setting_updated')
    else
      render action: 'edit'
    end
  end

  protected

  def institution_params
    params.require(:institution).permit(:ftp_directory, :ftp_hostname, :ftp_username, :ftp_port, :ftp_password, :ftp_passive)
  end

  def check_permissions
    redirect_to(settings_path, error: I18n.t('ftp_settings_controller.dont_have_permission')) unless has_access?(@navigation_context.institution, UPDATE_INSTITUTION)
  end
end
