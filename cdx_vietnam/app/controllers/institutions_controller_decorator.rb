class InstitutionsController
  def new
    redirect_to institutions_path, notice: I18n.t('institutions.new.not_allowed')
  end

  def create
    redirect_to institutions_path, notice: I18n.t('institutions.new.not_allowed')
  end
end
