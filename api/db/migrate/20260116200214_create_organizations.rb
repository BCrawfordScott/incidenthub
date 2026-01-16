class CreateOrganizations < ActiveRecord::Migration[7.2]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      t.integer :status, default: 0, null: false
      t.string :billing_email
      t.jsonb :billing_metadata, null: false, default: {}

      t.timestamps
    end

    add_check_constraint :organizations, "status IN (0, 1)", name: "organizations_status_check"
    add_index :organizations, :name
  end
end
