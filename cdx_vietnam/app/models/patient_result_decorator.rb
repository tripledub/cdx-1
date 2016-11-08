class PatientResult
  after_save :trigger_sync_patient_result
  attr_reader :synced

  private

  def trigger_sync_patient_result
    # check xper or mirocopy
    if self.result_status_changed? && self.result_status == 'completed' && !self.is_sync
      is_have_xpert_detected = false
      is_have_xpert_detected = true if PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_name: "xpertmtb", rifampicin: "detected", result_status: 'completed').count > 0
      # check if has one xpert with detected result
      if self.result_name == 'xpertmtb'
        if is_have_xpert_detected
          sync_to_etb

          if PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_name: "xpertmtb", rifampicin: "detected", result_status: 'completed',).count == 1
            send_all_microcopy_to_etb
          end
        end
        sync_to_vtm
      elsif self.result_name == 'microscopy'
        sync_to_etb if is_have_xpert_detected
        sync_to_vtm
      end
    end
  end

  def sync_to_vtm
    json = "CdxVietnam::Presenters::Vtm".constantize.create_patient(self)
    IntegrationJob.perform_later(json)
  end

  def sync_to_etb
    json = "CdxVietnam::Presenters::Etb".constantize.create_patient(self)
    IntegrationJob.perform_later(json)
  end

  def send_all_microcopy_to_etb
    micros = PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', type: 'MicroscopyResult')
    micros.each do |micro|
      sleep 1 #sleep prevent duplicate patient
      json = "CdxVietnam::Presenters::Etb".constantize.create_patient(micro)
      IntegrationJob.perform_later(json)
    end
  end

  def send_all_xpert_to_etb
    xperts = PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', type: 'XpertResult')
    xperts.each do |xpert|
      sleep 1 #sleep prevent duplicate patient
      json = "CdxVietnam::Presenters::Etb".constantize.create_patient(xpert)
      IntegrationJob.perform_later(json)
    end
  end
end