class PatientResult
  after_save :create_external_patient
  attr_reader :synced

  private

  def create_external_patient_old
    if self.result_status_changed? && self.result_status == 'completed'
      #TODO, check if is xpert and result is positive
      if (self.result_name == "xpertmtb") && ( self.rifampicin.present? && self.rifampicin == "detected") && !self.is_sync
        json = "CdxVietnam::Presenters::#{self.patient.external_patient_system.camelize}".constantize.create_patient(self)
        IntegrationJob.perform_later(json)
        
        get_other_microscopy
      elsif (self.result_name == "microscopy") && !self.is_sync &&
              PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_name: "xpertmtb", rifampicin: "detected", result_status: 'completed',).count > 0
        json = "CdxVietnam::Presenters::#{self.patient.external_patient_system.camelize}".constantize.create_patient(self)
        IntegrationJob.perform_later(json)
      end
    end
  end

  def get_other_microscopy
    micros = PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', type: 'MicroscopyResult', is_sync: false)
    micros.each do |micro|
      json = "CdxVietnam::Presenters::#{self.patient.external_patient_system.camelize}".constantize.create_patient(micro)
      IntegrationJob.perform_later(json)
    end
  end


  def create_external_patient
    # check xper or mirocopy
    if self.result_status_changed? && self.result_status == 'completed' && !self.is_sync
      is_have_xpert_detected = false
      is_have_xpert_detected = true if PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_name: "xpertmtb", rifampicin: "detected", result_status: 'completed',).count > 0
      # check if has one xpert with detected result
      if self.result_name == 'xpertmtb'
        # check if xpert with 'detected' result
        if ( self.rifampicin.present? && self.rifampicin == "detected") || is_have_xpert_detected
          #send xpert to etb
          json = "CdxVietnam::Presenters::Etb".constantize.create_patient(self)
          IntegrationJob.perform_later(json)
          # if this is first etb, change patient sync system to etb and make all microcopy test to not sync
          # after that call sync for all microcopy
          if PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_name: "xpertmtb", rifampicin: "detected", result_status: 'completed',).count == 1
            update_sync_status_microcopy
            send_all_microcopy_to_etb
          end
        else #send it to vtm
          # @TODO create Vtm
          json = "CdxVietnam::Presenters::Vtm".constantize.create_patient(self)
          IntegrationJob.perform_later(json)
        end
      elsif self.result_name == 'microscopy'
        if is_have_xpert_detected
          # send etb
          json = "CdxVietnam::Presenters::Etb".constantize.create_patient(self)
          IntegrationJob.perform_later(json)
        else
          # send vtm
          json = "CdxVietnam::Presenters::Vtm".constantize.create_patient(self)
          IntegrationJob.perform_later(json)
        end
      end
    end
  end

  def send_all_microcopy_to_etb
    micros = PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', type: 'MicroscopyResult')
    micros.each do |micro|
      sleep 1
      json = "CdxVietnam::Presenters::Etb".constantize.create_patient(micro)
      IntegrationJob.perform_later(json)
    end
    xperts = PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', type: 'XpertResult')
    xperts.each do |xpert|
      sleep 1
      json = "CdxVietnam::Presenters::Etb".constantize.create_patient(xpert)
      IntegrationJob.perform_later(json)
    end
  end

  def update_sync_status_microcopy
    PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', type: 'MicroscopyResult', is_sync: true).update_all(is_sync: false)
    PatientResult.joins(:encounter).where(encounters: { patient_id: self.patient.id}, result_status: 'completed', type: 'XpertResult', is_sync: true).update_all(is_sync: false)
  end
end