module TestOrders
  # Export Test Orders to CSV customisation for Vietnam
  class ListCsv
    def generate
      CSV.generate(force_quotes: true) do |csv|
        csv << [
          Encounter.human_attribute_name(:batch_id),
          Encounter.human_attribute_name(:site_id),
          Encounter.human_attribute_name(:performing_site_id),
          Encounter.human_attribute_name(:sample_id),
          Encounter.human_attribute_name(:testing_for),
          Encounter.human_attribute_name(:user_id),
          Encounter.human_attribute_name(:start_time),
          Encounter.human_attribute_name(:status)
        ]
        @test_orders.map { |test_order| add_csv_row(csv, test_order) }
      end
    end

    protected

    def add_csv_row(csv, test_order)
      csv << [
        test_order.batch_id,
        Sites::Presenter.site_name(test_order.site),
        Sites::Presenter.site_name(test_order.performing_site),
        SampleIdentifiers::Presenter.for_encounter(test_order),
        test_order.testing_for,
        test_order.user.full_name,
        Extras::Dates::Format.datetime_with_time_zone(test_order.start_time, :full_time),
        TestOrders::Presenter.generate_status(test_order)
      ]
    end
  end
end
