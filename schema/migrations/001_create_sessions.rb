class CreateSessions < Sequel::Migration

  def up
    create_table :sessions do
      primary_key :id
      varchar     :session_id, :size => 64, :unique => true
      timestamp   :created_at
      text        :data
    end
  end

  def down
    execute "DROP TABLE sessions"
  end
  
end


