# Xpert results controller
class XpertResultsController < PatientResultsController
  before_filter :find_xpert_result, only: [:edit, :update, :show]

  def show
  end

  def edit
    @xpert_result.sample_collected_at = @xpert_result.sample_collected_at || Time.now
    @xpert_result.result_at           = @xpert_result.result_at || Time.now
  end

  def update
    if PatientResults::Persistence.update_result(@xpert_result, xpert_result_params, 't{xpert_results.update.audit}')
      redirect_to encounter_path(@encounter), notice: I18n.t('xpert_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_xpert_result
    @xpert_result = @encounter.patient_results.find(params[:id])
  end

  def xpert_result_params
    params.require(:xpert_result).permit(
      :sample_collected_at, :sample_identifier_id, :tuberculosis, :trace, :rifampicin, :examined_by, :result_at, :comment
    )
  end
end
