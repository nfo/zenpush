# encoding: UTF-8
require 'json'
require 'yaml'
require 'httparty'

module ZenPush
  class Zendesk
    include HTTParty

    headers 'Content-Type' => 'application/json'
    # debug_output

    def initialize(b = nil, u = nil, p = nil)
      if b.nil? || u.nil? || p.nil?
        creds = YAML.load_file(File.join(ENV['HOME'], '.zenpush.yml'))
        b ||= creds['uri']
        u ||= creds['user']
        p ||= creds['password']
      end

      self.class.base_uri b + '/api/v1'
      self.class.basic_auth u, p
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
      self.get('/categories.json', options).parsed_response
    end

    def category(category_id, options = {})
      self.get("/categories/#{category_id}.json", options).parsed_response
    end

    def forums(options = {})
      self.get('/forums.json', options).parsed_response
    end

    def forum(forum_id, options = {})
      self.get("/forums/#{forum_id}.json", options).parsed_response
    end

    def users(options = {})
      self.get('/users.json', options).parsed_response
    end

    def entries(forum_id, options = {})
      self.get("/forums/#{forum_id}/entries.json", options).parsed_response
    end

    def entry(entry_id, options = {})
      self.get("/entries/#{entry_id}.json", options).parsed_response
    end

    # Find category by name
    def find_category(category_name, options = {})
      self.categories.detect {|c| c['name'] == category_name}
    end

    # Find forum by name, knowing the category name
    def find_forum(category_name, forum_name, options = {})
      category = self.find_category(category_name, options)
      if category
        self.forums.detect {|f| f['name'] == forum_name}
      end
    end

    # Find entry by name, knowing the forum name and category name
    def find_entry(category_name, forum_name, entry_title, options = {})
      forum = self.find_forum(category_name, forum_name, options)
      if forum
        self.entries(forum['id'], options).detect {|e| e['title'] == entry_title}
      end
    end

    # Create an entry in the given forum id
    def post_entry(forum_id, entry_title, entry_body, options = {})
      self.post("/entries.json",
        options.merge(
          :body => { :entry => {
            :forum_id => forum_id, :title => entry_title, :body => entry_body
          } }.to_json
        )
      )
    end

    # Update an entry in the given forum id
    def put_entry(entry_id, entry_body, options = {})
      self.put("/entries/#{entry_id}.json",
        options.merge(
          :body => { :entry => { :body => entry_body } }.to_json
        )
      )
    end

  end
end