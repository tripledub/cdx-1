module TestOrders
  class Status
    class << self
      def change_status(encounter)
        encounter.update_attribute(:status, 'pending') if order_is_pending?(encounter.test_batch)
      end

      protected

      def order_is_pending?(test_batch)
        test_batch.payment_done == true && test_batch.status == 'samples_collected'
      end
    end
  end
end
