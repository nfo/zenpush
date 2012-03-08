# encoding: UTF-8
require 'zenpush/runner'
require 'zenpush/zendesk'
require 'zenpush/markdown'

module ZenPush
  extend self

  # Zendesk API
  def z
    @z ||= ZenPush::Zendesk.new
  end

  # 
  def file_to_category_forum_entry(file)
    absolute_path = File.realpath(file)
    parts = absolute_path.split('/')
    entry_name = File.basename(absolute_path, '.md') # TODO support .markdown and make it case insensitive
    forum_name = parts[-2]
    category_name = parts[-3]
    return category_name, forum_name, entry_name
  end
end