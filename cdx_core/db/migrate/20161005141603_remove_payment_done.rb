# Remove payment_done not used anymore
class RemovePaymentDone < ActiveRecord::Migration
  def change
    remove_column :encounters, :payment_done
  end
end
