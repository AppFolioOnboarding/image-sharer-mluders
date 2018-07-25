# This migration comes from acts_as_taggable_on_engine (originally 6)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddMissingIndexesOnTaggings < ActiveRecord::Migration[4.2]; end
else
  class AddMissingIndexesOnTaggings < ActiveRecord::Migration; end
end
AddMissingIndexesOnTaggings.class_eval do
  # rubocop:disable AbcSize, CyclomaticComplexity, MethodLength
  # rubocop:disable PerceivedComplexity, IfUnlessModifier, GuardClause
  def change
    add_index :taggings, :tag_id unless index_exists? :taggings, :tag_id, null: false
    add_index :taggings, :taggable_id unless index_exists? :taggings, :taggable_id, null: false
    add_index :taggings, :taggable_type unless index_exists? :taggings, :taggable_type, null: false
    add_index :taggings, :tagger_id unless index_exists? :taggings, :tagger_id, null: false
    add_index :taggings, :context unless index_exists? :taggings, :context

    unless index_exists? :taggings, %i[tagger_id tagger_type]
      add_index :taggings, %i[tagger_id tagger_type]
    end

    unless index_exists? :taggings, %i[taggable_id taggable_type tagger_id context], name: 'taggings_idy'
      add_index :taggings, %i[taggable_id taggable_type tagger_id context], name: 'taggings_idy'
    end
  end
  # rubocop:enable AbcSize, CyclomaticComplexity, MethodLength
  # rubocop:enable PerceivedComplexity, IfUnlessModifier, GuardClause
end
