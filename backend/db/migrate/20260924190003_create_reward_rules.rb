class CreateRewardRules < ActiveRecord::Migration[8.1]
  def change
    create_table :reward_rules do |t|
      t.references :credit_card, null: false, foreign_key: true, index: false
      t.string :category, null: false
      t.decimal :earning_rate, precision: 6, scale: 4, null: false
      t.integer :spend_cap_cents
      t.date :effective_from, null: false
      t.date :effective_to
      t.text :notes

      t.timestamps
    end

    add_index :reward_rules, [ :credit_card_id, :category, :effective_from ],
              name: "index_reward_rules_on_card_category_effective_from"
  end
end
