class RequestedTestsController < ApplicationController

  before_filter :find_encounter, :validate_access

  def update
    error_text   = Hash.new

    params['requested_tests'].each do |test|
      current_test = @encounter.requested_tests.find(test[1]['id'])
      error_text   = current_test.errors.messages unless current_test.update_and_audit({ status: test[1]['status'], comment: test[1]['comment'] }, current_user, "Requested test #{current_test.name} has been updated")
    end

    if error_text.empty?
      render json: 'ok'
    else
      render json: error_text, status: :unprocessable_entity
    end
  end

  private

  def find_encounter
    @encounter = Encounter.find(params[:id])
  end

  def validate_access
    authorize_resource(@encounter, UPDATE_ENCOUNTER)
  end
end
