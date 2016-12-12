class IntegrationLog < ActiveRecord::Base
  serialize :json, JSON

  def self.report_to_csv
    sql = %q(
      SELECT l.id, p.id cdp_patient_id, p.etb_patient_id, p.vtm_patient_id, p.name, l.order_id, l.system, l.status
      FROM patients p 
      JOIN (
          SELECT 
                 
                 l.id as cdp_order_id,
                 l.id as cdp_patient_id,
                 l.*
          FROM integration_logs l 
          
      ) l ON p.id = l.cdp_patient_id
      JOIN patient_results r ON r.id = l.cdp_order_id
      JOIN encounters e ON r.encounter_id = e.id
      ORDER by p.id, l.system, l.order_id
    )
    
    logs = self.find_by_sql(sql)

    data = CSV.generate do |csv|
      csv << logs.first.attributes.keys if logs.first
      logs.each do |log|
        csv << log.attributes.values
      end
    end

    return data
  end
end
