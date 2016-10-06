# Samples controller
class SamplesController < ApplicationController
  before_filter :find_encounter

  def create
    message, status = if @encounter.financed?
                Samples::Persistence.collect_sample_ids(@encounter, params[:samples])
              else
                [I18n.t('patient_results.update_samples.updated_fail'), :unprocessable_entity]
              end

    render json: { result: message }, status: status
  end

  protected

  def find_encounter
    @encounter = @navigation_context.institution.encounters.find(params[:encounter_id])
  end
end
