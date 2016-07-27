class MicroscopyResult < PatientResult
  validates_presence_of  :requested_test_id, :sample_collected_on, :examined_by, :result_on, :specimen_type, :serial_number, :appearance, :test_result
  validates_inclusion_of :test_result, in: ['negative', '1to9', '1plus', '2plus', '3plus']
  validates_inclusion_of :appearance,  in: ['blood', 'mucopurulent', 'saliva']

  delegate :patient, to: 'requested_test.encounter'

  class << self
    def visual_appearance_options
      [
        ['blood', I18n.t('select.microscopy.visual_appearance.blood')],
        ['mucopurulent', I18n.t('select.microscopy.visual_appearance.mucopurulent')],
        ['saliva', I18n.t('select.microscopy.visual_appearance.saliva')]
      ]
    end

    def test_result_options
      [
        ['negative', I18n.t('select.microscopy.test_result_options.negative')],
        ['1to9',     I18n.t('select.microscopy.test_result_options.1to9')],
        ['1plus',    I18n.t('select.microscopy.test_result_options.1plus')],
        ['2plus',    I18n.t('select.microscopy.test_result_options.2plus')],
        ['3plus',    I18n.t('select.microscopy.test_result_options.3plus')]
      ]
    end
  end
end
