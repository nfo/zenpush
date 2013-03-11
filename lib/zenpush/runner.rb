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
    desc 'List topics'
    def topics(options = {})
      ap ZenPush.z.topics(options[:forum_id])
    end

    desc 'Does the topic matching the given file exist?'
    option :file, :type => :string
    def exists?(options = {})
      category_name, forum_name, topic_title = ZenPush.file_to_category_forum_topic(options[:file])
      topic = ZenPush.z.find_topic(category_name, forum_name, topic_title)
      ap !!topic
    end

    desc 'Create or update a topic from the given file'
    option :file, :type => :string
    option :flavor, :type => :string
    def push(options = {})
      category_name, forum_name, topic_title = ZenPush.file_to_category_forum_topic(options[:file])

      topic_body =
        if options[:file].end_with?('.md') || options[:file].end_with?('.markdown')
          ZenPush::Markdown.to_zendesk_html(options[:file], options[:flavor])
        else
          File.read(options[:file])
        end

      ZenPush.z.create_or_update_topic(category_name, forum_name, topic_title, topic_body, options)
    end
  end
end
