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
      table = Terminal::Table.new do |t|
      @names[:result].each do |name|
        convert_title(name)
        japanese_title = @result[:title].to_s
        if japanese_title.size > 25
          japanese_title.insert(25, "\n")
        elsif japanese_title == ""
          next
        end
          if japanese_title.size > 25
            slice_title = japanese_title[0..21]
            slice_title += "..."
            t.add_row [name.magenta.bold, slice_title.light_green.bold]
          else
            t.add_row [name.magenta.bold, japanese_title.light_green.bold]
          end
        end
      end
      table.headings = ['Key',  'Title']
      table.style = {:width => 120, :padding_left => 3, :border_x => "=", :border_i => "x"}
      puts table
    end

    desc "update", "Get updated radio titles within a week."
    def update
      radio_name
      table = Terminal::Table.new do |t|
        @names[:result].each do |name|
          convert_title(name)
          japanese_title = @result[:title].to_s
          update_at = @result[:update].to_s
          unless update_at == ""
            array_update_at = update_at.split(".")
            result_year = array_update_at[0].to_i
            result_month = array_update_at[1].to_i
            result_day = array_update_at[2].to_i
            result_date = Date.new(result_year, result_month, result_day)
            current_date = Date.today
            week_ago = current_date - 7
            if result_date >= week_ago
              if japanese_title.size > 25
                japanese_title.insert(25, "\n")
              elsif japanese_title == ""
                next
              end
                if japanese_title.size > 25
                  slice_title = japanese_title[0..21]
                  slice_title += "..."
                  t.add_row [update_at.to_s.cyan.bold,  name.magenta.bold, slice_title.light_green.bold]
                else
                  t.add_row [update_at.to_s.cyan.bold,  name.magenta.bold, japanese_title.light_green.bold]
                end
            else
                next
            end
          else
            next
          end
            end
        end
        table.headings = ['Update_at', 'Key', 'Title']
        table.style = {:width => 120, :padding_left => 3, :border_x => "=", :border_i => "x"}
        table.align_column(1, :right)
        puts table
    end

    desc %Q(info [RADIO_KEY] options: "open" or "-o"), "Get updated radio titles within a week. options is open radio page."
    def info(key, open="")
      convert_title(key)
      guest = @result[:guest]
      if guest == ""
        guest = "なし"
      end
      puts "タイトル: #{@result[:title]} 第#{@result[:count]}回\n パーソナリティ: #{@result[:personality]}\n ゲスト: #{guest}\n 更新日: #{@result[:update]}\n スケジュール: #{@result[:schedule]}"
      if open == "open" || open == "-o"
        Launchy.open("http://www.onsen.ag/program/" + @result[:url])
      end
    end


    private

      def radio_name
        @url = 'http://www.onsen.ag/api/shownMovie/shownMovie.json'
        @name = ""
        open(@url) do |file|
          @name += file.read
        end
        @names = JSON.parse(@name, {:symbolize_names => true})
      end

      def convert_title(title)
        u = "http://www.onsen.ag/data/api/getMovieInfo/" + title
        escaped_address = URI.escape(u)
        uri = URI.parse(escaped_address)
        json = Net::HTTP.get(uri)
        json.gsub!(/^*callback\(/, '')
        json.gsub!(/\);$/, '')
        @result = JSON.parse(json, {:symbolize_names => true})
      end
  end
end
