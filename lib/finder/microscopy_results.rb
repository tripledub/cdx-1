class Finder::MicroscopyResults < Finder::ManualResults
  def results_class
    ::MicroscopyResult
  end
end
