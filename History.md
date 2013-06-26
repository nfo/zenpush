## 0.3.1

* Bugfix: Finding a forum by name is scoped to the category. ([alexkwolfe](https://github.com/alexkwolfe))

## 0.3.0

* [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown) support, with the `-F github` option. ([alexkwolfe](https://github.com/alexkwolfe))
* [Zendesk API v2](http://www.zendesk.com/blog/zendesk-api). `entries` become `topics`. ([alexkwolfe](https://github.com/alexkwolfe))
* Automatically create category and forum if either does not exist. ([alexkwolfe](https://github.com/alexkwolfe))

## 0.2.0

* HTML support: don't convert topics to HTML if they're not `.md` or `.markdown` files. ([nfo](https://github.com/nfo))

## 0.1.1

* New option `:filenames_use_dashes_instead_of_spaces`. ([torandu](https://github.com/torandu))

## 0.1.0

* Original version. ([nfo](https://github.com/nfo))
* List categories, forums, entries. ([nfo](https://github.com/nfo))
* Convert entries from Markdown to HTML before pushing them to Zendesk. ([nfo](https://github.com/nfo))