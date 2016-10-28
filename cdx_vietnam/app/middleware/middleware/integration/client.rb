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

      is_wait = true

      patient_temp = Patient.where(id: patient["cdp_id"]).first
      if patient_temp.present?
        if system == 'vtm'
          if patient_temp.vtm_patient_id.blank?
            patient_temp.update_attributes({vtm_patient_id: '0'})
            is_wait = false
          end
        elsif system == 'etb'
          if patient_temp.etb_patient_id.blank?
            patient_temp.update_attributes({etb_patient_id: '0'})
            is_wait = false
          end
        end
      end

      try_count = 0
      if is_wait
        loop do
          patient_temp = Patient.where(id: patient["cdp_id"]).first
          if patient_temp.present?
            if system == 'etb'
              patient["patient_#{system}_id"] = patient_temp.etb_patient_id
            elsif system == 'vtm'
              patient["patient_#{system}_id"] = patient_temp.vtm_patient_id
            end
          end
          break unless (patient["patient_#{system}_id"].blank? || patient["patient_#{system}_id"] == '0') || try_count < @max_retry
          try_count += 1
          sleep 10
          log.update_attributes({
            try_n_times: try_count, 
            error_message: "microscopy not have #{system}_patient_id",
            status: "wait_patient_id"
          })
        end
      end

      if (patient["patient_#{system}_id"].blank? || patient["patient_#{system}_id"] == '0') && is_wait
        log.update_attributes({
          try_n_times: try_count, 
          error_message: "microscopy not have #{system}_patient_id",
          status: "timeout_for_patient_id"
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
      return patient_id if !(patient_id.blank? || patient["patient_#{system}_id"] == '0')
      
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
      
      cdp_patient = Patient.where(id: patient["cdp_id"]).first

      # Still fail after @max_retry time
      if !res[:success]
        log.update_attributes({
          try_n_times: try_count, 
          error_message: res[:error],
          status: "Error"
        })
        order = PatientResult.where(id: log.json["patient"]["test_order"]["cdp_order_id"]).first
        order.update_attributes({is_sync: false}) if order
        if cdp_patient
          if system == 'etb'
            cdp_patient.update_attributes({
              etb_patient_id: nil
            })
          elsif system == 'vtm'
            cdp_patient.update_attributes({
              vtm_patient_id: nil
            })
          end
        end
        return false
      end
      
      patient["patient_#{system}_id"] = res["patient_#{system}_id".to_sym]
      
      # update external system id into current patient
      if cdp_patient
        if system == 'etb'
          cdp_patient.update_attributes({
            etb_patient_id: res["patient_#{system}_id".to_sym]
          })
        elsif system == 'vtm'
          cdp_patient.update_attributes({
            vtm_patient_id: res["patient_#{system}_id".to_sym]
          })
        end
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
      system = log.json["patient"]['target_system']
      
      order = PatientResult.where(id: order_id, is_sync: false).first
      
      return false if !order
      
      json = "CdxVietnam::Presenters::#{system.camelize}".constantize.create_patient(order)
      
      if log.fail_step == 'patient'
        integration(json, log)
      else
        json = JSON.parse(json)
        create_test_order(json["patient"]["test_order"], log.system, log)
      end
    end
  end
end
