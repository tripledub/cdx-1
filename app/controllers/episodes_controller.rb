class EpisodesController < ApplicationController
 def new
   @patient_episode = Episode.new(patient: Patient.first)
 end
end
