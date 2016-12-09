require 'spec_helper'

describe Integration::CdpScraper::EtbScraper do
  before do 
    @etb_username = 'dummy'
    @etb_endpoint = 'http://dummy'
    @etb_password = 'dummy'
    # @note: in reality, hostname must be extracted from endpoint URL
    # @hostname = @etb_endpoint[/http[a]*.\/\/[^\/:]*/][/[^\/]*$/]
    @hostname = /dummy/
  end

  context '#Login: ' do
    it 'does not end up with error as long as the target endpoint is ALIVE' do 
      # stub the request and assume that the target server responds (status = 200)
      stub_request(:any, @hostname)

      client = Integration::CdpScraper::EtbScraper::new(@etb_username, @etb_password, @etb_endpoint)
      response = nil

      # the scraper should not fail even if the target server is dead
      expect { response = client.login }.not_to raise_error

      # the result JSON from the scraper should tell that the request has failed
      expect(response[:success]).to eql(false)
    end

    it 'does not end up with an error even if the target endpoint is DEAD (500 Error)' do 
      # stub the request and assume that the target server failed (status = 500)
      stub_request(:any, @hostname).to_return(:status => 500)
      client = Integration::CdpScraper::EtbScraper::new(@etb_username, @etb_password, @etb_endpoint)
      response = nil
      
      # the scraper should not fail even if the target server is dead
      expect { response = client.login }.not_to raise_error

      # the result JSON from the scraper should tell that the request has failed
      expect(response[:success]).to eql(false)
    end
  end

  context '#Create Test Orders: ' do 
    it "responds with correct JSON in case of creation failure" do 
      # stub the request and assume that the target server responds (status = 200)
      stub_request(:any, @hostname)
      
      # login to the target system
      client = Integration::CdpScraper::EtbScraper::new(@etb_username, @etb_password, @etb_endpoint)
      response = client.login  # failed

      expect { response = client.create_patient({ 'patient' => {} }) }.not_to raise_error

      # the result JSON from the scraper should tell that the request has failed
      expect(response[:success]).to eql(false)
    end

    it "terminates the request in case of wrong case-type submitted" do 
      # stub the request and assume that the target server responds (status = 200)
      stub_request(:any, @hostname)
      
      # login to the target system
      client = Integration::CdpScraper::EtbScraper::new(@etb_username, @etb_password, @etb_endpoint)
      response = client.login  # failed

      response = client.create_patient({ 'patient' => {} })
      expect(response[:error]).to match(/Invalid.*case_type.*/i)
    end

    it "should login and fail" do
      http_result = double('http_result')
      expect_any_instance_of(Integration::CdpScraper::EtbScraper).to receive(:get).at_least(:once).and_return(http_result)
      expect_any_instance_of(Integration::CdpScraper::EtbScraper).to receive(:post).at_least(:once).and_return(http_result)

      client = Integration::CdpScraper::EtbScraper::new(@etb_username, @etb_password, @etb_endpoint)
      
      allow(http_result).to receive_message_chain(:parser, :css, :empty?) { true }

      response = client.login  # failed
    end

    it "should create test order and fail in case of invalid parameters" do
      http_result = double('http_result')
      client = Integration::CdpScraper::EtbScraper::new(@etb_username, @etb_password, @etb_endpoint)
      allow(http_result).to receive_message_chain(:login) { true }

      response = client.create_test_order({'test_order' => {'type' => 'wrong'}})
    end

    it "should create Xpert test order and just works" do
      http_result = double('http_result')
      dom_elements = double('dom_elements')
      dom_attribute = double('dom_attribute')
      dom_element = double('dom_element', 'attributes' => {'name' => dom_attribute, 'value' => dom_attribute })
      
      allow(dom_attribute).to receive(:text).and_return('')
      allow(dom_attribute).to receive(:value).and_return('')
      allow(dom_element).to receive(:inner_html).and_return('')
      allow(http_result).to receive_message_chain(:parser, :css) { dom_elements }
      allow(http_result).to receive_message_chain(:search, :select, :first) { dom_element }
      allow(dom_elements).to receive(:[]) { dom_element }
      allow(dom_elements).to receive(:first).and_return(dom_element)
      allow(dom_elements).to receive(:last).and_return(dom_element)
      allow(dom_element).to receive_message_chain(:next_element, :next_element, :attributes) { {'name' => dom_attribute, 'value' => dom_attribute } }

      expect_any_instance_of(Integration::CdpScraper::EtbScraper).to receive(:get).at_least(:once).and_return(http_result)
      expect_any_instance_of(Integration::CdpScraper::EtbScraper).to receive(:post).at_least(:once).and_return(http_result)

      client = Integration::CdpScraper::EtbScraper::new(@etb_username, @etb_password, @etb_endpoint)
      
      test_order_json = {
        'test_order' => {
          'type' => 'xpert',
          'patient_etb_id' => 'any',
          'sample_collected_date' => 'any',
          'laboratory_region' => 'any',
          'laboratory_name' => 'any',
          'result' => '1'
      }}

      response = client.create_test_order(test_order_json)
    end

    it "should create Microscopy test order and just works" do
      http_result = double('http_result')
      dom_elements = double('dom_elements')
      dom_attribute = double('dom_attribute')
      dom_element = double('dom_element', 'attributes' => {'name' => dom_attribute, 'value' => dom_attribute })
      
      allow(dom_attribute).to receive(:text).and_return('')
      allow(dom_attribute).to receive(:value).and_return('')
      allow(dom_element).to receive(:inner_html).and_return('')
      allow(http_result).to receive_message_chain(:parser, :css) { dom_elements }
      allow(http_result).to receive_message_chain(:search, :select, :first) { dom_element }
      allow(dom_elements).to receive(:[]) { dom_element }
      allow(dom_elements).to receive(:first).and_return(dom_element)
      allow(dom_elements).to receive(:last).and_return(dom_element)
      allow(dom_element).to receive_message_chain(:next_element, :next_element, :attributes) { {'name' => dom_attribute, 'value' => dom_attribute } }

      expect_any_instance_of(Integration::CdpScraper::EtbScraper).to receive(:get).at_least(:once).and_return(http_result)
      expect_any_instance_of(Integration::CdpScraper::EtbScraper).to receive(:post).at_least(:once).and_return(http_result)

      client = Integration::CdpScraper::EtbScraper::new(@etb_username, @etb_password, @etb_endpoint)
      
      test_order_json = {
        'test_order' => {
          'type' => 'microscopy',
          'patient_etb_id' => 'any',
          'sample_collected_date' => 'any',
          'laboratory_region' => 'any',
          'laboratory_name' => 'any',
          'result' => 'NEGATIVE'
      }}

      response = client.create_test_order(test_order_json)
    end
  end
end