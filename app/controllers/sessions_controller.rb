class SessionsController < Devise::SessionsController
  skip_before_action :check_no_institution!, only: :destroy
  skip_before_action :ensure_context
  before_filter :load_locales
  
  def load_locales
    @locales ||= [[I18n.t("views.en"),"en"],[I18n.t("views.vi"), "vi"]]
  end
end
