class TestResult < ActiveRecord::Base
  has_and_belongs_to_many :device_messages
  belongs_to :device
  has_one :institution, through: :device
  belongs_to :sample
  belongs_to :patient
  serialize :custom_fields, HashWithIndifferentAccess
  serialize :indexed_fields, HashWithIndifferentAccess
  validates_presence_of :device
  validates_uniqueness_of :test_id, scope: :device_id, allow_nil: true
  validate :same_patient_in_sample

  before_create :generate_uuid
  before_save :encrypt

  after_initialize do
    self.custom_fields  ||= {}
    self.indexed_fields  ||= {}
  end

  attr_writer :plain_sensitive_data

  delegate :device_model, :device_model_id, to: :device

  def merge(test)
    self.plain_sensitive_data.deep_merge_not_nil!(test.plain_sensitive_data)
    self.custom_fields.deep_merge_not_nil!(test.custom_fields)
    self.indexed_fields.deep_merge_not_nil!(test.indexed_fields)
    self.sample_id = test.sample_id unless test.sample_id.blank?
    self.device_messages |= test.device_messages
    self
  end

  def add_sample_data(sample)
    if sample.plain_sensitive_data.present?
      self.plain_sensitive_data.deep_merge_not_nil!(sample.plain_sensitive_data)
    end

    if sample.custom_fields.present?
      self.custom_fields.deep_merge_not_nil!(sample.custom_fields)
    end

    if sample.indexed_fields.present?
      self.indexed_fields.deep_merge_not_nil!(sample.indexed_fields)
    end
  end

  def extract_sample_data_into(sample)
    if self.patient_id.present?
      sample.patient_id = self.patient_id
    end

    sample.plain_sensitive_data[:sample].reverse_deep_merge!(self.plain_sensitive_data[:sample] || {})
    sample.custom_fields[:sample].reverse_deep_merge!(self.custom_fields[:sample] || {})
    sample.indexed_fields[:sample].reverse_deep_merge!(self.indexed_fields[:sample] || {})

    if self.plain_sensitive_data[:patient].present?
      sample.plain_sensitive_data[:patient] ||= {}
      sample.plain_sensitive_data[:patient].reverse_deep_merge! self.plain_sensitive_data[:patient]
    end

    if self.custom_fields[:patient].present?
      sample.custom_fields[:patient] ||= {}
      sample.custom_fields[:patient].reverse_deep_merge! self.custom_fields[:patient]
    end

    if self.indexed_fields[:patient].present?
      sample.indexed_fields[:patient] ||= {}
      sample.indexed_fields[:patient].reverse_deep_merge! self.indexed_fields[:patient]
    end

    self.plain_sensitive_data.delete(:sample)
    self.custom_fields.delete(:sample)
    self.indexed_fields.delete(:sample)
    self.plain_sensitive_data.delete(:patient)
    self.custom_fields.delete(:patient)
    self.indexed_fields.delete(:patient)
  end

  def add_patient_data(patient)
    if self.sample.present?
      self.sample.add_patient_data(patient)
      self.sample.save!
    else
      if patient.plain_sensitive_data.present?
        self.plain_sensitive_data.deep_merge_not_nil!(patient.plain_sensitive_data)
      end

      if patient.custom_fields.present?
        self.custom_fields.deep_merge_not_nil!(patient.custom_fields)
      end

      if patient.indexed_fields.present?
        self.indexed_fields.deep_merge_not_nil!(patient.indexed_fields)
      end
    end
  end

  def extract_patient_data_into(patient)
    if self.sample.present?
      self.sample.extract_patient_data_into(patient)
    else
      patient.plain_sensitive_data[:patient].reverse_deep_merge!(self.plain_sensitive_data[:patient] || {})
      patient.custom_fields[:patient].reverse_deep_merge!(self.custom_fields[:patient] || {})
      patient.indexed_fields[:patient].reverse_deep_merge!(self.indexed_fields[:patient] || {})

      self.plain_sensitive_data.delete(:patient)
      self.custom_fields.delete(:patient)
      self.indexed_fields.delete(:patient)
    end
  end

  def current_patient
    self.patient
  end

  def current_patient=(patient)
    self.patient = patient
    if self.sample.present?
      self.sample.patient = patient
      self.sample.save!
    end
  end

  def plain_sensitive_data
    @plain_sensitive_data ||= (Oj.load(MessageEncryption.decrypt(self.sensitive_data)) || {}).with_indifferent_access
  end

  def pii_data
    pii = self.plain_sensitive_data
    pii = pii.deep_merge(self.sample.plain_sensitive_data) if self.sample.present?
    pii = pii.deep_merge(self.current_patient.plain_sensitive_data) if self.current_patient.present?
    pii
  end

  def custom_fields_data
    data = self.custom_fields
    data = data.deep_merge(self.sample.custom_fields) if self.sample.present?
    data = data.deep_merge(self.current_patient.custom_fields) if self.current_patient.present?
    data
  end

  def encrypt
    self.sensitive_data = MessageEncryption.encrypt Oj.dump(self.plain_sensitive_data)
    self
  end

  def generate_uuid
    self.uuid ||= Guid.new.to_s
  end

  def self.query params, user
    TestResultQuery.new params, user
  end

  private

  def same_patient_in_sample
    if self.sample.present? && self.patient != self.sample.patient
      errors.add(:patient_id, "should match sample's patient")
    end
  end

end
