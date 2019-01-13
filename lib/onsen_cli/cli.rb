require "onsen_cli"
require "thor"
require 'open-uri'
require 'json'
require 'net/http'
require 'colorize'
require 'kconv'
require 'launchy'
require 'nokogiri'
require 'Date'


module OnsenCli
  class CLI < Thor

    desc "titles [DAY]", "Get the radio titles. Please specify an argument. Japanese: 月、火、水.. English: mon, tue, wed.. no arguenmet: get today radio titles."
    def titles(day = "")
      day_en = get_day(day)
      # sleep(1)
      doc = Nokogiri::HTML(open('http://www.onsen.ag/'))
      doc.css('.listWrap .clr li').each do |title|
        if title.attr('data-week') == day_en
          puts "#{title.attr('id')} #{title.attr('data-update')} #{title.css('h4 span').inner_text.bold}"
        end
      end
    end

    desc "search [KEYWORD]", "Search radio titles."
    def search(word)
      escaped_address = URI.escape('http://www.onsen.ag/data/api/searchMovie?word=' + word)
      uri = URI.parse(escaped_address)
      json = Net::HTTP.get(uri)
      json.gsub!(/^*callback\(|\);$/, '')
      search_result = JSON.parse(json, {:symbolize_names => true})
      titles = search_result(search_result[:result])
      titles.each { |key, title| puts "#{key} #{title.bold}" }
    end

    desc "topics", "Get Onsen topics."
    def topics
      doc = Nokogiri::HTML(open('http://www.onsen.ag/blog/?feed=rss2'))
      doc.css('item').each do |topic|
        puts "\n#{topic.css('title').inner_text.bold}\n#{topic.css('encoded p.summaryText').inner_text.delete("＞続きを読む")}\n#{topic.css('guid').inner_text}\n"
      end
    end

    desc %Q(info [RADIO_KEY] options: "open" or "-o"), "Get the radio informations. options is open radio page."
    def info(key, open="")
      result = get_radio_info(key)
      if result.has_key?(:error)
        puts "Not Found: 番組が見つかりませんでした。".colorize(:color => :white, :background => :red).bold
        exit!
      end
      puts "タイトル: #{result[:title]} 第#{result[:count]}回\nパーソナリティ: #{result[:personality]}\nゲスト: #{result[:guest]}\n更新日: #{result[:update]}\nスケジュール: #{result[:schedule]}\nメールアドレス: #{result[:mail]}"
      if open == "open" || open == "-o"
        Launchy.open("http://www.onsen.ag/program/" + result[:url])
      end
    end


    private

      def get_radio_info(key)
        escaped_address = URI.escape('http://www.onsen.ag/data/api/getMovieInfo/' + key)
        uri = URI.parse(escaped_address)
        json = Net::HTTP.get(uri)
        json.gsub!(/^2*callback\(|\);$/, '')
        return result = JSON.parse(json, {:symbolize_names => true})
      end

      def search_result(results)
        hash = {}
        results.each do |result|
          movie_info = get_radio_info(result)
          unless movie_info.has_key?(:error)
            hash.store(movie_info[:url],movie_info[:title])
          end
        end
        return hash
      end

      def get_day(day)
        case day
          when "月", "mon"
            day_en = "mon"
          when "火", "tue"
            day_en = "tue"
          when "水", "wed"
            day_en = "wed"
          when "木", "thu"
            day_en = "thu"
          when  "金", "fri"
            day_en = "fri"
          when "土", "sat"
            day_en = "sat"
          when "日", "sun"
            day_en = "sat"
          when "", "今日", "today"
            d = Date.today
            if d.strftime("%a").downcase! == "sun"
              day_en = "sat"
            else
              day_en =  d.strftime("%a").downcase!
            end
          else
            raise "日付を指定してください。 指定については[onsen_cli help]で確認することができます。".colorize(:white).colorize(:background => :red).bold
        end
        return day_en
      end
  end
end
