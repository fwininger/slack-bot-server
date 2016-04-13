module SlackBotServer
  module Commands
    class Ratp < SlackRubyBot::Commands::Base
      def self.fetch_ratp
        url = "http://apixha.ixxi.net/APIX?keyapp=FvChCBnSetVgTKk324rO&cmd=getNextStopsRealtime&stopArea=846&line=58&direction=115&withText=true&apixFormat=json".freeze
        res = Net::HTTP.get_response(URI(url))

        case res
        when Net::HTTPSuccess then
          json = JSON.parse(res.body)
          json.symbolize_keys
        else
          nil
        end
      end

      def self.call(client, data, _match)
        client.say(channel: data.channel, text: fetch_ratp.to_s)
        logger.info "UNAME: #{client.owner}, user=#{data.user}"
      end
    end
  end
end
