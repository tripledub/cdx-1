class TestBatch < ActiveRecord::Base
  include AutoUUID
  include Auditable

  belongs_to :institution
  belongs_to :encounter
  has_many :patient_results

  delegate :patient, to: :encounter

  validates_inclusion_of :status,  in: ['new', 'samples_collected', 'in_progress', 'closed']

  before_create :set_status_to_new
  after_save :update_test_order_status

  protected

  def set_status_to_new
    self.status = 'new'
  end

  def update_test_order_status
    TestOrders::Status.change_status(encounter)
  end
end
