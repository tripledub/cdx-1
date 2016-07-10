class XpertResultsController < PatientResultsController

  before_filter :find_xpert_result, only: [:edit, :update, :show]

  def new
    @xpert_result                     = @requested_test.build_xpert_result
    @xpert_result.sample_collected_on = Date.today
    @xpert_result.result_on           = Date.today
  end

  def create
    @xpert_result           = @requested_test.build_xpert_result(xpert_result_params)

    if @requested_test.xpert_result.save_and_audit(current_user, I18n.t('xpert_results.create.audit'))
      redirect_to encounter_path(@requested_test.encounter), notice: I18n.t('xpert_results.create.notice')
    else
      render action: 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @xpert_result.update_and_audit(xpert_result_params, current_user, I18n.t('xpert_results.update.audit'))
      redirect_to encounter_path(@requested_test.encounter), notice: I18n.t('xpert_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_xpert_result
    @xpert_result = @requested_test.xpert_result
  end

  def xpert_result_params
    params.require(:xpert_result).permit(:sample_collected_on, :tuberculosis, :rifampicin, :examined_by, :result_on)
  end
end
