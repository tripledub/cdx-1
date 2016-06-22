class EpisodesController < ApplicationController
 def new
   @patient = Patient.find(params[:patient_id])
   @episode = Episode.new(patient: @patient)
 end
end
