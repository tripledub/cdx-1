class CultureResultsController < PatientResultsController

  before_filter :find_culture_result, only: [:edit, :update, :show]

  def show
  end

  def edit
    @culture_result.sample_collected_on = @culture_result.sample_collected_on || Date.today
    @culture_result.result_on           = @culture_result.result_on || Date.today
    @culture_result.media_used          = @culture_result.media_used || @requested_test.encounter.culture_format
  end

  def update
    if @culture_result.update_and_audit(culture_result_params, current_user, I18n.t('culture_results.update.audit'))
      redirect_to encounter_path(@test_batch.encounter), notice: I18n.t('culture_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_culture_result
    @culture_result = @test_batch.patient_results.find(params[:id])
  end

  def culture_result_params
    params.require(:culture_result).permit(:sample_collected_on, :examined_by, :result_on, :media_used, :serial_number, :test_result, :method_used)
  end
end
