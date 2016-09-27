module Reports
  class Base
    def self.process(*args)
      new(*args).process
    end

    attr_reader :current_user, :context, :data, :date_results, :end_date
    attr_reader :filter, :options, :results, :start_date

    def initialize(current_user, context, options = {})
      @filter ||= { 'group_by' => 'day(test.start_time)' }
      @current_user = current_user
      @context = context
      @data = []
      @options = options
      setup
    end

    def process
      @results = TestResult.query(filter, current_user).execute
      self
    end

    def sort_by_day
      nod = number_of_days - 1
      nod.downto(0).each do |i|
        day = Date.parse(end_date) - i.days
        key = day.strftime('%Y-%m-%d')
        data << data_hash_day(day, day_results('%Y-%m-%d', key))
      end
      self
    end

    def sort_by_hour(cnt = 23)
      hour_results = results_by_period('%H')
      cnt.downto(0) do |i|
        now = (Time.now - i.hours)
        hourname = now.strftime('%H')
        data << {
          label: hourname,
          values: [hour_results ? hour_results[hourname].count : 0]
        }
      end
      data
    end

    def sort_by_month
      nom = number_of_months.abs - 1
      nom.downto(0).each do |i|
        date = Date.parse(end_date) - i.months
        date_key = date.strftime('%Y-%m')
        data << data_hash_month(date, month_results(date_key))
      end
      self
    end

    def start_date
      return options['date_range']['start_time']['gte'] if valid_start_date?
      return options['since'] if options['since']
      report_since
    end

    def end_date
      return options['date_range']['start_time']['lte'] if valid_end_date?
      Date.today.iso8601
    end

    def number_of_days
      Date.parse(end_date).jd - Date.parse(start_date).jd
    end

    def number_of_months
      sd = Date.parse(start_date)
      ed = Date.parse(end_date)
      (ed.year * 12 + ed.month) - (sd.year * 12 + sd.month)
    end

    private

    def count_total(results)
      results.inject(0) { |a, e| a + e['count'] }
    end

    def data_hash_day(dayname, day_results)
      {
        label: label_daily(dayname),
        values: [day_results ? day_results.count : 0]
      }
    end

    def data_hash_month(date, date_results)
      {
        label: label_monthly(date),
        values: [date_results ? count_total(date_results) : 0]
      }
    end

    def day_or_month
      number_of_days > 60 ? 'month' : 'day'
    end

    def date_constraints
      valid_date_range? ? report_between : report_since
    end

    def valid_date_range?
      valid_start_date? && valid_end_date?
    end

    def valid_start_date?
      options['date_range'] && options['date_range']['start_time']['gte'].present?
    end

    def valid_end_date?
      options['date_range'] && options['date_range']['start_time']['lte'].present?
    end

    def day_results(format, key)
      results_by_period(format)[key]
    end

    def label_daily(day)
      day.strftime('%d/%m')
    end

    def label_monthly(date)
      "#{I18n.t('date.abbr_month_names')[date.month]}#{date.month == 1 ? " #{date.strftime('%y')}" : ''}"
    end

    def lookup_device(uuid)
      device = ::Device.where(uuid: uuid).first
      return device.name if device
    end

    def month_results(period)
      results_by_period('%Y-%m')[period]
    end

    def report_between
      filter['since'] = options['date_range']['start_time']['gte']
      filter['until'] = options['date_range']['start_time']['lte']
    end

    def report_since
      filter['since'] = options['since'] || (Date.today - 7.days).iso8601
    end

    def results_by_period(format = '%Y-%m')
      results['tests'].group_by do |t|
        Date.parse(t['test.start_time']).strftime(format)
      end
    end

    def setup
      site_or_institution
      date_constraints
      ignore_qc
      filter_by_device
    end

    def site_or_institution
      filter['institution.uuid'] = context.institution.uuid if context.institution
      filter['site.uuid'] = context.site.uuid if context.site && context.exclude_subsites
      filter['site.path'] = context.site.uuid if context.site && !context.exclude_subsites
      filter.delete('site.uuid') if context.exclude_subsites && !context.site
    end

    def filter_by_device
      filter['device.uuid'] = options[:device] if options[:device]
    end

    def ignore_qc
      # TODO post mvp: should generate list of all types but qc, or support query by !=
      filter['test.type'] = 'specimen'
    end

    def users
      results['tests'].index_by { |t| t['test.site_user'] }.keys
    end

    def slice_colors
      ["#21C334", "#C90D0D", "#aaaaaa", "#00A8AB", "#B7D6B7", "#D8B49C", "#DE6023", "#47B04B", "#009788", "#A05D56", "#D0743C", "#FF8C00"]
    end

    def get_manual_results_query(filter)
      since_day    = filter['since'] + ' 00:00'
      until_day    = (filter['until'] || Date.today.strftime("%Y-%m-%d")) + ' 23:59'
      manual_query = PatientResult.where('patient_results.type != "TestResult"')
        .joins('LEFT OUTER JOIN encounters ON encounters.id = patient_results.encounter_id')
        .joins('LEFT OUTER JOIN institutions ON institutions.id = encounters.institution_id')
        .joins('INNER JOIN sites ON sites.id = encounters.site_id')
        .where('sites.deleted_at IS NULL')
      manual_query.where({ 'institutions.uuid'          => filter['institution.uuid'] }) if filter['institution.uuid']
      manual_query.where({ 'sites.uuid'                 => filter['site.uuid'] })        if filter['site.uuid']
      manual_query.where({ 'patient_results.created_at' => since_day..until_day })
    end
  end
end
