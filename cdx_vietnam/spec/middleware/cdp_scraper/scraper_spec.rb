require 'spec_helper'

describe Integration::CdpScraper::EtbScraper do
  before do 
    @etb_username = Settings.etb_username
    @etb_endpoint = Settings.etb_endpoint
    @etb_password = Settings.etb_password
    # extract the hostname from URL
    # @hostname = @etb_endpoint[/http[a]*.\/\/[^\/:]*/][/[^\/]*$/]
    @hostname = /etbmanager/
  end

  context '#login' do
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

  context '#create_patient' do 
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
  end
end