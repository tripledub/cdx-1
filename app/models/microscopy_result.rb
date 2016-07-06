class MicroscopyResult < PatientResult
  validates_presence_of  :sample_collected_on, :examined_by, :result_on, :specimen_type, :serial_number, :appearance
  validates_inclusion_of :results_negative, :results_1to9, :results_1plus, :results_2plus, :results_3plus, in: [true, false]
  validates_inclusion_of :appearance, in: ['blood', 'mucopurulent', 'saliva']

  class << self
    def visual_appearance_options
      [['blood', I18n.t('select.microscopy.visual_appearance.blood')], ['mucopurulent', I18n.t('select.microscopy.visual_appearance.mucopurulent')], ['saliva', I18n.t('select.microscopy.visual_appearance.saliva')]]
    end

    def visual_appearance_options_humanize(option)
      result = visual_appearance_options.find { |e| e[0] == option }
      result[1] if result
    end
  end
end
