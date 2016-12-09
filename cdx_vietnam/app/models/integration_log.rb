class IntegrationLog < ActiveRecord::Base
  serialize :json, JSON

  def self.report
    sql = %q(
      SELECT p.id cdp_patient_id, p.etb_patient_id, p.vtm_patient_id, p.name, l.order_id, l.system, l.status
      FROM patients p 
      JOIN (
          SELECT cast(json_extract(l.json, '$.patient.test_order.cdp_order_id') as unsigned) AS cdp_order_id,
                 cast(json_extract(l.json, '$.patient.cdp_id') as unsigned) AS cdp_patient_id,
                 l.*
          FROM integration_logs l 
          WHERE status = 'Finished'
      ) l ON p.id = l.cdp_patient_id
      JOIN patient_results r ON r.id = l.cdp_order_id
      JOIN encounters e ON r.encounter_id = e.id
      ORDER by p.id, l.system, l.order_id
    )
    logs = self.find_by_sql(sql)

    return logs
  end
end
