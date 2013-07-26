require 'test/unit'
require 'zenpush/zendesk'
require 'zenpush'

class SortingTest < Test::Unit::TestCase

  def test_can_find_attachments_folder_on_starter
    ZenPush.z.options[:account_type]="starter"
    ZenPush.z.options[:ignore_duplicate_names_in_path]=true
    
    category_name, forum_name, topic_title, attachments_folder = ZenPush.file_to_category_forum_topic(File.new("fixtures/category/forum/topic/topic.md"))
    assert_nil category_name
    assert_equal forum_name, "forum"
    assert_equal topic_title, "topic"
    assert_equal attachments_folder, "fixtures/category/forum/topic/attachments"
  end

  def test_can_find_attachments_folder_on_full
    ZenPush.z.options[:account_type]="full"
    ZenPush.z.options[:ignore_duplicate_names_in_path]=true

    category_name, forum_name, topic_title, attachments_folder = ZenPush.file_to_category_forum_topic(File.new("fixtures/category/forum/topic/topic.md"))
    assert_equal category_name, "category"
    assert_equal forum_name, "forum"
    assert_equal topic_title, "topic"
    assert_equal attachments_folder, "fixtures/category/forum/topic/attachments"
  end

  def test_can_find_attachments_folder_on_full_without_duplicates
    ZenPush.z.options[:account_type]="full"
    ZenPush.z.options[:ignore_duplicate_names_in_path]=false

    category_name, forum_name, topic_title, attachments_folder = ZenPush.file_to_category_forum_topic(File.new("fixtures/category/forum/non-duplicate.md"))
    assert_equal category_name, "category"
    assert_equal forum_name, "forum"
    assert_equal topic_title, "non duplicate"
    assert_nil attachments_folder
  end

  def test_can_find_attachments_folder_on_starter_without_duplicates
    ZenPush.z.options[:account_type]="starter"
    ZenPush.z.options[:ignore_duplicate_names_in_path]=false

    category_name, forum_name, topic_title, attachments_folder = ZenPush.file_to_category_forum_topic(File.new("fixtures/category/forum/non-duplicate.md"))
    assert_nil category_name
    assert_equal forum_name, "forum"
    assert_equal topic_title, "non duplicate"
    assert_nil attachments_folder
  end

end