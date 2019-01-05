require "onsen_cli"
require "thor"
require 'open-uri'
require 'json'
require 'net/http'
require 'colorize'
require 'terminal-table'
require 'kconv'
require 'date'
require 'launchy'


module OnsenCli
  class CLI < Thor

    desc "titles", "Get the radio titles."
    def titles
    radio_name
    rows = []
      @names[:result].each do |key|
        get_radio_info(key)
        next if @result.has_key?(:error)
        japanese_title = @result[:title]
        if japanese_title.length > 25
          slice_title = ellipsis_title(japanese_title)
          rows << [key.magenta.bold, slice_title.light_green.bold + "...".light_green.bold]
        else
          rows << [key.magenta.bold, japanese_title.light_green.bold]
        end
      end
      table = Terminal::Table.new :headings => ['Key',  'Title'],
              :style => {:width => 120, :padding_left => 3, :border_x => "=", :border_i => "x"}, :rows => rows
      puts table
    end


    desc "update", "Get updated radio titles within a week."
    def update
      radio_name
      rows = []
      current_time = Date.today
      week_ago = current_time - 7
      @names[:result].each do |key|
        get_radio_info(key)
        next if @result.has_key?(:error)
        japanese_title = @result[:title]
        update_at = @result[:update]
        next if update_at  == ""
        convert_date(update_at)
        if @result_date >= week_ago
          if japanese_title.length > 25
            slice_title = ellipsis_title(japanese_title)
            rows << [update_at.to_s.cyan.bold,  key.magenta.bold, slice_title.light_green.bold + "...".light_green.bold]
          else
            rows << [update_at.to_s.cyan.bold,  key.magenta.bold, japanese_title.light_green.bold]
          end
        end
      end
      table = Terminal::Table.new :headings => ['Update_at', 'Key', 'Title'],
              :style => {:width => 120, :padding_left => 3, :border_x => "=", :border_i => "x"},
              :align_column => {:right => 1},
              :rows => rows
      puts table
    end

    desc %Q(info [RADIO_KEY] options: "open" or "-o"), "Get updated radio titles within a week. options is open radio page."
    def info(key, open="")
      get_radio_info(key)
      if @result.has_key?(:error)
        puts "Not Found: 番組が見つかりませんでした。".colorize(:color => :white, :background => :red).bold
        exit!
      end
      guest = @result[:guest]
      guest = "なし" if guest == ""
      puts "タイトル: #{@result[:title]} 第#{@result[:count]}回\n パーソナリティ: #{@result[:personality]}\n ゲスト: #{guest}\n 更新日: #{@result[:update]}\n スケジュール: #{@result[:schedule]}"
      if open == "open" || open == "-o"
        Launchy.open("http://www.onsen.ag/program/" + @result[:url])
      end
    end


    private

      def radio_name
        url = 'http://www.onsen.ag/api/shownMovie/shownMovie.json'
        name = ""
        open(url) do |file|
          name += file.read
        end
        @names = JSON.parse(name, {:symbolize_names => true})
      end

      def get_radio_info(key)
        escaped_address = URI.escape('http://www.onsen.ag/data/api/getMovieInfo/' + key)
        uri = URI.parse(escaped_address)
        json = Net::HTTP.get(uri)
        json.gsub!(/^*callback\(|\);$/, '')
        @result = JSON.parse(json, {:symbolize_names => true})
      end

      def ellipsis_title(japanese_title)
        japanese_title.insert(25, "\n")
        japanese_title.slice(0..21)
      end

      def convert_date(update_at)
        array_update_at = update_at.split(".")
        result_year = array_update_at[0].to_i
        result_month = array_update_at[1].to_i
        result_day = array_update_at[2].to_i
        @result_date = Date.new(result_year, result_month, result_day)
      end
  end
end
