class Extras::Dates::Filters
  class << self
    def date_options_for_filter
      [
        { label: I18n.t('extras.dates.filters.previous_week'),  value: 1.week.ago.beginning_of_week },
        { label: I18n.t('extras.dates.filters.previous_month'), value: 1.month.ago.beginning_of_month },
        { label: I18n.t('extras.dates.filters.previous_year'),  value: 1.year.ago.beginning_of_year }
      ]
    end
  end
end
