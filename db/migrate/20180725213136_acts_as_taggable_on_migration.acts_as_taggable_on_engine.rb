# This migration comes from acts_as_taggable_on_engine (originally 1)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class ActsAsTaggableOnMigration < ActiveRecord::Migration[4.2]; end
else
  class ActsAsTaggableOnMigration < ActiveRecord::Migration; end
end
ActsAsTaggableOnMigration.class_eval do
  # rubocop:disable MethodLength
  def self.up
    create_table :tags do |t|
      t.string :name, null: false, options: 'varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;'
      t.timestamps null: false
    end

    create_table :taggings do |t|
      t.references :tag, null: false

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, polymorphic: true, null: false
      t.references :tagger, polymorphic: true, null: true # allow null, because we don't have explicit users yet

      # Limit is created to prevent MySQL error on index
      # length for MyISAM table type: http://bit.ly/vgW2Ql
      t.string :context, limit: 128, null: false

      t.datetime :created_at, null: false
    end

    add_index :taggings, :tag_id
    add_index :taggings, %i[taggable_id taggable_type context]
  end
  # rubocop:enable MethodLength

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
