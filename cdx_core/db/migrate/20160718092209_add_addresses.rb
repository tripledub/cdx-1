class AddAddresses < ActiveRecord::Migration
  def up
    create_table :addresses do |t|
      t.string  :uuid
      t.integer :addressable_id
      t.string  :addressable_type
      t.string  :address
      t.string  :zip_code
      t.string  :city
      t.string  :state
      t.timestamps
    end

    add_index :addresses, [ :addressable_id, :addressable_type]

    # Migrate current addresses to new table
    Patient.all.each do |patient|
      if show_full_address(patient).present?
        patient.addresses.create(
          address:  patient.address,
          zip_code: patient.zip_code,
          city:     patient.city,
          state:    patient.state
        )
      end
    end
  end

  def down
    drop_table :addresses
  end

  protected

  def show_full_address(patient)
    address = []
    address << patient.address
    address << patient.city
    address << patient.state
    address << patient.zip_code
    address.reject(&:blank?).join(', ')
  end
end
