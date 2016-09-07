class Extras::Dates::Filters
  class << self
    def date_options_for_filter
      [
        {
          label: I18n.t('extras.dates.filters.previous_week'),
          value: 1.week.ago.strftime('%Y-%m-%d')
        },
        {
          label: I18n.t('extras.dates.filters.previous_month'),
          value: 1.month.ago.strftime('%Y-%m-%d')
        },
        {
          label: I18n.t('extras.dates.filters.previous_quarter'),

          value: 3.months.ago.strftime('%Y-%m-%d')
        },
        {
          label: I18n.t('extras.dates.filters.previous_year'),
          value: 1.year.ago.strftime('%Y-%m-%d')
        }
      ]
    end
  end
end
