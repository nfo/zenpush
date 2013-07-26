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

    desc 'Create or update a topic from the given file and upload attachments if present'
    option :file, :type => :string
    option :flavor, :type => :string
    def push(options = {})
      category_name, forum_name, topic_title, attachments_folder = ZenPush.file_to_category_forum_topic(options[:file])

      topic_body =
        if options[:file].end_with?('.md') || options[:file].end_with?('.markdown')
          ZenPush::Markdown.to_zendesk_html(options[:file], options[:flavor])
        else
          File.read(options[:file])
        end

      topic_title = topic_title.split.each{|i| i.capitalize!}.join(' ')  
      topic = ZenPush.z.find_topic(category_name, forum_name, topic_title)
      if topic
        # UPDATE THE TOPIC
        topic = ZenPush.z.put_topic(topic['id'], topic_body)
      else
        forum = ZenPush.z.find_or_create_forum(category_name, forum_name)
        if forum
          # CREATE THE TOPIC
          topic = ZenPush.z.post_topic(forum['id'], topic_title, topic_body)
        else
          ap "Could not find a forum named '#{forum_name}'" +  (ZenPush.z.options[:account_type]=="starter" ? "." : " in the category '#{category_name}'.")
          exit(-1)
        end
      end
      # If there is an attachments folder, upload and associate all the files in that folder.
      if attachments_folder && File.directory?(attachments_folder)
        # Ignore folders including . and ..
        upload_files = Dir.entries(attachments_folder).select{ |f| !File.directory? f }
        current_attachment_ids_to_remove = topic['attachments'].select{|a| upload_files.include? a['file_name'] }.collect{|a| a['id']}
        current_attachment_ids_to_remove.each{ |ca| ZenPush.z.delete_attachment(ca) }
        tokens = upload_files.collect{ |uf| ZenPush.z.post_upload(File.basename(uf), attachments_folder+"/"+uf) }
        topic = ZenPush.z.put_topic_tokens(topic['id'], tokens)
      end
      ap topic
    end
  end
end
