class TestBatch < ActiveRecord::Base
  include AutoUUID
  include Auditable

  belongs_to :institution
  belongs_to :encounter
  has_many :patient_results

  delegate :patient, to: :encounter

  validates_inclusion_of :status,  in: ['new', 'samples_collected', 'samples_received', 'in_progress', 'closed'], allow_nil: true

  before_create :set_status_to_new
  after_save :update_test_order_status

  def status_options
    [
      ['new', I18n.t('select.test_batch.status_options.new')],
      ['samples_collected', I18n.t('select.test_batch.status_options.samples_collected')],
      ['samples_received', I18n.t('select.test_batch.status_options.samples_received')],
      ['in_progress', I18n.t('select.test_batch.status_options.in_progress')],
      ['closed', I18n.t('select.test_batch.status_options.closed')]
    ]
  end

  protected

  def set_status_to_new
    self.status = 'new'
  end

  def update_test_order_status
    TestOrders::Persistence.change_status(encounter)
  end
end
