module TestOrders
  # CdxVietnam extention that handles the presentation of a test order
  class Presenter
    class << self
      alias_method :core_index_view, :index_view

      def index_view(encounters)
        core_index_view(encounters).each do |encounter|
          encounter.delete(:dueDate)
        end
      end
    end
  end
end
