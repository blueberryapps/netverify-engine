class CreateNetverifyValidations < ActiveRecord::Migration
  def change
    create_table :netverify_validations do |t|
      t.integer :validatable_id
      t.string :validatable_type
      t.string :state
      t.string :jumio_id_scan_reference
      t.string :merchant_id_scan_reference
      t.hstore :personal_information
      t.hstore :error_types
      t.hstore :images

      t.timestamps
    end
  end
end
