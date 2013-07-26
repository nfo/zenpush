require 'test/unit'
require 'zenpush/zendesk'

class UploadTest < Test::Unit::TestCase

  def test_upload_file
    # This is kind of an integration test, and requires your zendesk account to setup correctly in the .zenpush.yml file
    #  It might be valid to remove this test, but can't think of a good way of testing my method

    desk = ZenPush::Zendesk.new
    assert_not_nil desk.options
    body = desk.post_upload("testfile", File.new("fixtures/category/forum/topic/attachments/upload.jpg"))
    assert_equal 15, body.size()

  end

end