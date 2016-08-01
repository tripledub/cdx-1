class DstLpaResultsController < PatientResultsController

  before_filter :find_dst_lpa_result, only: [:edit, :update, :show]

  before_filter :validate_culture_is_added, only: [:new, :create]

  def new
    @dst_lpa_result                     = @requested_test.build_dst_lpa_result
    @dst_lpa_result.sample_collected_on = Date.today
    @dst_lpa_result.result_on           = Date.today
    @dst_lpa_result.serial_number       = @requested_test.encounter.samples.map(&:entity_ids).join(', ')
    @dst_lpa_result.media_used          = params['media']
  end

  def create
    @dst_lpa_result = @requested_test.build_dst_lpa_result(dst_lpa_result_params)

    if @requested_test.dst_lpa_result.save_and_audit(current_user, I18n.t('dst_lpa_results.create.audit'))
      redirect_to encounter_path(@requested_test.encounter), notice: I18n.t('dst_lpa_results.create.notice')
    else
      render action: 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @dst_lpa_result.update_and_audit(dst_lpa_result_params, current_user, I18n.t('dst_lpa_results.update.audit'))
      redirect_to encounter_path(@requested_test.encounter), notice: I18n.t('dst_lpa_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_dst_lpa_result
    @dst_lpa_result = @requested_test.dst_lpa_result
  end

  def dst_lpa_result_params
    params.require(:dst_lpa_result).permit(:sample_collected_on, :examined_by, :result_on, :media_used, :serial_number, :results_h, :results_r, :results_e, :results_s, :results_amk, :results_km, :results_cm, :results_fq, :results_other1, :results_other2, :results_other3, :results_other4, :method_used)
  end

  def validate_culture_is_added
    redirect_to(encounter_path(@requested_test.encounter), notice: I18n.t('dst_lpa_results.create.dst_warning')) if @requested_test.encounter.requested_tests.show_dst_warning
  end
end
