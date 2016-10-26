module CdxVietnam
  module Presenters
    class Vtm
      def self.create_patient(patient_result)
        new(patient_result).create_patient
      end

      attr_reader :encounter, :patient, :patient_result

      def initialize(patient_result)
        patient_result.reload
        @patient_result = patient_result
        @encounter = patient_result.encounter
        @patient = @encounter.patient
        @episode = @encounter.patient.episodes.last
      end

      def create_patient
        exam_date1 = Extras::Dates::Format.datetime_with_time_zone(encounter.updated_at, I18n.t('date.formats.vtm_long'))
        exam_date2 = Extras::Dates::Format.datetime_with_time_zone(encounter.updated_at, I18n.t('date.formats.vtm_long2'))

        {
          patient: {
            case_type: 'patient', # OK, luôn là patient
            cdp_id: patient.id.to_s,
            target_system: 'vtm', # OK
            patient_vtm_id: patient.vtm_patient_id, 
            registration_number: '', # OK
            ngayKhamBenh: exam_date1,
            strngayKhamBenh: exam_date2,
            consulting_professional: '[FROM CDP]', # OK
            diagnosis_date: diagnosis_date,
            name: patient.name,
            age: patient.age,
            gender: gender,
            health_insurance_number: 'Any',
            healthcare_unit: '981',
            cellphone_number: '23711',
            registration_address1: cdp_address(patient.addresses[1].address), # line đầu tiên của Contact Address
            registration_province: 'Hà Nội',
            registration_district: 'Quận Hoàng Mai',
            current_address: cdp_address(patient.addresses[0].address), # lấy dòng đầu tiên của PERMANENT ADDRESS
            symptoms: 'any',
            hiv_status: hiv_status_patient,
            test_order: test_order
          }
        }.to_json
      end

      private

      def cdp_address(addresses)
        if patient.addresses[1].address.blank?
          return 'Missing in CDP'
        else
          return patient.addresses[1].address
        end
      end

      def test_order
        order_type = get_order_type(patient_result.result_name)
        rs = {
          type: order_type,
          order_id: encounter.batch_id.to_s,
          cdp_order_id: patient_result.id.to_s,
          hiv_status: hiv_status_test_order,
          sample_collected_date1: Extras::Dates::Format.datetime_with_time_zone(patient_result.sample_collected_at, I18n.t('date.formats.vtm_long')),
          sample_collected_date2: Extras::Dates::Format.datetime_with_time_zone(patient_result.sample_collected_at, I18n.t('date.formats.vtm_long2')),
          requesting_site: 981,
          performing_site: 15,
          specimen_type: specimen_type(patient_result),
          requester: 'NGHI',
          result: vtm_result(order_type) 
        }
      end

      def hiv_status_patient
        mapping_list = {'positive_tb' => 3, 'negative_tb' => 2, 'unknown' => 1}
        return mapping_list[@episode.hiv_status] if @episode.present? && mapping_list[@episode.hiv_status].present?
        return 0
      end

      def hiv_status_test_order
        mapping_list = {'positive_tb' => 3, 'negative_tb' => 2, 'unknown' => 0}
        return mapping_list[@episode.hiv_status] if @episode.present? && mapping_list[@episode.hiv_status].present?
        return 1
      end

      def vtm_result(order_type)
        if order_type == 'xpert'
          return xpert_result
        elsif order_type == 'microscopy'
          return micro_result
        else
          '3'
        end
      end

      def xpert_result
        return 1 if patient_result.tuberculosis == 'not_detected'
        if patient_result.tuberculosis == 'detected'
          if patient_result.rifampicin == 'detected'
            return 3
          elsif patient_result.rifampicin == 'not_detected'
            return 2
          else
            return 4
          end
        else
          return 5 #invalid
        end
      end

      def micro_result
        mapping_list = {'negative' => '1', '1to9' => '2', '1plus' => '3', '2plus' => '4', '3plus' => '5'}
        return mapping_list[patient_result.test_result] if patient_result.test_result.present? && mapping_list[patient_result.test_result].present?
        return 'POSITIVE'
      end

      def get_order_type(cdp_order_type)
        return 'xpert' if cdp_order_type == 'xpertmtb'
        return 'microscopy' if cdp_order_type == 'microscopy'
        return ''
      end

      def specimen_type(test_order_to_send)
        if test_order_to_send.encounter.coll_sample_type.upcase == 'SPUTUM'
          '1'
        else
          '2'
        end
      end

      def age
        _dob = patient.birth_date_on
        now = Time.now.utc.to_date
        now.year - _dob.year - ((now.month > _dob.month || (now.month == _dob.month && now.day >= _dob.day)) ? 0 : 1)
      end

      def consulting_date
        Extras::Dates::Format.datetime_with_time_zone(patient.created_at, I18n.t('date.formats.etb_short'))
      end

      def dob
        Extras::Dates::Format.datetime_with_time_zone(patient.birth_date_on, I18n.t('date.formats.etb_short'))
      end

      def diagnosis_date
        Extras::Dates::Format.datetime_with_time_zone(encounter.updated_at, I18n.t('date.formats.etb_short'))
      end

      def gender
        return '0' if patient.gender.upcase == 'FEMALE'
        return '1'
      end
    end
  end
end