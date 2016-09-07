class PatientSearchController < ApplicationController
  respond_to :json

  expose(:patients) { Patient.all }

  def index
    render json: Presenters::PatientSearch.search_results(patients.where(patients.arel_table[:name].matches("%#{params[:q]}%")).order(:name).limit(30))
  end
end
