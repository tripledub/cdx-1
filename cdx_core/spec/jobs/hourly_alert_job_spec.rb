require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!


describe HourlyAlertJob, elasticsearch: true do
  let(:user) {User.make}
  let(:institution) {Institution.make user_id: user.id}
  let(:worker) { HourlyAlertJob.new }

  context "end to end alert aggregation test" do
    before(:example) do
      @alert = Alert.make
      @alert.user = institution.user
      @alert.category_type == "device_errors"
      @alert.aggregation_type = Alert.aggregation_types.key(1)
      @alert.aggregation_frequency = Alert.aggregation_frequencies.key(0)
      @alert.aggregation_threshold = 99
      @alert.email_limit=1000
      @alert.query = {"test.error_code"=>"155"}
      alert_recipient = AlertRecipient.new
      alert_recipient.recipient_type = AlertRecipient.recipient_types["internal_user"]
      alert_recipient.user = user
      alert_recipient.alert=@alert
      alert_recipient.save
      @alert.save
    end

    after(:example) do
      @alert.destroy
    end

    let(:site1) {Site.make institution: institution }

    it "for error code category inject an error code" do
      before_test_history_count = AlertHistory.count
      before_test_recipient_count=RecipientNotificationHistory.count

      @alert.create_percolator

      device1 = Device.make institution: institution, site: site1
      DeviceMessage.create_and_process device: device1, plain_text_data: (Oj.dump test:{assays:[result: :negative], error_code: 155}, sample: {id: 'a'}, patient: {id: 'a',gender: :male})
      worker.perform

      after_test_history_count = AlertHistory.count
      after_test_recipient_count= RecipientNotificationHistory.count

      expect(before_test_history_count+2).to eq(after_test_history_count)
      expect(before_test_recipient_count+1).to eq(after_test_recipient_count)
    end

    it "test result with different error code does not trigger alert filter" do
      before_test_history_count = AlertHistory.count
      before_test_recipient_count=RecipientNotificationHistory.count

      @alert.create_percolator

      device1 = Device.make institution: institution, site: site1
      DeviceMessage.create_and_process device: device1, plain_text_data: (Oj.dump test:{assays:[result: :negative], error_code: 888}, sample: {id: 'a'}, patient: {id: 'a',gender: :male})
      worker.perform

      after_test_history_count = AlertHistory.count
      after_test_recipient_count= RecipientNotificationHistory.count

      expect(before_test_history_count).to eq(after_test_history_count)
      expect(before_test_recipient_count).to eq(after_test_recipient_count)
    end


    it "check non-repeat logic for when same smaple id but different event-id that multiple alert triggers are not generated" do
      before_test_history_count = AlertHistory.count
      before_test_recipient_count=RecipientNotificationHistory.count

      @alert.create_percolator

      device1 = Device.make institution: institution, site: site1
      DeviceMessage.create_and_process device: device1, plain_text_data: (Oj.dump test:{assays:[result: :negative], error_code: 155}, sample: {id: 'aa',entity_id: "111"}, patient: {id: 'a',gender: :male})
      DeviceMessage.create_and_process device: device1, plain_text_data: (Oj.dump test:{assays:[result: :negative], error_code: 155}, sample: {id: 'aa',entity_id: "112"}, patient: {id: 'a',gender: :male})

      worker.perform

      after_test_history_count = AlertHistory.count
      after_test_recipient_count= RecipientNotificationHistory.count

      expect(before_test_history_count+3).to eq(after_test_history_count)
      expect(before_test_recipient_count+1).to eq(after_test_recipient_count)
    end


  end
end
