require 'spec_helper'

describe Presenters::Episodes do
  let(:institution) { Institution.make }
  let(:site)        { Site.make institution: institution }
  let(:patient)     { Patient.make institution: institution }

  describe 'patient_episodes' do
    before :each do
      7.times { Episode.make patient: patient }
    end

    it 'should return an array of formated devices' do
      expect(described_class.patient_episodes(patient.episodes).size).to eq(7)
    end

    it 'should return elements formated' do
      expect(described_class.patient_episodes(patient.episodes).first).to eq({
        id:             patient.episodes.first.uuid,
        diagnosis:      Extras::Select.find_from_struct(Episode.diagnosis_options, patient.episodes.first.diagnosis),
        hivStatus:      Extras::Select.find_from_struct(Episode.hiv_status_options, patient.episodes.first.hiv_status),
        initialHistory: "#{Extras::Select.find_from_struct(Episode.initial_history_options, patient.episodes.first.initial_history)} - #{Extras::Select.find_from_struct(Episode.previous_history_options, patient.episodes.first.previous_history)}",
        drugResistance: Extras::Select.find_from_struct(Episode.drug_resistance_options, patient.episodes.first.drug_resistance),
        outcome:        Extras::Select.find_from_struct(Episode.treatment_outcome_options, patient.episodes.first.outcome),
        editLink:       Rails.application.routes.url_helpers.edit_patient_episode_path(patient, patient.episodes.first)
      })
    end
  end
end
