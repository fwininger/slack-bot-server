module SlackBotServer
  module Commands
    class Tram < SlackRubyBot::Commands::Base
      def self.fetch_ratp
        url = "http://apixha.ixxi.net/APIX?keyapp=FvChCBnSetVgTKk324rO&cmd=getNextStopsRealtime&stopArea=846&line=58&withText=true&apixFormat=json".freeze
        res = Net::HTTP.get_response(URI(url))

        case res
        when Net::HTTPSuccess then
          json = JSON.parse(res.body)
          json.symbolize_keys
        else
          nil
        end
      end

      def self.process_result
        data = fetch_ratp
        return [] if data.nil?
        res = []
        data[:nextStopsOnLines].each do |line|
          hash = line.symbolize_keys
          logger.info "ratp line : #{hash.to_s}"

          lineName = "#{hash[:groupOfLinesName]} #{hash[:lineName]}"

          hash[:nextStops].each do |stop|
            stop = stop.symbolize_keys
            color = if stop[:waitingTime].to_i < 3*60
                      '#FF0000'
                    elsif stop[:waitingTime].to_i < 6*60
                      '#00FF00'
                    else
                      '#ffdb47'
                    end
            res << {
                  fallback: "#{lineName} à destiation de #{stop[:destinationName]}: #{stop[:waitingTimeRaw].to_s}",
                  title: "#{lineName} à destiation de #{stop[:destinationName]}",
                  text: "#{stop[:waitingTimeRaw]}",
                  color: color
              }
          end
        end
        logger.info "Result process : #{res.to_s}"
        res
      end

      def self.call(client, data, _match)
        #client.say(channel: data.channel, attachments: process_result)
        client.web_client.chat_postMessage(
          channel: data.channel,
          as_user: true,
          attachments: process_result
        )
        logger.info "UNAME: #{client.owner}, user=#{data.user}"
      end
    end
  end
end
