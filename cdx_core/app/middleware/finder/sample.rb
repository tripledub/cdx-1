module Finder
  class Sample
    class << self
      def find_by_encounter(encounter, current_user)
        samples_in_encounter = "samples.encounter_id = #{encounter.id} OR " if encounter.try(:persisted?)
        # TODO this logic is not enough to grab an empty sample from one encounter and move it to another. but is ok for CRUD experience

        ::Sample.where("#{samples_in_encounter} samples.id in (#{authorized_samples(current_user)})")
          .where(institution: encounter.institution)
          .joins(:sample_identifiers)
      end

      def as_json(json, sample)
        json.(sample, :uuids, :entity_ids, :lab_sample_ids)
        json.uuid sample.uuids[0]
      end

      protected

      def authorized_samples(current_user)
        Policy.authorize(QUERY_TEST, TestResult, current_user).joins(:sample_identifier).select('sample_identifiers.sample_id').to_sql
      end
    end
  end
end
