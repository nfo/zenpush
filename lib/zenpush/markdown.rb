# encoding: UTF-8
require 'redcarpet/compat'

module ZenPush
  class Markdown

    # Convert a markdown file to HTML, removing all <code> tags,
    # which make Zendesk remove carriage returns.
    def self.to_zendesk_html(file)
      ::Markdown.new(File.read(file)).to_html.gsub(/<\/?code>/, '')
    end
  end
end