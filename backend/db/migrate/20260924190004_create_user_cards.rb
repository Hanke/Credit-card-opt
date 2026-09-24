class CreateUserCards < ActiveRecord::Migration[8.1]
  def change
    create_table :user_cards do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :credit_card, null: false, foreign_key: true
      t.datetime :added_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end

    add_index :user_cards, [ :user_id, :credit_card_id ], unique: true
  end
end
