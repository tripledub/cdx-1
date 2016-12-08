# Returns a json with patients based
class PatientSearchController < ApplicationController
  respond_to :json

  def index
    render json: Patients::Presenter.search_results(
      Patient.where(Patient.arel_table[:name].matches("%#{params[:q]}%")).order(:name).limit(30)
    )
  end
end
