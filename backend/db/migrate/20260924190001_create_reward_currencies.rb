class CreateRewardCurrencies < ActiveRecord::Migration[8.1]
  def change
    create_table :reward_currencies do |t|
      t.citext :name, null: false
      t.decimal :cents_per_point, precision: 8, scale: 4, null: false,
                comment: "Value of one point in cents: 1.0 = 1 cent/point, Aeroplan 1.5, PC Optimum 0.1. " \
                         "value_cents = points * cents_per_point."
      t.text :description

      t.timestamps
    end

    add_index :reward_currencies, :name, unique: true
  end
end
