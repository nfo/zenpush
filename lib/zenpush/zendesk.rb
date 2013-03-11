# encoding: UTF-8
require 'json'
require 'yaml'
require 'httparty'
require 'persistent_httparty'
require 'nokogiri'

module ZenPush
  class Zendesk
    include HTTParty
    persistent_connection_adapter({ :idle_timeout => 30,
                                    :keep_alive   => 60 })

    attr_accessor :options

    headers 'Content-Type' => 'application/json'
    # debug_output

    def initialize(options = {})

      default_options = {
        :uri                                    => nil,
        :user                                   => nil,
        :password                               => nil,
        :filenames_use_dashes_instead_of_spaces => false,
      }

      zenpush_yml = File.join(ENV['HOME'], '.zenpush.yml')

      if File.readable?(zenpush_yml)
        zenpush_yml_opts = YAML.load_file(zenpush_yml)
        default_options.merge!(zenpush_yml_opts)
      end

      opts = default_options.merge!(options)
      opts.each_pair { |k, v| raise "#{k} is nil" if v.nil? }

      @options = opts

      self.class.base_uri opts[:uri] + '/api/v2'
      self.class.basic_auth opts[:user], opts[:password]
    end

    def get(uri, options = {})
      self.class.get(uri, options)
    end

    def post(uri, options = {})
      self.class.post(uri, options)
    end

    def put(uri, options = {})
      self.class.put(uri, options)
    end

    def delete(uri, options = {})
      self.class.delete(uri, options)
    end

    def categories(options = {})
      self.get('/categories.json', options).parsed_response['categories']
    end

    def category(category_id, options = {})
      self.get("/categories/#{category_id}.json", options).parsed_response
    end

    def forums(options = {})
      self.get('/forums.json', options).parsed_response['forums']
    end

    def forum(forum_id, options = {})
      self.get("/forums/#{forum_id}.json", options).parsed_response
    end

    def users(options = {})
      self.get('/users.json', options).parsed_response['users']
    end

    def topics(forum_id, options = {})
      self.get("/forums/#{forum_id}/topics.json", options).parsed_response['topics']
    end

    def topic(topic_id, options = {})
      self.get("/topics/#{topic_id}.json", options).parsed_response
    end

    # Find category by name
    def find_category(category_name, options = {})
      categories = self.categories
      if categories.is_a?(Array)
        categories.detect { |c| c['name'] == category_name }
      else
        raise "Could not retrieve categories: #{categories}"
      end
    end

    # Find category by name, creating it if it doesn't exist
    def find_or_create_category(category_name, options={})
      find_category(category_name, options) || begin
        post_category(category_name, options={})
      end
    end

    # Find forum by name, knowing the category name
    def find_forum(category_name, forum_name, options = {})
      category = self.find_category(category_name, options)
      if category
        self.forums.detect { |f| f['name'] == forum_name }
      end
    end

    # Given a category name, find a forum by name. Create the category and forum either doesn't exist.
    def find_or_create_forum(category_name, forum_name, options={})
      category = self.find_or_create_category(category_name, options)
      if category
        self.forums.detect { |f| f['name'] == forum_name } || post_forum(category['id'], forum_name)
      end
    end

    # Find topic by name, knowing the forum name and category name
    def find_topic(category_name, forum_name, topic_title, options = {})
      forum = self.find_forum(category_name, forum_name, options)
      if forum
        self.topics(forum['id'], options).detect { |t| t['title'] == topic_title }
      end
    end

    def create_or_update_topic(category_name, forum_name, topic_title, topic_body, options = {})
      topic = ZenPush.z.find_topic(category_name, forum_name, topic_title)
      if topic
        update_topic(topic, topic_body, options)
      else
        create_topic(category_name, forum_name, topic_title, topic_body, options)
      end
    end

    # Create topic by name, knowing the forum name and category name. Automatically uploads images.
    def create_topic(category_name, forum_name, topic_title, topic_body, options = {})
      forum = ZenPush.z.find_or_create_forum(category_name, forum_name)
      if forum
        topic_body = upload_images(topic_body)
        post_topic(forum['id'], topic_title, topic_body, options)
      else
        raise "Could not find a forum named '#{forum_name}' in the category '#{category_name}'"
      end
    end

    # Update topic by name, knowing the forum name and category name. Automatically uploads images.
    def update_topic(topic, topic_body, options = {})
      delete_images(topic['body'])
      topic_body = upload_images(topic_body)
      put_topic(topic['id'], topic_body, options)
    end

    # Upload all the attachments linked in the topic body
    def upload_images(topic_body)
      doc   = Nokogiri::HTML.fragment(topic_body)

      # Collect all relative links
      urls  = doc.css('img').collect do |img|
        img['src'] =~ /^http/i ? nil : img['src']
      end.compact.uniq

      # Upload files and replace link with Zendesk content URL
      token = nil
      urls.collect do |url|
        file = File.expand_path(File.join('.', URI.unescape(url)))
        if File.exists?(file)
          upload = post_upload(file, token)
          token  ||= upload['token']
          upload['attachments'].first.tap do |attachment|
            doc.css('img').each do |img|
              img['src'] = attachment['content_url'] if img['src'] == url
            end
          end
        else
          puts "Could not find #{url}. Skipping."
        end
      end.flatten

      # Append a comment to the topic HTML to keep track of the upload token
      if token
        doc.add_child("<span id=\"upload-token\" data-token=\"#{token}\"></span>")
        doc.to_html
      else
        doc.to_html
      end
    end

    # Delete uploaded content for a topic
    def delete_images(existing_topic_body)
      doc  = Nokogiri::HTML.fragment(existing_topic_body)
      span = doc.css('#upload-token').first
      delete_upload(span['data-token']) if span
    end

    # Create a category with a given name
    def post_category(category_name, options={})
      self.post('/categories.json',
                options.merge(
                  :body => { :category => {
                    :name => category_name
                  } }.to_json
                )
      )['category']
    end

    # Create a forum in the given category id
    def post_forum(category_id, forum_name, options={})
      self.post('/forums.json',
                options.merge(
                  :body => { :forum => {
                    :name        => forum_name,
                    :category_id => category_id
                  } }.to_json
                )
      )['forum']
    end

    # Create a topic in the given forum id
    def post_topic(forum_id, title, body, options = {})
      self.post("/topics.json",
                options.merge(
                  :body => { :topic => {
                    :forum_id => forum_id, :title => title, :body => body
                  } }.to_json
                )
      )['topic']
    end

    # Update a topic in the given forum id
    def put_topic(id, body, options = {})
      self.put("/topics/#{id}.json",
               options.merge(
                 :body => { :topic => { :body => body } }.to_json
               )
      )['topic']
    end

    # Add an attachment by creating an upload
    def post_upload(file, token = nil)
      contents = File.binread(file)
      self.post("/uploads.json?filename=#{File.basename(file)}#{"&token=#{token}" if token}",
                :body    => contents,
                :headers => { 'Content-Type' => 'application/binary' }
      ).parsed_response['upload']
    end

    # Delete an upload
    def delete_upload(token)
      self.delete("/uploads/#{token}.json") if token
    end

  end
end
