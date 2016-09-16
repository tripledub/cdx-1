class TestBatch < ActiveRecord::Base
  include AutoUUID
  include Auditable

  belongs_to :institution
  belongs_to :encounter
  has_many :patient_results

  delegate :patient, to: :encounter
end
