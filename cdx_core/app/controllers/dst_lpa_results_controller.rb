class DstLpaResultsController < PatientResultsController

  before_filter :find_dst_lpa_result, only: [:edit, :update, :show]

  before_filter :validate_culture_is_added, only: [:new, :create]

  def show
  end

  def edit
    @dst_lpa_result.sample_collected_on = @dst_lpa_result.sample_collected_on || Date.today
    @dst_lpa_result.result_on           = @dst_lpa_result.result_on  || Date.today
    @dst_lpa_result.media_used          = @dst_lpa_result.media_used || params['media']
  end

  def update
    if @dst_lpa_result.update_and_audit(dst_lpa_result_params, current_user, I18n.t('dst_lpa_results.update.audit'))
      redirect_to encounter_path(@test_batch.encounter), notice: I18n.t('dst_lpa_results.update.notice')
    else
      render action: 'edit'
    end
  end

  protected

  def find_dst_lpa_result
    @dst_lpa_result = @test_batch.patient_results.find(params[:id])
  end

  def dst_lpa_result_params
    params.require(:dst_lpa_result).permit(:sample_collected_on, :examined_by, :result_on, :media_used, :serial_number, :results_h, :results_r, :results_e, :results_s, :results_amk, :results_km, :results_cm, :results_fq, :results_other1, :results_other2, :results_other3, :results_other4, :method_used)
  end

  def validate_culture_is_added
    redirect_to(encounter_path(@test_batch.encounter), notice: I18n.t('dst_lpa_results.create.dst_warning')) if @test_batch.show_dst_warning
  end
end
