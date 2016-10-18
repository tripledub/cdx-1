# Vitimes Scraper Client for connecting to VTM system
#
# @input patient [JSON] patient info
# @input test_order [JSON] patient's test orders (including results)
# @return [JSON] status
#
require 'mechanize'
require 'json'
require 'time'

module Integration
  module CdpScraper
    # Implemation of the scraper for Vitimes system
    class VitimesScraper < Base
      # Get authenticated using the provided credentials
      # After logged in, the session's cookie will be used for subsequent requests
      def login
        login_url = uri('#/login')
        get(login_url)

        login_url = uri('app/customersApp/views/login.html?v=1.0.24')
        get(login_url)
        
        login_post_url = uri('api/auth/login')
        post_data = {"username": @username, "password": @passwd, "token":""}.to_json
        resp = post(login_post_url, post_data)
        resp_json = JSON.parse(resp.body)
        if resp_json['status'] != true
          raise "Authentication failed"
        end
      end
      
      # create VTM test-order
      def create_test_order(test_order)
        params = test_order['test_order'].clone

        post_data_get_patient = { "patientId": params['patient_vtm_id'] }
        resp = post(uri('api/sokhambenh/GetPatient'), post_data_get_patient.to_json)
        resp_json = JSON.parse(resp.body)
        
        vtm_id = resp_json['skbs'][0]['id']
        
        post_data = {
          "xn": {
            "id":0,
            "patientId": params['patient_vtm_id'],
            "examRecordId": vtm_id,
            "requiredFacilityId":922,
            "testReason":2,
            "testMonth":0,
            "tbTreatmentHistory":1,
            "hivStatus":1,
            "loaiBenhPham":"1",
            "loaiBenhPhamKhacGhiRo":"",
            "ngayLayMau":"2016-10-15T16:51:42.551Z",
            "strngayLayMau":"15/10/2016 23:51:42",
            "gioLayMau":23,
            "phutLayMau":51,
            "loaiYeuCauXN":6,
            "loaiYeuCauXNMauSo":"",
            "loaiYeuCauXN6LanThu":"77",
            "loaiYeuCauXN6LanThu2LyDo":"Why 2nd? Again",
            "chanDoanLao":0,
            "chanDoanLaoNgoaiPhoiGhiRo":"",
            "chanDoanLaoMDR":1,
            "chanDoanLaoXDR":0,
            "chanDoanLaoXDR1Month":0,
            "chanDoanLaoXDRKhacGhiRo":"",
            "nguoiYeuCau":"Who requested",
            "creatorId":68,
            "facilityLevelId":4,
            "provinceId":1,
            "districtId":0,
            "communeId":0,
            "facilityId":981
          }
        }

        puts post_data.to_json

        resp = post(uri('api/sokhambenh/SaveXN'), post_data.to_json)
        resp_json = JSON.parse(resp.body)
        if resp_json['status'] != true
          raise "Failed to create test-order"
        end

        return { success: true, error: '', patient_vtm_id: params['patient_vtm_id'] }
      rescue StandardError => ex
        return { success: false, error: ex.message, patient_vtm_id: params['patient_vtm_id'] }
      end
      
      # Create a patient into Vitimes
      def create_patient(patient = {})
        raise 'Invalid JSON format' unless patient['patient']
        params = patient['patient'].clone

        check_key 'name', params
        check_key 'age', params
        check_key 'gender', params

        check_valid 'gender', params, ['0', '1']
        check_valid 'hiv_status', params, ['0', '1', '2', '3']

        patient_list_page_url = uri('/#/quanlybenhnhan/sokhambenh')
        get(patient_list_page_url)

        params.merge!({
          'ngayKhamBenh' => Extras::Date::Format.datetime_with_time_zone(DateTime.strptime(params['diagnosis_date'], '%m/%d/%Y'), :etb_long),
          'strngayKhamBenh' => Extras::Date::Format.datetime_with_time_zone(DateTime.strptime(params['diagnosis_date'], '%m/%d/%Y'), :etb_short)
        })
        
        create_patient_url = uri('api/sokhambenh/SaveSKB')
        post_data = {
          "skb": {
            "id":0,
            "treatmentId":0,
            "treatmentMonth":0,
            "patientId":0,
            "ngayKhamBenh": params['ngayKhamBenh'],
            "strngayKhamBenh": params['strngayKhamBenh'],
            "bsKhamBenh": params['consulting_professional'],
            "mabnql": params['registration_number'],
            "fullName": params['name'],
            "age": params['age'],
            "yob":"",
            "gender": params['gender'].to_i,
            "idNumber":"",
            "mobile": params['cellphone_number'],
            "hasHealthInsurance":false,
            "healthInsuranceNumber":"",
            "provinceId":65,
            "districtId":0,
            "communeId":0,
            "address": params['registration_address1'],
            "contactAddress": params['current_address'],
            "jobId":0,
            "referredFromFacilityCode":0,
            "referredFromFacility":"",
            "trieuChung": params['symptoms'],
            "tinhTrangHIV": params['hiv_status'].to_i,
            "chanDoanTuyenTruoc":"",
            "chanDoanKhoaKhamBenhTCL":"",
            "huongDieuTri":"",
            "cachGiaiQuyet":0,
            "doiTuong":0,
            "ghichu":"",
            "active":1,
            "referToMDRFacilityId":0,
            "referToConfirmation":0,
            "referToConfirmationDate":"2016-10-15T15:53:26.704Z",
            "strreferToConfirmationDate":"",
            "treatmentLevelId":4,
            "treatmentProvinceId":65, # user dependency problem here
            "treatmentDistrictId":0,
            "treatmentCommuneId":0,
            "treatmentFacilityId":922,
            "referToLevelId":0,
            "referToProvinceId":0,
            "referToDistrictId":0,
            "referToCommuneId":0,
            "referToFacilityId":0,
            "referredDate":"2016-10-15T15:53:26.704Z",
            "referFromSKBId":0,
            "strreferredDate":""
          }
        }

        puts post_data.to_json
        resp = post(create_patient_url, post_data.to_json)
        resp_json = JSON.parse(resp.body)
        if resp_json['status'] != true
          raise "Failed to create patient"
        end

        return { success: true, error: '', patient_vtm_id: resp_json['data1'] }
      rescue StandardError => ex
        return { success: false, error: ex.message, patient_vtm_id: nil }
      end
    end
  end
end
