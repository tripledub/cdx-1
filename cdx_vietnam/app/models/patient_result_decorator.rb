class PatientResult
  after_save :create_external_patient
  attr_reader :synced

  private

  def create_external_patient
    if self.result_status_changed? && self.result_status == 'completed'
      #TODO, check if is xpert and result is positive
      if (self.result_name == "xpertmtb") && ( self.rifampicin.present? && self.rifampicin == "detected") && !self.is_sync
        json = CdxVietnam::Presenters::Etb.create_patient(self)
        IntegrationJob.perform_later(json)
        
        get_other_microscopy
      elsif (self.result_name == "microscopy") && !self.is_sync &&
              PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_name: "xpertmtb", rifampicin: "detected", result_status: 'completed',).count > 0
        json = CdxVietnam::Presenters::Etb.create_patient(self)
        IntegrationJob.perform_later(json)
      end
    end
  end
  
  def get_other_microscopy
    micros = PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', type: 'MicroscopyResult', is_sync: false)
    micros.each do |micro|
      json = CdxVietnam::Presenters::Etb.create_patient(micro)
      IntegrationJob.perform_later(json)
    end
  end
end
