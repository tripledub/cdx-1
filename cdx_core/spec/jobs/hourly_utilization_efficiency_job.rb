require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

describe HourlyUtilizationEfficiencyJob, elasticsearch: true do
  let(:user) {User.make}
  let(:institution) {Institution.make user_id: user.id}
  let(:worker) { HourlyUtilizationEfficiencyJob.new }

  context "end to end alert Utilization Efficiency test" do
    before(:example) do
      @alert = Alert.make
      @alert.user = institution.user
      @alert.category_type = "utilization_efficiency"
      @alert.aggregation_type = Alert.aggregation_types.key(1)
      @alert.aggregation_frequency = Alert.aggregation_frequencies.key(0)
      @alert.sample_id = "12345"
      @alert.utilization_efficiency_number = 1
      @alert.aggregation_threshold = 4
      @alert.query = {"sample.id"=>"12345"}
      @alert.utilization_efficiency_last_checked = Time.now
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

    let(:parent_location) {Location.make}
    let(:leaf_location1) {Location.make parent: parent_location}
    let(:upper_leaf_location) {Location.make}

    let(:site1) {Site.make institution: institution, location_geoid: leaf_location1.id}

    it "utilization_efficiency inject a test result once" do
      before_test_history_count = AlertHistory.count
      before_test_recipient_count=RecipientNotificationHistory.count
      @alert.create_percolator

      Timecop.freeze(Time.now + 1.day)
      device1 = Device.make institution: institution, site: site1
      DeviceMessage.create_and_process device: device1, plain_text_data: (Oj.dump test:{assays:[result: :negative]}, sample: {id: '12345'}, patient: {id: 'a',gender: :male})
      worker.perform
      after_test_history_count = AlertHistory.count
      after_test_recipient_count= RecipientNotificationHistory.count

      expect(before_test_history_count+2).to eq(after_test_history_count)
      expect(before_test_recipient_count+1).to eq(after_test_recipient_count)
    end

  end

end
