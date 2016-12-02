class PatientResult
  after_save :create_external_patient
  attr_reader :synced

  private

  def create_external_patient
    # check xper or mirocopy
    if self.result_status_changed? && self.result_status == 'completed' && !self.is_sync
      number_xpert_detected = XpertResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, rifampicin: "detected", result_status: 'completed').count
      is_have_xpert_detected = false
      is_have_xpert_detected = true if number_xpert_detected > 0

      if self.type == 'XpertResult'
        is_xpert_detected = self.rifampicin.present? && self.rifampicin == "detected"

        if is_xpert_detected || is_have_xpert_detected
          if is_xpert_detected && number_xpert_detected == 1
            update_sync_status
            send_all_microcopy_to_etb
          else
            send_to_etb
          end
        else
          send_to_vtm
        end
      elsif self.result_name == 'microscopy'
        if is_have_xpert_detected
          send_to_etb
        else
          send_to_vtm
        end
      end
    end
  end

  def send_all_microcopy_to_etb
    MicroscopyResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', is_sync: true).update_all(is_sync: false)
    XpertResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', is_sync: true).update_all(is_sync: false)
    xperts = XpertResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', is_sync: false)
    xperts.each do |xpert|
      sleep 1
      send_to_etb(xpert)
    end
    micros = MicroscopyResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', is_sync: false)
    micros.each do |micro|
      sleep 1
      send_to_etb(micro)
    end
  end

  def update_sync_status
    
  end

  def send_to_etb(patient_result = self)
    json = CdxVietnam::Presenters::Etb.create_patient(patient_result)
    IntegrationJob.perform_later(json)
  end

  def send_to_vtm(patient_result = self)
    json = CdxVietnam::Presenters::Vtm.create_patient(patient_result)
    IntegrationJob.perform_later(json)
  end
end
