# Vitimes Scraper Client for connecting to VTM system
#
# @input patient [JSON] patient info
# @input test_order [JSON] patient's test orders (including results)
# @return [JSON] status
#
require 'mechanize'
require 'json'
require 'time'
require_relative 'cdp_scraper'

module Integration
  module CdpScraper
    # Implemation of the scraper for Vitimes system
    class VitimesScraper < Base
      REGION_MAP = {
        'Hoang Mai District' => 15,
        'Hai Ba Trung District' => 4,
        'Hanoi Lung Hospital' => 981
      }

      TYPE_MAP = {
        'microscopy' => 1,
        'xpert' => 6,
      }

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
        login

        params = test_order['test_order'].clone

        check_key 'type', params
        check_key 'visual_appearance', params
        check_key 'hiv_status', params
        check_key 'sample_collected_date1', params
        check_key 'sample_collected_date2', params
        check_key 'specimen_type', params
        check_key 'requesting_site', params
        check_key 'performing_site', params
        check_key 'result', params

        check_valid 'type', params, TYPE_MAP.keys
        check_valid 'hiv_status', params, [0, 1, 2, 3]
        check_valid 'specimen_type', params, [1, 2]
        check_valid 'requesting_site', params, REGION_MAP.values
        check_valid 'performing_site', params, REGION_MAP.values

        params['type'] = TYPE_MAP[params['type']]

        post_data_get_patient = { "patientId": params['patient_vtm_id'] }
        resp = post(uri('api/sokhambenh/GetPatient'), post_data_get_patient.to_json)
        resp_json = JSON.parse(resp.body)
        
        vtm_id = resp_json['skbs'][0]['id']
        
        post_data = {
          "xn": {
            "id":0,
            "patientId": params['patient_vtm_id'].to_i,
            "examRecordId": vtm_id,
            "requiredFacilityId": params['requesting_site'].to_i,
            "testReason":1,
            "testMonth":0,
            "tbTreatmentHistory":1,
            "hivStatus": params['hiv_status'].to_i,
            "loaiBenhPham": params['specimen_type'].to_s,
            "loaiBenhPhamKhacGhiRo": (params['specimen_type'].to_s == '2') ? params['specimen_type_other'] : "",
            "ngayLayMau": params['sample_collected_date1'],
            "strngayLayMau": params['sample_collected_date2'],
            "gioLayMau":10,
            "phutLayMau":10,
            "loaiYeuCauXN": params['type'].to_i,
            "loaiYeuCauXNMauSo":1,
            "loaiYeuCauXN6LanThu":0,
            "loaiYeuCauXN6LanThu2LyDo":"",
            "chanDoanLao":3,
            "chanDoanLaoNgoaiPhoiGhiRo":"",
            "chanDoanLaoMDR":0,
            "chanDoanLaoXDR":0,
            "chanDoanLaoXDR1Month":0,
            "chanDoanLaoXDRKhacGhiRo":"",
            "nguoiYeuCau":"Mr.CDP",
            "creatorId":68,
            "facilityLevelId":4,
            "provinceId":1,
            "districtId":0,
            "communeId":0,
            "facilityId": params['performing_site'].to_i
          }
        }

        puts post_data.to_json

        resp = post(uri('api/sokhambenh/SaveXN'), post_data.to_json)
        resp_json = JSON.parse(resp.body)
        if resp_json['status'] != true
          raise "Failed to create test-order"
        end
        
        # get newly created test order
        test_order_id = resp_json['data'].max_by{|e| e['id'].to_i }['id']
        puts test_order_id
        
        # update test-order result
        post_data_result = {
          "xnresult": {
            "id":0,
            "examRecordId": vtm_id.to_i,
            "patientId": params['patient_vtm_id'].to_i,
            "requiredFacilityId": params['requesting_site'].to_i,
            "testId": test_order_id,
            "testNumber": Time.now.to_i,
            "ngayNhanMau": params['sample_collected_date1'],
            "strngayNhanMau": params['sample_collected_date2'],
            "gioNhanMau":10,
            "phutNhanMau":10,
            "ngayXN": params['sample_collected_date1'],
            "strngayXN":params['sample_collected_date2'],
            "gioXN":10,
            "phutXN":10,
            "trangThaiBenhPhamAFB1_1": params['visual_appearance'].to_i,
            "ketQuaAFB1_1":(params['type'] == 1) ? params['result'].to_i : 0,
            "ketQuaAFBItGhiRo1_1":0,
            "trangThaiBenhPhamAFB1_2":0,
            "ketQuaAFB1_2":0,
            "ketQuaAFBItGhiRo1_2":0,
            "ketQuaAFB1":0,
            "trangThaiBenhPhamAFB2_1":0,
            "ketQuaAFB2_1":0,
            "ketQuaAFBItGhiRo2_1":0,
            "trangThaiBenhPhamAFB2_2":0,
            "ketQuaAFB2_2":0,
            "ketQuaAFBItGhiRo2_2":0,
            "ketQuaAFB2":0,
            "trangThaiBenhPhamMTBDinhDanhKhangRMPXpert":"",
            "ketQuaBenhPhamMTBDinhDanhKhangRMPXpert": (params['type'] == 1) ? 0 : params['result'].to_i,
            "maLoiBenhPhamMTBDinhDanhKhangRMPXpert":"",
            "trangThaiBenhPhamMTBNuoiCay":"",
            "ketQuaMTBNuoiCay":0,
            "ketQuaDinhDanhMTBNuoiCay":0,
            "ntmDinhDanhLPA":"",
            "mtblpaCoMTB":0,
            "trangThaiBenhPhamMTBLPA":"",
            "ketQuaMTBLPAIsoniazid":0,
            "ketQuaMTBLPARifampicin":0,
            "ketQuaMTBLPAFluoroquinolones":0,
            "ketQuaMTBLPACapreomycin":0,
            "ketQuaMTBLPAViomycin":0,
            "ketQuaMTBLPAAmikacin":0,
            "ketQuaMTBLPAGhiChu":"",
            "ketQuaMTBKhangThuocHang1":"",
            "ketQuaMTBKhangThuocHang2":"",
            "ketQuaMTBKhangThuocGhiChu":"",
            "ketQuaINH":0,
            "ketQuaRMP":0,
            "ketQuaEMB":0,
            "ketQuaSM":0,
            "ketQuaPZA":0,
            "ketQuaOF":0,
            "ketQuaAK":0,
            "ketQuaKM":0,
            "ketQuaCAP":0
          }
        }

        puts post_data_result.to_json

        resp = post(uri('api/sokhambenh/SaveXNResult'), post_data_result.to_json)
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
        login

        raise 'Invalid JSON format' unless patient['patient']
        params = patient['patient'].clone

        check_key 'name', params
        check_key 'age', params
        check_key 'gender', params

        check_valid 'gender', params, ['0', '1']
        check_valid 'hiv_status', params, ['0', '1', '2', '3']

        patient_list_page_url = uri('/#/quanlybenhnhan/sokhambenh')
        get(patient_list_page_url)
        
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
            "hasHealthInsurance":(params['health_insurance_number'].nil? or params['health_insurance_number'].empty?) ? false : true,
            "healthInsuranceNumber":(params['health_insurance_number'].nil? or params['health_insurance_number'].empty?) ? "" : params['health_insurance_number'],
            "provinceId":1,
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
            "treatmentProvinceId":1,
            "treatmentDistrictId":0,
            "treatmentCommuneId":0,
            "treatmentFacilityId": params['healthcare_unit'].to_i,
            "referToLevelId":0,
            "referToProvinceId":0,
            "referToDistrictId":0,
            "referToCommuneId":0,
            "referToFacilityId":0,
            "referredDate":"2016-10-21T08:24:57.489Z",
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
