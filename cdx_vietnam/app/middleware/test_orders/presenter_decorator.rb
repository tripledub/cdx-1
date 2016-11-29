module TestOrders
  # CdxVietnam extension that handles the presentation of a test order
  class Presenter
    class << self
      alias_method :core_fetch_rows, :fetch_rows

      def fetch_rows(encounters)
        core_fetch_rows(encounters).each do |encounter|
          encounter.delete(:dueDate)
        end
      end
    end
  end
end
