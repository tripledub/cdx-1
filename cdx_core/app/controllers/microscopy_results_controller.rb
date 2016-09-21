class MicroscopyResultsController < PatientResultsController

  before_filter :find_culture_result, only: [:edit, :update, :show]

  def new
    @microscopy_result                     = @requested_test.build_microscopy_result
    @microscopy_result.sample_collected_on = Date.today
    @microscopy_result.result_on           = Date.today
    @microscopy_result.serial_number       = @requested_test.encounter.samples.map(&:entity_ids).join(', ')
    @microscopy_result.specimen_type       = @requested_test.encounter.coll_sample_type
  end

  def create
    @microscopy_result = @requested_test.build_microscopy_result(microscopy_result_params)

    if @requested_test.microscopy_result.save_and_audit(current_user, I18n.t('microscopy_results.create.audit'))
      redirect_to encounter_path(@requested_test.encounter), notice: I18n.t('microscopy_results.create.notice')
    else
      render action: 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @microscopy_result.update_and_audit(microscopy_result_params, current_user, I18n.t('microscopy_results.update.audit'))
      redirect_to encounter_path(@requested_test.encounter), notice: I18n.t('microscopy_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_culture_result
    @microscopy_result = @requested_test.microscopy_result
  end

  def microscopy_result_params
    params.require(:microscopy_result).permit(:sample_collected_on, :examined_by, :result_on, :specimen_type, :serial_number, :appearance, :test_result)
  end
end
