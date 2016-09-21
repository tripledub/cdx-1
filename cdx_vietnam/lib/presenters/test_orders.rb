class Presenters::TestOrders
  include Presenters::Concerns::TestOrders

  class << self
    alias_method :core_index_view, :index_view

    def index_view(encounters)
      core_index_view(encounters).each do |encounter|
        encounter.delete(:dueDate)
      end
    end
  end
end
