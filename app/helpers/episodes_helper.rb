module EpisodesHelper
  def outcome_options
    opts = Episode.treatment_outcome_options.inject([]) do |arr, obj|
      arr << obj.marshal_dump
    end
    opts.unshift id: '', name: I18n.t('select.default')
  end
end
