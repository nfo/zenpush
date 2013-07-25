# encoding: UTF-8
require 'zenpush/runner'
require 'zenpush/zendesk'
require 'zenpush/markdown'

module ZenPush
  extend self

  # Zendesk API
  def z
    @z ||= ZenPush::Zendesk.new
  end

  def file_to_category_forum_topic(file)
    absolute_path = File.realpath(file)
    file_extension = File.extname(file)

    parts = absolute_path.split('/')

    if ZenPush.z.options[:filenames_use_dashes_instead_of_spaces]
      parts.each { |el| el.gsub!(/-/, ' ') }
    end

    parts.reverse!

    topic_name = File.basename(parts[0], file_extension)
    parts.shift
    forum_name = nil
    category_name = nil
    if ZenPush.z.options[:ignore_duplicate_names_in_path]
      category_start=0
      parts.each_index{ |index|
        if parts[index]!=topic_name && !forum_name
          forum_name=parts[index]
          parts.shift(index)
        end
      }
      parts.each_index{ |index|
        if parts[index]!=category_name && !category_name
          category_name=parts[index]
        end
      }
    else
      forum_name = parts[-2]
      category_name = parts[-3]
    end

    return category_name, forum_name, topic_name
  end
end
