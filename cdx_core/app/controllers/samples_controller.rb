# Samples controller
class SamplesController < ApplicationController
  before_filter :find_encounter

  def create
    message = if @encounter.financed?
                Samples::Persistence.collect_sample_ids(@encounter, params[:samples])
              else
                I18n.t('patient_results.update_samples.updated_fail')
              end

    render json: { result: message }, status: message.empty? ? :ok : :unprocessable_entity
  end

  protected

  def find_encounter
    @encounter = @navigation_context.institution.encounters.find(params[:encounter_id])
  end
end
