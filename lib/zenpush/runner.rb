# encoding: UTF-8
require 'boson/runner'
require 'ap'

module ZenPush
  class Runner < Boson::Runner

    desc 'List categories'
    def categories(options = {})
      ap ZenPush.z.categories
    end

    desc 'List forums'
    def forums(options = {})
      ap ZenPush.z.forums
    end

    option :forum_id, :type => :numeric
    desc 'List entries'
    def entries(options = {})
      ap ZenPush.z.entries(options[:forum_id])
    end

    desc 'Does the entry matching the given file exist ?'
    option :file, :type => :string
    def exists?(options = {})
      category_name, forum_name, entry_title = ZenPush.file_to_category_forum_entry(options[:file])
      entry = ZenPush.z.find_entry(category_name, forum_name, entry_title)
      ap !!entry
    end

    desc 'Create or update an entry from the given file'
    option :file, :type => :string
    def push(options = {})
      category_name, forum_name, entry_title = ZenPush.file_to_category_forum_entry(options[:file])

      entry_body = ZenPush::Markdown.to_zendesk_html(options[:file])

      entry = ZenPush.z.find_entry(category_name, forum_name, entry_title)
      if entry
        # UPDATE THE ENTRY
        ap ZenPush.z.put_entry(entry['id'], entry_body)
      else
        forum = ZenPush.z.find_forum(category_name, forum_name)
        if forum
          # CREATE THE ENTRY
          ap ZenPush.z.post_entry(forum['id'], entry_title, entry_body)
        else
          ap "Could not find a forum named '#{forum_name}' in the category '#{category_name}'"
          exit(-1)
        end
      end
    end
  end
end