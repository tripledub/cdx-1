class TestBatch < ActiveRecord::Base
  belongs_to :encounter
  has_many :patient_results

  delegate :patient, to: :encounter
end
