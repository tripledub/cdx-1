module CdxVietnam
  module Presenters
    class Etb
      def self.create_patient(patient_result)
        new(patient_result).create_patient
      end

      attr_reader :encounter, :patient, :patient_result

      def initialize(patient_result)
        @patient_result = patient_result
        @encounter = patient_result.encounter
        @patient = @encounter.patient
      end

      def create_patient
        {
          patient: {
            case_type: 'patient', # OK, luôn là patient
            target_system: 'etb', # OK
            patient_etb_id: '', # @TODO, nếu là vtm thì nó sẽ là 1 bộ json khác, lần đầu gửi có thể NULL,  ''
            bdq_id: '000000', # OK, hard-coded
            name: patient.name,  
            registration_number: '', # not required
            gender: gender, # that ok but eTB:gender not have 'other' value
            date_of_birth: dob, 
            age: patient.age, # OK
            national_id_number: '023232323', # @TODO, cdp not have this field
            mother_name: '', # OK, hard-code
            sending_sms: 'FALSE', # OK
            treatment_sms: 'FALSE', # OK
            phone_number: '23711', # Hard-coded instead of [patient.phone]
            cellphone_number: '23711', # OK, just hard-code like this
            supervisor2_cellphone: '23711', # OK, just hard-code like this
            nationallity: 'NATIVE', # OK, just hard-code like this
            registration_address1: patient.addresses[1].address, # line đầu tiên của Contact Address
            registration_address2: '', # OK
            registration_region: 'MIỀN BẮC', # OK hard-coded
            registration_province: 'Hà Nội', # OK hard-coded
            registraiton_district: 'Cầu Giấy', # OK hard-coded
            located_at_different_address: 'FALSE', # @TODO: nếu patient.addresses[1].address ==  patient.addresses[0].address --> TRUE, otherwise FALSE 
            current_address: patient.addresses[0].address, # lấy dòng đầu tiên của PERMANENT ADDRESS
            healthcare_unit_location: 'Miền Nam', # OK
            healthcare_unit_name: 'Quận 1', # OK
            healthcare_unit_registration_date: '10/01/2016', # @TODO, ngày tạo patient
            suspect_mdr_case_type: "VN_SPT_FAILED_CAT_II",
            diagnosis_date: diagnosis_date, 
            tb_drug_resistance_type: 'RIF_RESISTANCE', # @TODO, LIST VALUE
            registration_group: "VN_2015_NEW", # @TODO
            site_of_disease: "PULMONARY", # @TODO
            number_of_previous_tb_treatment: '0',
            consulting_date: consulting_date, # @TODO, ngày tạo patient
            consulting_professional: '[FROM CDP]',
            consulting_height: '',
            consulting_weight: '100',
            consulting_comment: '',
            test_order: test_order
          }
        }.to_json
      end

      private

      def test_order
        test_order_to_send = patient_result # @TODO, get test order result should be send, which test order result will be choice? Can trigger with test order instead of patient.
        order_type = get_order_type(test_order_to_send.result_name)
        if order_type == "xpert"
          rs = {
            type: get_order_type(test_order_to_send.result_name), # @TODO
            order_id: 'CDP000034', # @TODO
            sample_collected_date: test_order_to_send.sample_collected_at.strftime('%m/%d/%Y'), # @TODO
            month: 2, # @TODO, sample on cdp not have month field
            laboratory_serial_number: 'N3432',# @TODO, cdp not have this field
            laboratory_region: 'MIỀN BẮC', # OK - HARD CODE
            laboratory_name: 'LAB - HƯNG YÊN', # OK - HARD CODE
            date_of_release: test_order_to_send.sample_collected_at.strftime('%m/%d/%Y'), # @TODO
            result: 2, # @TODO, make sure list value, result of cdp not suitable with eTB
            comment: test_order_to_send.comment
          }
        else
          rs = {
            type: get_order_type(test_order_to_send.result_name), # @TODO
            order_id: 'CDP000034', # @TODO
            sample_collected_date: test_order_to_send.sample_collected_at.strftime('%m/%d/%Y'), # @TODO
            month: 2, # @TODO, sample on cdp not have month field
            specimen_type: specimen_type(test_order_to_send), # @TODO, make sure valid LIST VALUE
            laboratory_serial_number: 'N3432',# @TODO, cdp not have this field
            visual_appearance: 'BLOOD_STAINED', # @TODO, make sure valid LIST VALUE, cdp not have this field
            laboratory_region: 'MIỀN BẮC', # OK - HARD CODE
            laboratory_name: 'LAB - HƯNG YÊN', # OK - HARD CODE
            next_exam_date: '',
            date_of_release: test_order_to_send.sample_collected_at.strftime('%m/%d/%Y'), # @TODO
            result: 'NEGATIVE', # @TODO, make sure list value, result of cdp not suitable with eTB
            comment: test_order_to_send.comment
          }
        end
        return rs
      end

      def get_order_type(cdp_order_type)
        puts "=======get order type ===========#{cdp_order_type}"
        return "xpert" if cdp_order_type == 'xpertmtb'
        return "microscopy" if cdp_order_type == 'microscopy'
        return ""
      end

      def specimen_type(test_order_to_send)
        if test_order_to_send.encounter.coll_sample_type.upcase == "SPUTUM"
          "SPUTUM"
        else
          "OTHER"
        end
      end

      def site_of_disease
        # @TODO
      end

      def registration_group
        # @TODO
      end

      def tb_drug_resistance_type
        accepted_list = ["RIF_RESISTANCE", "MULTIDRUG_RESISTANCE", "PRE_XDR", "EXTENSIVEDRUG_RESISTANCE",
                         "MONO_RESISTANCE", "POLY_RESISTANCE"]
        # @TODO, patient not have tb_drug_resistance_type
        if patient.has_attribute?('tb_drug_resistance_type') && patient.tb_drug_resistance_type.present? && accepted_list.include?(patient.tb_drug_resistance_type.upcase)
          return patient.tb_drug_resistance_type.upcase
        else
          return ""
        end
      end

      def suspect_mdr_case_type
        accepted_list = ["VN_SPT_FAILED_CAT_II", "VN_SPT_CONTACT_MDR_INDEX_CASE", "VN_SPT_FAILED_CAT_I", 
                        "VN_SPT_NON_CONVERTER_AFTER_2_OR_3_MONTH", "VN_SPT_RELAPSE_OF_CAT_I_OR_CAT_II", 
                        "VN_SPT_RETREATMENT_AFTER_LOST2FOLLOWUP", "VN_SPT_TB_HIV", "VN_SPT_OTHERS",
                        "VN_SPT_NEW_TB_CASES"]
        # @TODO, patient not have suspect_mdr_case_type
        if patient.has_attribute?('suspect_mdr_case_type') && patient.suspect_mdr_case_type.present? && accepted_list.include?(patient.suspect_mdr_case_type.upcase)
          return patient.suspect_mdr_case_type.upcase
        else
          return ""
        end
      end

      def age
        _dob = patient.birth_date_on
        now = Time.now.utc.to_date
        now.year - _dob.year - ((now.month > _dob.month || (now.month == _dob.month && now.day >= _dob.day)) ? 0 : 1)
      end

      def consulting_date
        patient.created_at.strftime('%m/%d/%Y')
      end

      def dob
        patient.birth_date_on.strftime('%m/%d/%Y')
      end

      def diagnosis_date
        encounter.updated_at.strftime('%m/%d/%Y')
      end

      def gender
        gender = patient.gender || patient.core_fields[:gender]
        gender.upcase || 'N/A'
      end
    end
  end
end