# Microscopy results controller
class MicroscopyResultsController < PatientResultsController
  before_filter :find_microscopy_result, only: [:edit, :update, :show]

  def show
  end

  def edit
    @microscopy_result.sample_collected_at = @microscopy_result.sample_collected_at || Time.now
    @microscopy_result.result_at           = @microscopy_result.result_at || Time.now
    @microscopy_result.specimen_type       = I18n.t("test_results.index.specimen_type.#{@encounter.coll_sample_type}")
  end

  def update
    if PatientResults::Persistence.update_result(@microscopy_result, microscopy_result_params, 't{microscopy_results.update.audit}')
      redirect_to encounter_path(@encounter), notice: I18n.t('microscopy_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_microscopy_result
    @microscopy_result = @encounter.patient_results.find(params[:id])
  end

  def microscopy_result_params
    params.require(:microscopy_result)
          .permit(:sample_collected_at, :examined_by, :result_at, :specimen_type, :sample_identifier_id, :appearance, :test_result, :comment)
  end
end
