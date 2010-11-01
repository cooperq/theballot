class FeaturedGuides < ActiveRecord::Migration
  def self.up
    add_column :guides, :featured, :boolean, :default => false
  end

  def self.down
    remove_column :guides, :featured
  end
end
