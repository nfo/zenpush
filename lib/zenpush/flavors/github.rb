# encoding: UTF-8
require 'redcarpet'
require 'pygments'

module ZenPush
  module Flavors

    class SyntaxRenderer < Redcarpet::Render::HTML
      def block_code(code, language)
        if language && !language.empty?
          Pygments.highlight(code, :options => {:lexer => language.to_sym, :encoding => 'utf-8'})
        else
          "<pre>#{code}</pre>"
        end
      end
    end

    module Github
      def self.to_html(text)
        renderer = SyntaxRenderer.new(optionize [
          :with_toc_data,
          :hard_wrap,
          :xhtml
        ])
        markdown = Redcarpet::Markdown.new(renderer, optionize([
          :fenced_code_blocks,
          :no_intra_emphasis,
          :tables,
          :autolink,
          :strikethrough,
          :space_after_headers
        ]))
        markdown.render(text)
      end

      def self.optionize(options)
        options.each_with_object({}) { |option, memo| memo[option] = true }
      end
    end
  end
end
