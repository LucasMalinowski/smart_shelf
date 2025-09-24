# frozen_string_literal: true

class CreateFamilies < ActiveRecord::Migration[7.1]
  require "securerandom"

  class MigrationFamily < ActiveRecord::Base
    self.table_name = "families"
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    create_table :families do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :invite_code, null: false
      t.string :unit_system, null: false, default: "metric"
      t.timestamps
    end

    add_index :families, :slug, unique: true
    add_index :families, :invite_code, unique: true

    add_reference :users, :family, foreign_key: true

    create_table :family_invitations do |t|
      t.references :family, null: false, foreign_key: true
      t.string :email, null: false
      t.string :token, null: false
      t.integer :status, null: false, default: 0
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.datetime :expires_at
      t.timestamps
    end

    add_index :family_invitations, [:family_id, :email], unique: true
    add_index :family_invitations, :token, unique: true

    MigrationFamily.reset_column_information
    MigrationUser.reset_column_information

    MigrationUser.find_each do |user|
      base = user.email.split("@").first
      slug_base = base.parameterize
      slug = slug_base.presence || SecureRandom.hex(3)
      while MigrationFamily.exists?(slug: slug)
        slug = "#{slug_base}-#{SecureRandom.hex(2)}"
      end

      family = MigrationFamily.create!(
        name: "Família #{base.titleize}",
        slug: slug,
        invite_code: SecureRandom.hex(10)
      )

      user.update_columns(family_id: family.id)
    end

    change_column_null :users, :family_id, false
  end

  def down
    remove_reference :users, :family, foreign_key: true
    drop_table :family_invitations
    drop_table :families
  end
end
