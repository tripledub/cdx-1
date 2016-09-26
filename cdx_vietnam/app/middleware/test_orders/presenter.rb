module TestOrders
  class Presenter
    include Concerns::TestOrders::Presenter

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
