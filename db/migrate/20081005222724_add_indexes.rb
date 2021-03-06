class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index "assets_themes", ["asset_id"], :name => "index_on_asset_id"
    add_index "assets_themes", ["theme_id"], :name => "index_on_theme_id"
    add_index "attachments", ["parent_id"], :name => "index_on_parent_id"
    add_index "attachments", ["guide_id"], :name => "index_on_guide_id"
    add_index "attachments", ["user_id"], :name => "index_on_user_id"
    add_index "attachments", ["theme_id"], :name => "index_on_theme_id"
    add_index "choices", ["contest_id"], :name => "index_on_contest_id"
    add_index "contests", ["guide_id"], :name => "index_on_guide_id"
    add_index "endorsements", ["guide_id"], :name => "index_on_guide_id"
    add_index "guides", ["user_id"], :name => "index_on_user_id"
    add_index "guides", ["theme_id"], :name => "index_on_theme_id"
    add_index "links", ["guide_id"], :name => "index_on_guide_id"
    add_index "pledges", ["user_id"], :name => "index_on_user_id"
    add_index "pledges", ["guide_id"], :name => "index_on_guide_id"
    add_index "resources", ["parent_id"], :name => "index_on_parent_id"
    add_index "roles_users", ["role_id"], :name => "index_on_role_id"
    add_index "roles_users", ["user_id"], :name => "index_on_user_id"
    add_index "styles", ["author_id"], :name => "index_on_author_id"
    add_index "themes", ["style_id"], :name => "index_on_style_id"
    add_index "themes", ["author_id"], :name => "index_on_author_id"
    add_index "themes", ["print_style_id"], :name => "index_on_print_style_id"
  end

  def self.down
    remove_index "themes", :name => "index_on_print_style_id"
    remove_index "themes", :name => "index_on_author_id"
    remove_index "themes", :name => "index_on_style_id"
    remove_index "styles", :name => "index_on_author_id"
    remove_index "roles_users", :name => "index_on_user_id"
    remove_index "roles_users", :name => "index_on_role_id"
    remove_index "resources", :name => "index_on_parent_id"
    remove_index "pledges", :name => "index_on_guide_id"
    remove_index "pledges", :name => "index_on_user_id"
    remove_index "links", :name => "index_on_guide_id"
    remove_index "guides", :name => "index_on_theme_id"
    remove_index "guides", :name => "index_on_user_id"
    remove_index "endorsements", :name => "index_on_guide_id"
    remove_index "contests", :name => "index_on_guide_id"
    remove_index "choices", :name => "index_on_contest_id"
    remove_index "attachments", :name => "index_on_theme_id"
    remove_index "attachments", :name => "index_on_user_id"
    remove_index "attachments", :name => "index_on_guide_id"
    remove_index "attachments", :name => "index_on_parent_id"
    remove_index "assets_themes", :name => "index_on_theme_id"
    remove_index "assets_themes", :name => "index_on_asset_id"
  end
end
