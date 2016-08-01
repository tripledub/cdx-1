class CultureResultsController < PatientResultsController

  before_filter :find_culture_result, only: [:edit, :update, :show]

  def show
  end

  def new
    @culture_result                     = @requested_test.build_culture_result
    @culture_result.sample_collected_on = Date.today
    @culture_result.result_on           = Date.today
    @culture_result.serial_number       = @requested_test.encounter.samples.map(&:entity_ids).join(', ')
    @culture_result.media_used          = @requested_test.encounter.culture_format
  end

  def create
    @culture_result = @requested_test.build_culture_result(culture_result_params)

    if @requested_test.culture_result.save_and_audit(current_user, I18n.t('culture_results.create.audit'))
      redirect_to encounter_path(@requested_test.encounter), notice: I18n.t('culture_results.create.notice')
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @culture_result.update_and_audit(culture_result_params, current_user, I18n.t('culture_results.update.audit'))
      redirect_to encounter_path(@requested_test.encounter), notice: I18n.t('culture_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_culture_result
    @culture_result = @requested_test.culture_result
  end

  def culture_result_params
    params.require(:culture_result).permit(:sample_collected_on, :examined_by, :result_on, :media_used, :serial_number, :test_result, :method_used)
  end
end
