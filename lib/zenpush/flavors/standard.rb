# encoding: UTF-8
require 'redcarpet/compat'

module ZenPush
  module Flavors
    module Standard
      def self.to_html(content)
        ::Markdown.new(content).to_html.gsub(/<\/?code>/, '')
      end
    end
  end
end

