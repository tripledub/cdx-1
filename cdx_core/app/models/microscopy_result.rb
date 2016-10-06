class MicroscopyResult < PatientResult
  validates_presence_of  :sample_collected_on, :examined_by, :result_on, :specimen_type, :appearance, :test_result, on: :update
  validates_inclusion_of :test_result, in: %w(negative 1to9 1plus 2plus 3plus), allow_nil: true
  validates_inclusion_of :appearance,  in: %w(blood mucopurulent saliva), allow_nil: true
  validates_inclusion_of :result_status, in: %w(new sample_collected allocated pending_approval rejected completed), allow_nil: true

  delegate :patient, to: 'encounter'

  def localised_name
    I18n.t('microscopy_results.localised_name')
  end

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
