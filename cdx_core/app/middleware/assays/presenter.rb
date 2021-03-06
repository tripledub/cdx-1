module Assays
  # Presenter for assays
  class Presenter
    class << self
      def all_results(test_result)
        test_result.assay_results.map do |assay|
          assay.condition + ' ' + I18n.t('select.test_results.result_type.' + assay.result)
        end.join(' / ')
      end
    end
  end
end
