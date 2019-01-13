# OnsenCli

インターネットラジオ音泉の番組一覧と番組情報をコマンドラインから閲覧できるコマンドラインツールです。

## Installation

RubyGems.orgを使用していなため[specific_install](https://github.com/rdp/specific_install)を使用してください。

    $ gem install specific_install
    
    $ gem specific_install -l https://github.com/izumiiii/onsen_cli.git


Add this line to your application's Gemfile:

```ruby
gem 'onsen_cli'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install onsen_cli

## Usage

Display commands:

    $ onsen_cli help
    
Titles 曜日ごとのタイトルの検索:
    
    $ onsen_cli titles [曜日]
    
![titles](https://user-images.githubusercontent.com/41711526/51089371-5425f480-17af-11e9-96f9-0d2c21873d1e.gif)

Info ラジオの詳細情報:

    $ onsen_cli info [RADIO_KEY] options: "open" or "-o"
    
![oci](https://user-images.githubusercontent.com/41711526/51089373-5ab46c00-17af-11e9-8976-af6f000e6fc4.gif)

Search　キーワードからのラジオタイトル検索:

    $ onsen_cli search [KEYWORD]

![ocs](https://user-images.githubusercontent.com/41711526/51089372-57b97b80-17af-11e9-81b8-ccb2eb0d14be.gif)

Topics　トピックスの取得:

    $ onsen_cli topics
    
![oct](https://user-images.githubusercontent.com/41711526/51089521-08287f00-17b2-11e9-8656-8adbe4a976c1.gif)
    
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/izumiiii/onsen_cli.
