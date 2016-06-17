class Episode < ActiveRecord::Base
  belongs_to :patient

  def self.diagnosis_options
    [
      OpenStruct.new(id: :presumptive_tb,
                     name: 'Presumptive TB',
                     anatomical: true),
      OpenStruct.new(id: :bacteriologically_confirmed,
                     name: 'Bacteriologically Confirmed',
                     anatomical: true),
      OpenStruct.new(id: :clinically_diagnosed,
                     name: 'Clinically Diagnosed',
                     anatomical: false)
    ]
  end

  def self.drug_resistance_options
    [
      OpenStruct.new(id: :mono, name: 'Monoresistance'),
      OpenStruct.new(id: :poly, name: 'Polydrug resistance'),
      OpenStruct.new(id: :multi, name: 'Multidrug resistance'),
      OpenStruct.new(id: :extensive, name: 'Extensive drug resistance'),
      OpenStruct.new(id: :rif, name: 'Rifampicin resistance'),
      OpenStruct.new(id: :unknown, name: 'Unknown')
    ]
  end

  def self.hiv_status_options
    [
      OpenStruct.new(id: :positive_tb, name: 'HIV-positive TB patient'),
      OpenStruct.new(id: :negative_tb, name: 'HIV-negative TB patient'),
      OpenStruct.new(id: :unknown_tb, name: 'HIV Status Unkown TB patient')
    ]
  end

  def self.treatment_outcome_options
    [
      OpenStruct.new(id: :cured, name: 'Cured'),
      OpenStruct.new(id: :completed, name: 'Treatment completed'),
      OpenStruct.new(id: :failed, name: 'Treatment failed'),
      OpenStruct.new(id: :died, name: 'Died'),
      OpenStruct.new(id: :lost_to_follow_up, name: 'Lost to follow-up'),
      OpenStruct.new(id: :not_evaluated, name: 'Not evaluated'),
      OpenStruct.new(id: :success, name: 'Treatment success')
    ]
  end
end
