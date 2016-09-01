class SampleIdentifiersController < ApplicationController
  respond_to :json

  before_filter :find_sample_identifier

  def update
    if @sample_identifier.update(sample_identifier_params)
      render json: 'ok', status: :ok
    else
      render json: 'error', status: :bad_request
    end
  end

  protected

  def sample_identifier_params
    params.require(:sample_identifier).permit(:lab_sample_id)
  end

  def find_sample_identifier
    @sample_identifier = @navigation_context.institution.samples.joins(:sample_identifiers).where('sample_identifiers.uuid = ?', params[:id]).first.sample_identifiers.first
  end
end
