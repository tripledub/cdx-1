class XpertResultsController < PatientResultsController

  before_filter :find_xpert_result, only: [:edit, :update, :show]

  def show
  end

  def edit
    @xpert_result.sample_collected_on = @xpert_result.sample_collected_on || Date.today
    @xpert_result.result_on           = @xpert_result.result_on || Date.today
  end

  def update
    if @xpert_result.update_and_audit(xpert_result_params, current_user, I18n.t('xpert_results.update.audit'))
      redirect_to encounter_path(@test_batch.encounter), notice: I18n.t('xpert_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_xpert_result
    @xpert_result = @test_batch.patient_results.find(params[:id])
  end

  def xpert_result_params
    params.require(:xpert_result).permit(:sample_collected_on, :tuberculosis, :trace, :rifampicin, :examined_by, :result_on)
  end
end
