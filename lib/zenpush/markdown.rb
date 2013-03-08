# encoding: UTF-8

module ZenPush
  module Flavors
    FILES = Dir[File.join(File.dirname(__FILE__), 'flavors', '**', '*.rb')].freeze
    NAMES = FILES.collect { |f| File.basename(f, '.rb') }.freeze
    FILES.each do |file|
      require file
    end
  end

  class Markdown
    def self.to_zendesk_html(file, flavor=nil)
      select_flavor(flavor).to_html(File.read(file))
    end

    def self.select_flavor(flavor)
      flavor ||= :standard
      flavor_class_name = flavor.to_s.capitalize.to_sym
      if ZenPush::Flavors.const_defined?(flavor_class_name)
        ZenPush::Flavors.const_get(flavor_class_name)
      else
        raise "The '#{flavor}' flavor is not supported. Use: #{ZenPush::Flavors::NAMES.join(', ')}."
      end
    end
  end
end


