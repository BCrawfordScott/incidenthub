class ChangeUsersPrimaryKeyToUuid < ActiveRecord::Migration[7.2]
  def change
    execute "ALTER TABLE users DROP CONSTRAINT users_pkey;"

    remove_column :users, :id

    add_column :users, :id, :uuid, default: "gen_random_uuid()", null: false

    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
  end
end
