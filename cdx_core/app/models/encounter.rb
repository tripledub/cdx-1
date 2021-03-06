# Test order model
class Encounter < ActiveRecord::Base
  include Entity
  include AutoUUID
  include Resource
  include SiteContained
  include Auditable
  include NotificationObserver

  ASSAYS_FIELD = 'diagnosis'
  OBSERVATIONS_FIELD = 'observations'

  has_many :samples, dependent: :restrict_with_error
  has_many :test_results, dependent: :restrict_with_error
  has_many :patient_results, dependent: :destroy
  has_many :xpert_results
  has_many :audit_logs
  has_many :notifications

  belongs_to :performing_site, class_name: 'Site'
  belongs_to :patient
  belongs_to :user
  belongs_to :institution
  belongs_to :feedback_message

  validates_presence_of :patient
  validates_presence_of :institution
  validates_presence_of :site, if: Proc.new { |encounter| encounter.institution }
  validates_inclusion_of :culture_format, allow_nil: true, in: %w(solid liquid), if: Proc.new { |encounter| encounter.testing_for == 'TB' }
  validates_inclusion_of :status, in: %w(new financed not_financed samples_received samples_collected pending in_progress closed)
  validate :validate_patient

  before_save :ensure_entity_id
  before_create :set_default_status
  after_create :auto_finance_test_order

  notification_observe_field :status

  class << self
    def entity_scope
      'encounter'
    end

    def testing_for_options
      [
        ['TB', I18n.t('select.encounter.testing_for_options.tb')],
        ['HIV', I18n.t('select.encounter.testing_for_options.hiv')],
        ['Ebola', I18n.t('select.encounter.testing_for_options.ebola')]
      ]
    end

    def culture_format_options
      [
        ['solid', I18n.t('select.culture.media_options.solid')],
        ['liquid', I18n.t('select.culture.media_options.liquid')]
      ]
    end

    def status_options
      [
        ['new', I18n.t('select.encounter.status_options.new')],
        ['financed', I18n.t('select.encounter.status_options.financed')],
        ['samples_collected', I18n.t('select.encounter.status_options.samples_collected')],
        ['samples_received', I18n.t('select.encounter.status_options.samples_received')],
        ['pending', I18n.t('select.encounter.status_options.pending')],
        ['in_progress', I18n.t('select.encounter.status_options.in_progress')],
        ['not_financed', I18n.t('select.encounter.status_options.not_financed')],
        ['closed', I18n.t('select.encounter.status_options.closed')]
      ]
    end

    def merge_assays(assays1, assays2)
      return assays2 unless assays1
      return assays1 unless assays2

      assays1.dup.tap do |res|
        assays2.each do |assay2|
          assay = res.find { |a| a['condition'] == assay2['condition'] }
          if assay.nil?
            res << assay2.dup
          else
            assay.merge! assay2 do |key, v1, v2|
              if key == 'result'
                if v1 == v2
                  v1
                elsif v1 == 'indeterminate' || v1.blank? || (v1 == 'n/a' && v2 != 'indeterminate')
                  v2
                elsif v2 == 'indeterminate' || v2.blank? || (v2 == 'n/a' && v1 != 'indeterminate')
                  v1
                else
                  'indeterminate'
                end
              else
                v1
              end
            end
          end
        end
      end
    end

    def merge_assays_without_values(assays1, assays2)
      return assays2 unless assays1
      return assays1 unless assays2

      assays1.dup.tap do |res|
        assays2.each do |assay2|
          assay = res.find { |a| a['condition'] == assay2['condition'] }
          if assay.nil?
            res << (assay2.dup.tap do |h|
              h['result'] = nil
            end)
          end
        end
      end
    end

    def find_by_entity_id(entity_id, opts)
      find_by(entity_id: entity_id.to_s, institution_id: opts.fetch(:institution_id))
    end
  end

  attribute_field :start_time, copy: true

  attr_accessor :new_samples # Array({entity_id: String}) of new generated samples from UI.

  def entity_id
    core_fields['id']
  end

  def not_financed?
    status == 'not_financed'
  end

  def financed?
    status == 'financed'
  end

  def has_sample_ids?
    samples.present? && samples.first.sample_identifiers
  end

  def has_entity_id?
    entity_id.not_nil?
  end

  def has_dirty_diagnostic?
    test_results_not_in_diagnostic.count > 0
  end

  def phantom?
    super && core_fields[ASSAYS_FIELD].blank? && plain_sensitive_data[OBSERVATIONS_FIELD].blank?
  end

  def test_results_not_in_diagnostic
    diagnostic.present? ? test_results.where('updated_at > ?', user_updated_at || created_at) : test_results
  end

  def diagnostic
    core_fields[Encounter::ASSAYS_FIELD]
  end

  def human_diagnose
    return unless diagnostic

    positives = diagnostic.select { |a| a['result'] == 'positive' }.map { |a| a['condition'].try(:upcase) }.to_a
    negatives = diagnostic.select { |a| a['result'] == 'negative' }.map { |a| a['condition'].try(:upcase) }.to_a

    res = ''
    res << positives.join(', ')
    res << ' detected. ' unless positives.empty?
    res << negatives.join(', ')
    res << ' not detected. ' unless negatives.empty?

    res.strip
  end

  attribute_field OBSERVATIONS_FIELD

  def updated_diagnostic
    assays_to_merge = test_results_not_in_diagnostic.map { |tr| tr.core_fields[TestResult::ASSAYS_FIELD] }

    assays_to_merge.inject(diagnostic) do |merged, to_merge|
      Encounter.merge_assays_without_values(merged, to_merge)
    end
  end

  def updated_diagnostic_timestamp!
    update_attribute(:user_updated_at, Time.now.utc)
  end

  def self.as_json_from_query(json, encounter_query_result)
    encounter = encounter_query_result['encounter']

    json.encounter do
      json.uuid encounter['uuid']
      json.diagnosis encounter['diagnosis'] || []
      json.start_time(Extras::Dates::Format.datetime_with_time_zone(encounter['start_time']))
      json.end_time(Extras::Dates::Format.datetime_with_time_zone(encounter['end_time']))
    end

    json.site do
      json.name encounter_query_result['site']['name']
    end
  end

  def batch_id
    "CDP-#{self.id.to_s.rjust(7, '0')}"
  end

  def tests_requiring_approval
    "#{patient_results.pending_approval.count} / #{patient_results.count}"
  end

  protected

  def ensure_entity_id
    self.entity_id = entity_id
  end

  def set_default_status
    self.status = 'new'
  end

  def auto_finance_test_order
    TestOrders::Status.update_and_log(self, 'financed') if site.finance_approved == true
  end
end
