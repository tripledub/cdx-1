module Episodes
  # Presenter methods for episodes
  class Presenter
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
            created: Extras::Dates::Format.datetime_with_time_zone(episode.created_at),
            updated: Extras::Dates::Format.datetime_with_time_zone(episode.updated_at)
          }
        end
      end
    end
  end
end
