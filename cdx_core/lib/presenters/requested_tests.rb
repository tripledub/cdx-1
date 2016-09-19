class Presenters::RequestedTests
  class << self
    def index_view(encounter)
      encounter.requested_tests.map do |requested_test|
        {
          id: requested_test.id,
          turnaround: 'out',
          comment: requested_test.comment,
          completed_at: requested_test.completed_at,
          created_at: requested_test.created_at,
          datetime: requested_test.datetime,
          encounter_id: requested_test.encounter_id,
          name: requested_test.name,
          status: requested_test.status,
          updated_at: requested_test.updated_at
        }
      end
    end
  end
end
