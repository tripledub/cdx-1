class Presenters::Episodes
  class << self
    def patient_episodes(episodes)
      episodes.map do |episode|
        {
          id:             episode.uuid,
          diagnosis:      Extras::Select.find_from_struct(Episode.diagnosis_options, episode.diagnosis),
          hivStatus:      Extras::Select.find_from_struct(Episode.hiv_status_options, episode.hiv_status),
          initialHistory: "#{Extras::Select.find_from_struct(Episode.initial_history_options, episode.initial_history)} - #{Extras::Select.find_from_struct(Episode.previous_history_options, episode.previous_history)}",
          drugResistance: Extras::Select.find_from_struct(Episode.drug_resistance_options, episode.drug_resistance),
          outcome:        Extras::Select.find_from_struct(Episode.treatment_outcome_options, episode.outcome),
          anatomicalSiteDiagnosis: Extras::Select.find_from_struct(Episode.diagnosis_options, episode.anatomical_site_diagnosis),
          editLink:       Rails.application.routes.url_helpers.edit_patient_episode_path(episode.patient, episode),
          created: episode.created_at.to_s(:long),
          updated: episode.updated_at.to_s(:long)
        }
      end
    end
  end
end
