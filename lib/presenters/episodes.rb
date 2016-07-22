class Presenters::Episodes
  class << self
    def patient_episodes(episodes)
      episodes.map do |episode|
        {
          id:              episode.uuid,
          diagnosis:       Extras::Select.find_from_struct(Episode.diagnosis_options, episode.diagnosis),
          hiv_status:      Extras::Select.find_from_struct(Episode.hiv_status_options, episode.diagnosis),
          initial_history: "#{Extras::Select.find_from_struct(Episode.initial_history_options, episode.initial_history)} - #{Extras::Select.find_from_struct(Episode.previous_history_options, episode.previous_history)}",
          drug_resistance: Extras::Select.find_from_struct(Episode.drug_resistance_options, episode.diagnosis),
          outcome:         Extras::Select.find_from_struct(Episode.treatment_outcome_options, episode.diagnosis),
          editLink:        Rails.application.routes.url_helpers.edit_patient_episode_path(episode.patient, episode)
        }
      end
    end
  end
end
