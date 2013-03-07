# encoding: UTF-8
require 'json'
require 'yaml'
require 'httparty'

module ZenPush
  class Zendesk
    include HTTParty

    attr_accessor :options

    headers 'Content-Type' => 'application/json'
    # debug_output

    def initialize(options = {})

      default_options = {
        :uri => nil,
        :user => nil,
        :password => nil,
        :filenames_use_dashes_instead_of_spaces => false,
      }

      zenpush_yml = File.join(ENV['HOME'], '.zenpush.yml')

      if File.readable?(zenpush_yml)
        zenpush_yml_opts = YAML.load_file(zenpush_yml)
        default_options.merge!(zenpush_yml_opts)
      end

      opts = default_options.merge!(options)
      opts.each_pair { |k,v| raise "#{k} is nil" if v.nil? }

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

    def topics(forum_id, options = { })
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
    def find_or_create_category(category_name, options={ })
      find_category(category_name, options) || begin
        post_category(category_name, options={ })
      end
    end

    # Find forum by name, knowing the category name
    def find_forum(category_name, forum_name, options = {})
      category = self.find_category(category_name, options)
      if category
        self.forums.detect {|f| f['name'] == forum_name}
      end
    end

    # Given a category name, find a forum by name. Create the category and forum either doesn't exist.
    def find_or_create_forum(category_name, forum_name, options={ })
      category = self.find_or_create_category(category_name, options)
      if category
        self.forums.detect { |f| f['name'] == forum_name } || post_forum(category['id'], forum_name)
      end
    end

    # Find topic by name, knowing the forum name and category name
    def find_topic(category_name, forum_name, topic_title, options = {})
      forum = self.find_forum(category_name, forum_name, options)
      if forum
        self.topics(forum['id'], options).detect {|t| t['title'] == topic_title}
      end
    end

    # Create a category with a given name
    def post_category(category_name, options={ })
      self.post('/categories.json',
                options.merge(
                  :body => { :category => {
                    :name => category_name
                  } }.to_json
                )
      )['category']
    end

    # Create a forum in the given category id
    def post_forum(category_id, forum_name, options={ })
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
    def post_topic(forum_id, title, body, options = { })
      self.post("/topics.json",
                options.merge(
                  :body => { :topic => {
                    :forum_id => forum_id, :title => title, :body => body
                  } }.to_json
                )
      )['topic']
    end

    # Update a topic in the given forum id
    def put_topic(id, body, options = { })
      self.put("/topics/#{id}.json",
               options.merge(
                 :body => { :topic => { :body => body } }.to_json
               )
      )['topic']
    end

  end
end
