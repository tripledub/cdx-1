require_relative 'cdp_scraper'
# This class is base class for connect api
module Integration
  class Client
    def initialize
      @max_retry = 5
    end
    
    # Integration patient and order into external system
    def integration(json, log = nil)
      if !json.is_a? Hash
        json = JSON.parse(json)
      end

      patient = json['patient']
      test_order = patient['test_order']
      
      order = PatientResult.where(id: test_order["cdp_order_id"]).first
      
      return if !order || order.is_sync
      
      order.update_attributes({is_sync: true})
      
      system = patient['target_system']
      
      if !log
        log = IntegrationLog.create({
          json: json,
          patient_name: patient['name'],
          order_id: test_order['order_id'] + " - " + test_order['type'],
          fail_step: 'patient',
          system: system,
          error_message: '',
          try_n_times: 1,
          status: "In progress"
        })
      end

      # micro waiting for xpert test transfer to etb success
      try_count = 0
      loop do
        break unless (test_order['type'] == 'microscopy' && patient["patient_#{system}_id"].blank?) || try_count > @max_retry
        sleep 10
        try_count += 1
        patient_temp = Patient.where(id: patient["cdp_id"]).first
        patient["patient_#{system}_id"] = patient_temp.external_id if patient_temp.present?
        log.update_attributes({
          try_n_times: try_count, 
          error_message: "microscopy not have #{system}_patient_id",
          status: "wait_xpert"
        })
      end

      if test_order['type'] == 'microscopy' && patient["patient_#{system}_id"].blank?
        log.update_attributes({
          try_n_times: try_count, 
          error_message: "microscopy not have #{system}_patient_id",
          status: "Error"
        })
        return
      end
      
      patient_id = add_update_patient(patient, system, log)
      
      if patient_id
        test_order["patient_#{system}_id"] = patient_id
        create_test_order(test_order, system, log)
      end
    end
    
    # add or update patient to external system
    # return: patient_id if success
    #         false if there is error and write log
    def add_update_patient(patient, system, log)
      patient_id = patient["patient_#{system}_id"]
      
      # By-pass if there is already external patient id
      return patient_id if !patient_id.blank?
      
      # Sync patient data to external system
      try_count = 0
      res = nil
      loop do
        if system == 'etb'
          x = CdpScraper::EtbScraper::new(Settings.etb_username, Settings.etb_password, Settings.etb_endpoint)
          x.login
        else
          x = CdpScraper::VitimesScraper::new(Settings.vtm_username, Settings.vtm_password, Settings.vtm_endpoint, 'Content-Type' => 'application/json;charset=UTF-8')
        end
        res = x.create_patient({"patient" => patient})
        
        try_count += 1
        
        break if res[:success] || try_count >= @max_retry
        log.update_attributes({
          try_n_times: try_count,
          error_message: res[:error]
        })
        sleep 3
      end
      
      # Still fail after @max_retry time
      if !res[:success]
        log.update_attributes({
          try_n_times: try_count, 
          error_message: res[:error],
          status: "Error"
        })
        order = PatientResult.where(id: log.json["patient"]["test_order"]["cdp_order_id"]).first
        order.update_attributes({is_sync: false}) if order
        return false
      end
      
      patient["patient_#{system}_id"] = res["patient_#{system}_id".to_sym]
      cdp_patient = Patient.where(id: patient["cdp_id"]).first
      
      # update external system id into current patient
      if cdp_patient
        cdp_patient.update_attributes({
          external_patient_system: system,
          external_id: res["patient_#{system}_id".to_sym]
        })
      end
      
      log.update_attributes({
        json: {"patient" => patient},
        fail_step: "test_order",
        try_n_times: try_count, 
        error_message: ""
      })
      return res["patient_#{system}_id".to_sym]
    end
    
    # create test order and update test result
    def create_test_order(test_order, system, log)
      log.update_attributes({
        fail_step: "create_test_order"
      })
      # Sync order data to external system
      try_count = 0
      res = nil
      
      loop do
        if system == 'etb'
          x = CdpScraper::EtbScraper::new(Settings.etb_username, Settings.etb_password, Settings.etb_endpoint)
          x.login
        else
          x = CdpScraper::VitimesScraper::new(Settings.vtm_username, Settings.vtm_password, Settings.vtm_endpoint, 'Content-Type' => 'application/json;charset=UTF-8')
        end
        res = x.create_test_order({"test_order" => test_order})
        try_count += 1
        
        break if res[:success] || try_count >= @max_retry
        log.update_attributes({
          try_n_times: try_count,
          error_message: res[:error]
        })
        
        sleep 3
      end
      
      # Still fail after @max_retry time
      if !res[:success]
        log.update_attributes({
          try_n_times: try_count, 
          error_message: res[:error],
          status: "Error"
        })
        order = PatientResult.where(id: log.json["patient"]["test_order"]["cdp_order_id"]).first
        order.update_attributes({is_sync: false}) if order
        return false
      end
      
      log.update_attributes({
        fail_step: "",
        error_message: "",
        status: "Finished"
      })
      return true
    end
    
    # Admin trigger retry manually
    def retry(log_id)
      log = IntegrationLog.find(log_id)
      
      return false if !log
      
      order_id = log.json["patient"]["test_order"]["cdp_order_id"]
      
      order = PatientResult.where(id: order_id, is_sync: false).first
      
      return false if !order
      
      json = "CdxVietnam::Presenters::#{order.patient.external_patient_system.camelize}".constantize.create_patient(order)
      
      if log.fail_step == 'patient'
        integration(json, log)
      else
        json = JSON.parse(json)
        create_test_order(json["patient"]["test_order"], log.system, log)
      end
    end
  end
end
