module Samples
  class Finder
    class << self
      def find_by_encounter_or_institution(encounter, current_user, institution)
        samples_in_encounter = "samples.encounter_id = #{encounter.id} OR " if encounter.try(:persisted?)
        # TODO this logic is not enough to grab an empty sample from one encounter and move it to another. but is ok for CRUD experience

        ::Sample.where("#{samples_in_encounter} samples.id in (#{authorized_samples(current_user)})")
          .where(institution: institution)
          .joins(:sample_identifiers)
      end

      def find_as_json(institution, current_user, sample_uuids, entity_id)
        samples = search_samples(institution, current_user, sample_uuids, entity_id)
        as_json_samples(samples)
      end


      def as_json(json, sample)
        json.(sample, :uuids, :entity_ids, :cpd_id_samples)
        json.uuid sample.uuids[0]
      end

      protected

      def search_samples(institution, current_user, sample_uuids, entity_id)
        find_by_encounter_or_institution(nil, current_user, institution)
          .joins("LEFT JOIN encounters ON encounters.id = samples.encounter_id")
          .where("sample_identifiers.entity_id LIKE ?", "%#{entity_id}%")
          .where("samples.encounter_id IS NULL OR encounters.is_phantom = TRUE OR sample_identifiers.uuid IN (?)", (sample_uuids || "").split(','))
      end

      def as_json_samples(samples)
        Jbuilder.new do |json|
          json.array! samples do |sample|
            as_json(json, sample)
          end
        end
      end

      def authorized_samples(current_user)
        Policy.authorize(Policy::Actions::QUERY_TEST, TestResult, current_user).joins(:sample_identifier).select('sample_identifiers.sample_id').to_sql
      end
    end
  end
end
