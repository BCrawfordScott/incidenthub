class CreateMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.integer :role, default: 2, null: false

      t.timestamps
    end

    add_index :memberships, [:user_id, :organization_id], unique: true
    add_check_constraint :memberships, "role IN (0, 1, 2, 3)", name: "memberships_role_check"
  end
end
