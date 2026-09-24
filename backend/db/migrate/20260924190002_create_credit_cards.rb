class CreateCreditCards < ActiveRecord::Migration[8.1]
  def change
    create_table :credit_cards do |t|
      t.string :name, null: false
      t.string :issuer, null: false
      t.string :network
      t.integer :annual_fee_cents, null: false, default: 0
      t.references :reward_currency, null: false, foreign_key: true
      t.decimal :base_earn_rate, precision: 6, scale: 4, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.text :notes

      t.timestamps
    end

    add_index :credit_cards, :issuer
  end
end
