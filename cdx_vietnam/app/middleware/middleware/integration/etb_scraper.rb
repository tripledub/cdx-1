# ETB Scraper Client for connecting to eTB system
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
    class EtbScraper < Integration::CdpScraper::Base
      # Get authenticated using the provided credentials
      # After logged in, the session's cookie will be used for subsequent requests
      def login
        # init the session by accessing the login page
        login_url = uri('login.seam')
        get(login_url)
        
        # post the credentials
        post_data = {
          'AJAXREQUEST' => '_viewRoot',
          'main' => 'main',
          'main:user' => @username,
          'main:pwd' => @passwd,
          'javax.faces.ViewState' => 'j_id1',
          'main:login' => 'main:login'
        }
        
        post(login_url, post_data)

        # verify if login is successful
        home_page_url = uri('home.seam')
        parser = get(home_page_url).parser
        
        # check if login is OK
        if parser.css('div.icon-user-header').empty?
          raise "Authentication failed"
        else
        end
      rescue StandardError => ex
        return { success: false, error: 'Cannot loging to eTB' }
      end
      
      # Create patient's test orders into eTB
      def create_test_order(params)
        raise RuntimeError, "Invalid JSON structure" unless params['test_order']
        if params['test_order']['type'] == 'xpert'
          create_xpert_test_order(params['test_order'].clone)
        elsif params['test_order']['type'] == 'microscopy'
          create_microscopy_test_order(params['test_order'].clone)
        else
          raise RuntimeError, "Invalid order type"
        end
      rescue StandardError => ex
        return { success: false, error: ex.message, patient_etb_id: '', flag: 1 }
      end
      
      # Create patient's Xpert test order
      def create_xpert_test_order(params)
        params['month'] = 0 if params['month'].nil? or params['month'] == ''
        check_key 'patient_etb_id', params
        check_key 'sample_collected_date', params
        check_key 'laboratory_region', params
        check_key 'laboratory_name', params
        check_key 'result', params

        check_valid 'result', params, ['0', '1', '2', '3', '4']

        resp = get(uri("cases/casedata.seam?id=#{params['patient_etb_id']}"))
        resp = get(uri("cases/edtexamgenexpert.seam?id=#{params['patient_etb_id']}"))

        keys = {}
        keys['sample_collected_date'] = resp.parser.css('input.rich-calendar-input').first.attributes['name'].text
        keys['_current_sample_collected_date'] = resp.parser.css('input.rich-calendar-input').first.next_element.next_element.attributes['name'].text
        params['_current_sample_collected_date'] = resp.parser.css('input.rich-calendar-input').first.next_element.next_element.attributes['value'].text
        keys['laboratory_serial_number'] = resp.parser.css('input[maxlength="50"]')[0].attributes['name'].text
        keys['laboratory_region'] = resp.parser.css("select")[0].attributes['name'].text
        keys['laboratory_name'] = resp.parser.css("select")[1].attributes['name'].text
        keys['month'] = resp.parser.css("select")[2].attributes['name'].text
        keys['date_of_release'] = resp.parser.css('input.rich-calendar-input')[1].attributes['name'].text
        keys['_current_date_of_release'] = resp.parser.css('input.rich-calendar-input')[1].next_element.next_element.attributes['name'].text
        params['_current_date_of_release'] = resp.parser.css('input.rich-calendar-input')[1].next_element.next_element.attributes['value'].text
        keys['result'] = resp.parser.css('select[onchange="examResultChanged(this)"]')[0].attributes['name'].text
        keys['comment'] = resp.parser.css('textarea')[0].attributes['name'].value
        keys['_formexam'] = resp.parser.css('form[action="/etbmanager/cases/edtexamgenexpert.seam"][class="form1"]')[0].attributes['name'].text
        params['_formexam'] = keys['_formexam']
        params['_viewstate'] = resp.parser.css('input[id="javax.faces.ViewState"]').first.attributes['value'].text
        params['_ajax_simple'] = resp.parser.css('span[class="readonly-value"] > select')[0].attributes['name'].text
        keys['_last'] = resp.parser.css('span[class="readonly-value"]').first.inner_html[/(?<=similarityGroupingId...)[^']+/]
        keys['_formexam2'] = resp.parser.css('a[class="button"][href="#"]').first.attributes['name'].text
        params['_formexam2'] = keys['_formexam2']

        post_data_region = {
          'AJAXREQUEST' => '_viewRoot',
          keys['sample_collected_date'] => params['sample_collected_date'],
          keys['_current_sample_collected_date'] => params['_current_sample_collected_date'],
          keys['laboratory_serial_number'] => params['laboratory_serial_number'],
          keys['laboratory_name'] => 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue',
          keys['month'] => params['month'],
          keys['date_of_release'] => params['date_of_release'],
          keys['_current_date_of_release'] => params['_current_date_of_release'],
          keys['result'] => params['result'],
          keys['comment'] => params['comment'],
          params['_formexam'] => params['_formexam'],
          'autoScroll' => '',
          'javax.faces.ViewState' => params['_viewstate'],
          keys['laboratory_region'] => '950887',
          'ajaxSingle' => params['_ajax_simple'],
          keys['_last'] => keys['_last']
        }

        resp = post(uri('cases/edtexamgenexpert.seam'), post_data_region)
        params['laboratory_name'] = resp.search("select > option").select{|e| e.text == params['laboratory_name']}.first
        raise RuntimeError, "invalid Lab Name" unless  params['laboratory_name']
        params['laboratory_name'] =  params['laboratory_name'].attributes['value'].text

        post_data = {
          'AJAXREQUEST' => '_viewRoot',
          keys['sample_collected_date'] => params['sample_collected_date'],
          keys['_current_sample_collected_date'] => params['_current_sample_collected_date'],
          keys['laboratory_serial_number'] => params['laboratory_serial_number'],
          keys['laboratory_region'] => '950887',
          keys['laboratory_name'] => params['laboratory_name'],
          keys['month'] => params['month'],
          keys['date_of_release'] => params['date_of_release'],
          keys['_current_date_of_release'] => params['_current_date_of_release'],
          keys['result'] => params['result'],
          keys['comment'] => params['comment'],
          params['_formexam'] => params['_formexam'],
          'autoScroll' => '',
          'javax.faces.ViewState' => params['_viewstate'],
          keys['_formexam2'] => params['_formexam2']
        }
        
        @agent.redirect_ok = false
        resp = post(uri('cases/edtexamgenexpert.seam'), post_data)
        @agent.redirect_ok = true

        if resp.class == Mechanize::XmlFile and resp.header and resp.header['location'].include?("/etbmanager/cases/casedata.seam?id=#{params['patient_etb_id']}")
          return { success: true, error: '', patient_etb_id: params['patient_etb_id'] }
        else
          raise RuntimeError, "Something went wrong"
        end
      rescue StandardError => ex
        return { success: false, error: ex.message, patient_etb_id: params['patient_etb_id'] }
      end
      
      # Create patient's Microcopy test order
      def create_microscopy_test_order(params)
        params['month'] = 0 if params['month'].nil? or params['month'] == ''

        check_key 'patient_etb_id', params
        check_key 'sample_collected_date', params
        check_key 'laboratory_region', params
        check_key 'laboratory_name', params
        check_key 'result', params
        
        check_valid 'specimen_type', params, ['SPUTUM', 'OTHER']
        check_valid 'visual_appearance', params, ['BLOOD_STAINED', 'MUCOPURULENT', 'SALIVA']
        check_valid 'result', params, ['NEGATIVE', 'POSITIVE', 'PLUS', 'PLUS2', 'PLUS3', 'PENDING']

        resp = get(uri("cases/casedata.seam?id=#{params['patient_etb_id']}"))
        resp = get(uri("/cases/edtexammicroscopy.seam?id=#{params['patient_etb_id']}"))
        #return resp
        keys = {}
        keys['sample_collected_date'] = resp.parser.css('input.rich-calendar-input').first.attributes['name'].text
        keys['_current_sample_collected_date'] = resp.parser.css('input.rich-calendar-input').first.next_element.next_element.attributes['name'].text
        params['_current_sample_collected_date'] = resp.parser.css('input.rich-calendar-input').first.next_element.next_element.attributes['value'].text
        keys['month'] = resp.parser.css('select')[0].attributes['name'].text
        keys['specimen_type'] = resp.parser.css('select')[1].attributes['name'].text
        keys['laboratory_serial_number'] = resp.parser.css('input[maxlength="50"]').first.attributes['name'].text
        keys['visual_appearance'] = resp.parser.css('select')[2].attributes['name'].text
        keys['laboratory_region'] = resp.parser.css('select')[3].attributes['name'].text
        keys['laboratory_name'] = resp.parser.css('select')[4].attributes['name'].text
        keys['_next_exam_date'] = resp.parser.css('input.rich-calendar-input')[1].attributes['name'].text
        params['_next_exam_date'] = ''
        keys['_current_next_exam_date'] = resp.parser.css('input.rich-calendar-input')[1].next_element.next_element.attributes['name'].text
        params['_current_next_exam_date'] = resp.parser.css('input.rich-calendar-input')[1].next_element.next_element.attributes['value'].text
        keys['date_of_release'] = resp.parser.css('input.rich-calendar-input')[2].attributes['name'].text
        keys['_current_date_of_release'] = resp.parser.css('input.rich-calendar-input')[2].next_element.next_element.attributes['name'].text
        params['_current_date_of_release'] = resp.parser.css('input.rich-calendar-input')[2].next_element.next_element.attributes['value'].text
        keys['result'] = resp.parser.css('select')[5].attributes['name'].text
        keys['_number_of_afb'] = resp.parser.css('input[maxlength="3"]').first.attributes['name'].text
        params['_number_of_afb'] = ''
        keys['comment'] = resp.parser.css('textarea')[0].attributes['name'].value
        keys['_formexam'] = resp.parser.css('form[action="/etbmanager/cases/edtexammicroscopy.seam"][class="form1"]').first.attributes['name'].text
        params['_formexam'] = keys['_formexam']
        keys['_formexam2'] = resp.parser.css('a[class="button"][href="#"]').first.attributes['name'].text
        params['_formexam2'] = keys['_formexam2']
        params['_viewstate'] = resp.parser.css('input[id="javax.faces.ViewState"]').first.attributes['value'].text
        params['_ajax_simple'] = resp.parser.css('span[class="readonly-value"] > select')[0].attributes['name'].text
        keys['_region_select'] = resp.parser.css('span[class="readonly-value"] > select')[1].attributes['name'].text
        keys['_last'] = resp.parser.css('span[class="readonly-value"]').first.inner_html[/(?<=similarityGroupingId...)[^']+/]

        post_data_region = {
          'AJAXREQUEST' => '_viewRoot',
          keys['sample_collected_date'] => params['sample_collected_date'],
          keys['_current_sample_collected_date'] => params['_current_sample_collected_date'],
          keys['month'] => params['month'],
          keys['specimen_type'] => params['specimen_type'],
          keys['laboratory_serial_number'] => params['laboratory_serial_number'],
          keys['visual_appearance'] => params['visual_appearance'],
          keys['_region_select'] => 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue',
          keys['_next_exam_date'] => '',
          keys['_current_next_exam_date'] => params['_current_next_exam_date'],
          keys['date_of_release'] => params['date_of_release'],
          keys['_current_date_of_release'] => params['_current_date_of_release'],
          keys['result'] => params['result'],
          keys['_number_of_afb'] => params['_number_of_afb'],
          keys['comment'] => params['comment'],
          keys['_formexam'] => params['_formexam'],
          'autoScroll' => '',
          'javax.faces.ViewState' => params['_viewstate'],
          keys['laboratory_region'] => '950887',
          keys['_last'] => keys['_last'],
          'ajaxSingle' => params['_ajax_simple']
        }

        resp = post(uri('cases/edtexammicroscopy.seam'), post_data_region)

        params['laboratory_name'] = resp.search("select > option").select{|e| e.text == params['laboratory_name']}.first
        raise RuntimeError, "invalid Lab Name" unless  params['laboratory_name']
        params['laboratory_name'] =  params['laboratory_name'].attributes['value'].text
        
        post_data = {
          'AJAXREQUEST' => '_viewRoot',
          keys['sample_collected_date'] => params['sample_collected_date'],
          keys['_current_sample_collected_date'] => params['_current_sample_collected_date'],
          keys['month'] => params['month'],
          keys['specimen_type'] => params['specimen_type'],
          keys['laboratory_serial_number'] => params['laboratory_serial_number'],
          keys['visual_appearance'] => params['visual_appearance'],
          keys['laboratory_region'] => '950887',
          keys['laboratory_name'] => params['laboratory_name'],
          keys['_next_exam_date'] => '',
          keys['_current_next_exam_date'] => params['_current_next_exam_date'],
          keys['date_of_release'] => params['date_of_release'],
          keys['_current_date_of_release'] => params['_current_date_of_release'],
          keys['result'] => params['result'],
          keys['_number_of_afb'] => params['_number_of_afb'],
          keys['comment'] => params['comment'],
          keys['_formexam'] => params['_formexam'],
          'autoScroll' => '',
          'javax.faces.ViewState' => params['_viewstate'],
          keys['_formexam2'] => params['_formexam2']
        }

        @agent.redirect_ok = false
        resp = post(uri('cases/edtexammicroscopy.seam'), post_data)
        @agent.redirect_ok = true

        if resp.class == Mechanize::XmlFile and resp.header and resp.header['location'].include?("/etbmanager/cases/casedata.seam?id=#{params['patient_etb_id']}")
          return { success: true, error: '', patient_etb_id: params['patient_etb_id'] }
        else
          raise RuntimeError, "Something went wrong"
        end
      rescue StandardError => ex
        return { success: false, error: ex.message, patient_etb_id: params['patient_etb_id'] }
      end
      
      # create patient
      def create_patient(patient)
        params = patient['patient'].clone
        raise 'Invalid JSON format for patient' unless params
        if params['case_type'] == 'suspect'
          create_suspect(params)
        elsif params['case_type'] == 'patient'
          create_confirmed(params)
        else
          raise 'Invalid `case_type`'
        end
      rescue StandardError => ex
        return { success: false, error: ex.message, patient_etb_id: nil }
      end
      
      # Create patient in eTB
      def create_confirmed(params)
        params = replace_empty 'nationality', params, 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue'
        params = replace_empty 'tb_drug_resistance_type', params, 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue'
        params = replace_empty 'registration_group', params, 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue'
        params = replace_empty 'site_of_disease', params, 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue'
        params = replace_empty 'number_of_previous_tb_treatment', params, '0'

        check_key 'name', params
        check_key 'bdq_id', params
        check_key 'national_id_number', params
        check_key 'gender', params
        check_key 'age', params
        check_key 'registration_address1', params
        check_key 'healthcare_unit_registration_date', params
        check_key 'diagnosis_date', params

        check_valid 'gender', params, ['MALE', 'FEMALE']
        check_valid 'nationallity', params, ['NATIVE', 'FOREIGN']

        begin
          params['date_of_birth'] = '' if DateTime.strptime(params['date_of_birth'], '%m/%d/%Y') >= Date.today
        rescue
          params['date_of_birth'] = ''
        end

        get(uri('custom/vi/cases/index.seam'))
        # go to the search page
        search_page_url = uri('cases/newnotif.seam?cla=DRTB&type=CONFIRMED&unitId=-1')
        resp = get(search_page_url)

        # extract information from the current page to use in the subsequence POST request
        _name = resp.body[/(?<=label..id=.main:namePatient.)[a-zA-Z0-9_]*/]
        _drtb = resp.parser.css('input[type=hidden]').select{|i| i.attributes['value'].text == 'DRTB'}.first.attributes['name'].text
        _current_date = resp.parser.css('input[id="main:dt:edtdateInputCurrentDate"]').first.attributes['value'].text
        _state = resp.parser.css('input[id="javax.faces.ViewState"]').first.attributes['value'].text
        _main = resp.body[/(?<=initPatientTable.......similarityGroupingId...main.)[a-zA-Z0-9_]*/]
        _main2 = resp.body[/(?<=newPatientForm=function...A4J.AJAX.Submit..main..null...similarityGroupingId...main.)[a-zA-Z0-9_]*/]
              
        # simulate a search POST before going to the new user input form
        post_data = {
          'AJAXREQUEST' => '_viewRoot',
          'main' => 'main',
          "main:namePatient:#{_name}:name" => params['name'],
          'main:dt:edtdateInputDate' => '',
          'main:dt:edtdateInputCurrentDate' => _current_date,
          _drtb => 'DRTB',
          'javax.faces.ViewState' => _state,
          "main:#{_main}" => "main:#{_main}"
        }

        search_url = uri('/cases/newnotif.seam')
        @agent.pre_connect_hooks << lambda { |agent, request| 
          request['Referer'] = search_page_url 
          request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36'
        }
        post(search_url, post_data)

        # Simulate a request to get authorized for the user input page
        # The response would be a HTTP 301 Redirect, follow the redirect to go to the edit form
        post_data = {
          'AJAXREQUEST' => '_viewRoot',
          'main' => 'main',
          "main:namePatient:#{_name}:name" => params['name'],
          'main:dt:edtdateInputDate' => '',
          'main:dt:edtdateInputCurrentDate' => _current_date,
          _drtb => 'DRTB',
          'sel1' => 'on',
          'javax.faces.ViewState' => _state,
          "main:#{_main2}" => "main:#{_main2}"
        }
        
        @agent.redirect_ok = false
        resp = post(search_url, post_data)
        @agent.redirect_ok = true

        create_patient_form_url = resp.header['location']
        
        resp = get(create_patient_form_url)

        _p_name_header = resp.parser.css('#main div#pacname').first.css('input').first.attributes['name'].text
        #_p_bbq_header = resp.parser.css('#main > div[1] > table > tr')[1].css('input').first.attributes['name'].text
        _p_national_no_header = resp.parser.css('#main > div[1] > table > tr')[2].css('input').first.attributes['name'].text
        _p_regno_header = resp.parser.css('#main > div[1] > table > tr')[3].css('input').first.attributes['name'].text
        _p_gender_header = resp.parser.css('#main > div[1] > table > tr')[3].css('td')[1].css('select').first.attributes['name'].text
        _p_age_header = resp.parser.css('#main > div[1] > table > tr')[4].css('td')[1].css('input').first.attributes['name'].text
        _p_birth_header = resp.parser.css('#main > div[1] > table > tr')[4].css('td')[0].css('input')[1].attributes['name'].text
        _p_current_date_header = resp.parser.css('#main > div[1] > table > tr')[4].css('td')[0].css('input')[2].attributes['name'].text
        _p_current_date_value = resp.parser.css('#main > div[1] > table > tr')[4].css('td')[0].css('input')[2].attributes['value'].text
        _p_mother_name_header = resp.parser.css('#main > div[1] > table > tr')[5].css('input').first.attributes['name'].text
        _p_mobile2_header = resp.parser.css('#main > div[1] > table > tr')[6].css('input').first.attributes['name'].text
        _p_receivesms_header = resp.parser.css('#main > div[1] > table > tr')[7].css('select').first.attributes['name'].text
        _p_smstreatment_header = resp.parser.css('#main > div[1] > table > tr')[8].css('select').first.attributes['name'].text

        _p_phone_header = resp.parser.css('#main > div[1] > table > tr')[9].css('td').first.css('input').first.attributes['name'].text
        _p_mobile_header = resp.parser.css('#main > div[1] > table > tr')[9].css('td').last.css('input').first.attributes['name'].text
        _p_nationality_header = resp.parser.css('#main > div[1] > table > tr')[11].css('select').first.attributes['name'].text
        _p_addr_header = resp.parser.css('#main > div[1] > table > tr')[13].css('input').first.attributes['name'].text
        _p_addr2_header = resp.parser.css('#main > div[1] > table > tr')[14].css('input').first.attributes['name'].text
        _p_region_header = resp.parser.css('#main > div[1] > table > tr')[15].css('select').first.attributes['name'].text
        _p_province_header = resp.parser.css('#main > div[1] > table > tr')[15].css('select')[1].attributes['name'].text
        _p_cbselau3_header = resp.parser.css('#main > div[1] > table > tr')[15].css('select')[2].attributes['name'].text
        _p_diff_addr_header = resp.parser.css('#main > div[1] > table > tr')[16].css('select').first.attributes['name'].text
        _p_hidden_combo_header = resp.parser.css('#main > div[1] > table > tr')[16].css('select').last.attributes['name'].text
        _p_hidden_txt1_header = resp.parser.css('#main > div[1] > table > tr')[16].css('input').first.attributes['name'].text
        _p_hidden_txt2_header = resp.parser.css('#main > div[1] > table > tr')[16].css('input').last.attributes['name'].text
        
        _p_unit_header = resp.parser.css('#main > div[2] > div > table > tr').first.css('select').first.attributes['name'].text
        _p_inputdate_header = resp.parser.css('#divregdate input').first.attributes['name'].text
        _p_inputdatecurrent_header = resp.parser.css('#divregdate input').last.attributes['name'].text
        _p_inputdatecurrent_value = resp.parser.css('#divregdate input').last.attributes['value'].text
        _p_type_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[1].css('select').first.attributes['name'].text
        _p_typedate1_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[2].css('input').first.attributes['name'].text
        _p_typedate1current_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[2].css('input').last.attributes['name'].text
        _p_typedate1current_value = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[2].css('input').last.attributes['value'].text
        _p_resistance_type = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[3].css('select').first.attributes['name'].text
        _p_pattype_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[4].css('select').first.attributes['name'].text
        _p_kobiet_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[5].css('input').first.attributes['name'].text
        _p_infectsite_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[6].css('select').first.attributes['name'].text
        _p_kobiet_a_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[7].css('select').first.attributes['name'].text
        _p_kobiet_b_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[7].css('select').last.attributes['name'].text
        _p_kobiet_c_header = resp.parser.css('#main > div[2] > div > table > tr[2] > td > div')[8].css('select').first.attributes['name'].text

        _p_previous_treatment_header = resp.parser.css('#main > div[3]').css('select').first.attributes['name'].text
        _p_date3_header = resp.parser.css('#main > div')[3].css('table > tr > td > div')[0].css('input').first.attributes['name'].text
        _p_deate3current_header = resp.parser.css('#main > div')[3].css('table > tr > td > div')[0].css('input').last.attributes['name'].text
        _p_deate3current_value = resp.parser.css('#main > div')[3].css('table > tr > td > div')[0].css('input').last.attributes['value'].text
        _p_doc_name_header = resp.parser.css('#main > div')[3].css('table > tr > td > div')[1].css('input').last.attributes['name'].text
        _p_height_header = resp.parser.css('#main > div')[3].css('table > tr > td > div')[2].css('input').last.attributes['name'].text
        _p_weight_header = resp.parser.css('#main > div')[3].css('table > tr > td > div')[3].css('input').last.attributes['name'].text
        _p_comment_header = resp.parser.css('#main > div')[3].css('table > tr > td > div')[4].css('textarea').first.attributes['name'].text

        _main_create = resp.parser.css('a.button').select{|a| a.attributes['id'] && a.attributes['id'].value[/main/] }.first.attributes['id'].value
        _state_create = _state[/[^0-9]+/] + (_state[/[0-9]+/].to_i + 1).to_s

        post_data = {
          'AJAXREQUEST' => '_viewRoot',
          _p_name_header => params['name'],
          #_p_bbq_header => params['bdq_id'],
          _p_national_no_header => params['national_id_number'],
          _p_regno_header => params['registration_number'],
          _p_birth_header => params['date_of_birth'],
          _p_gender_header => params['gender'],
          _p_current_date_header => _p_current_date_value,
          _p_age_header => params['age'],
          _p_mother_name_header => params['mother_name'],
          _p_mobile2_header => params['supervisor2_cellphone'],
          _p_receivesms_header => params['sending_sms'],
          _p_smstreatment_header => params['treatment_sms'],
          _p_phone_header => params['phone_number'],
          _p_mobile_header => params['cellphone_number'],
          _p_nationality_header => params['nationality'], # NATIVE, FOREIGN
          _p_addr_header => params['registration_address1'],
          _p_addr2_header => params['registration_address2'],
          _p_region_header => '0', # dummy
          _p_province_header => '11', # dummy
          _p_cbselau3_header => '29', # dummy
          _p_diff_addr_header => 'FALSE', # dummy, params['located_at_different_address'],
          _p_hidden_txt1_header => params['current_address'],
          _p_hidden_txt2_header => '',
          _p_hidden_combo_header => 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue',
          _p_unit_header => '63',
          _p_inputdate_header => params['healthcare_unit_registration_date'],
          _p_inputdatecurrent_header => _p_inputdatecurrent_value,
          _p_type_header => params['suspect_mdr_case_type'],
          _p_typedate1_header => params['diagnosis_date'],
          _p_typedate1current_header => _p_typedate1current_value,
          _p_resistance_type => params['tb_drug_resistance_type'],
          _p_pattype_header => 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue',
          _p_kobiet_header => '',
          _p_infectsite_header => params['site_of_disease'],
          _p_kobiet_a_header => 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue',
          _p_kobiet_b_header => 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue',
          _p_kobiet_c_header => 'org.jboss.seam.ui.NoSelectionConverter.noSelectionValue',
          _p_previous_treatment_header => params['number_of_previous_tb_treatment'],
          _p_date3_header => params['consulting_date'],
          _p_deate3current_header => _p_deate3current_value,
          _p_doc_name_header => params['consulting_professional'],
          _p_height_header => params['consulting_height'],
          _p_weight_header => params['consulting_weight'],
          _p_comment_header => params['consulting_comment'],
          'main' => 'main',
          'autoScroll' => '',
          'javax.faces.ViewState' => _state_create,
          _main_create => _main_create
        }

        puts post_data.map{|k,v| "#{k}:#{v}"}

        @agent.pre_connect_hooks << lambda { |agent, request| 
          request['Referer'] = uri('/cases/casenew.seam?cla=DRTB&type=CONFIRMED&cid=' + create_patient_form_url[/[0-9]*$/])
        }

        @agent.redirect_ok = false
        resp = post(uri('cases/casenew.seam'), post_data)
        @agent.redirect_ok = true

        patient_etb_id = resp.header['location'][/(?<=id=)[0-9]+/] # extract patient-id from response

        response = {success: true, error: '', patient_etb_id: patient_etb_id}

        return response
      rescue StandardError => ex
        return { success: false, error: ex.message, patient_etb_id: nil }
      end
    end
  end
end
