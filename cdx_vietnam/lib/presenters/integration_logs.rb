class Presenters::IntegrationLogs
  class << self
    def index_table(records)
      records.map do |record|
        {
          id:             record.id,
          patientName:    record.patient_name,
          orderId:        record.order_id,
          json:           record.json,
          failStep:       record.fail_step,
          system:         record.system,
          errorMessage:   record.error_message,
          tryNTimes:      record.try_n_times,
          status:         record.status,
          updatedDate:    Extras::Dates::Format.datetime_with_time_zone(record.updated_at)
        }
      end
    end
  end
end