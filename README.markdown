# ZenPush

This gem allows editing your Zendesk knowledge base in Markdown. It's a command-line tool.

## Getting Started

    $ gem install zenpush

Run it:

    $ zenpush <command> <args>
    $ zp <command> <args>

## Requirements:

Only installs pure JSON gem json_pure by default. If you are able to install the C-extension json gem, it will use that instead.

Try:

    $ gem install json zenpush

## Configuration

Create a `zenpush.yml` file in your home directory. Here is an example:

    ---
    uri: https://myproduct.zendesk.com
    user: email@address.com/token
    password: LoDsQlEtBXSd8clW87DgWi0VNFod3U9xQggzwJEH

You can find your API token at https://myproduct.zendesk.com/settings/api.

## Usage

### Listing categories

    $ zp categories

### Listing forums

    $ zp forums

### Listing entries in a forum

    $ zp entries -f <forum_id>
    $ zp entries -F <forum_name>

### Creating/updating an entry

Keep an organized folder of your categories, forums, and entries. Let's say I have the category "Documentation", containing a forum "REST API", and the entries "Introduction" and "Authentication"; you'll want to keep this file structure:

    Documentation/REST API/Introduction.md
    Documentation/REST API/Authentication.md

Creating or updating an entry:

    $ zp push -f <path_to_markdown_file>

Following the previous example, you would type:

    [~/KB/Documentation/REST API]$ zp push -f Authentication.md
    [~/KB/Documentation]$ zp push -f REST API/Authentication.md
    [~/KB]$ zp push -f REST Documentation/API/Authentication.md

The gem will automatically discover the category and forum name of a given entry file. It will also convert your Markdown syntax in HTML before sending it to Zendesk.

### Check if an entry exists

    $ zp exists? -f <path_to_markdown_file>

## Contributors

* @nfo