class PatientResult
  after_save :create_external_patient
  attr_reader :synced
  def sync?
    return true if @synced
    @synced = true
    return false
  end

  private

  def create_external_patient
    if self.result_status == 'completed'
      #TODO, check if is xpert and result is positive
      if (self.result_name == "xpertmtb") && ( self.rifampicin.present? && self.rifampicin == "detected") && !sync?
        json = CdxVietnam::Presenters::Etb.create_patient(self)
        IntegrationJob.perform_later(json)
      end
    end
  end
end
