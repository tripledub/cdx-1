module EpisodesHelper
  def outcome_options
    Episode.treatment_outcome_options.inject([]) do |arr, obj|
      arr << obj.marshal_dump
    end
  end
end
