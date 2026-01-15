class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.citext :email, null: false
      t.string :password_digest, null: false
      t.integer :status, default: 0, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_check_constraint :users, "status IN (0, 1)", name: "users_status_check"
  end
end
