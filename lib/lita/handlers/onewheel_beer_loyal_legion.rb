require 'rest-client'
require 'nokogiri'
require 'sanitize'
require 'lita-onewheel-beer-base'

module Lita
  module Handlers
    class OnewheelBeerLoyalLegion < OnewheelBeerBase
      route /^loyallegion$/i,
            :taps_list,
            command: true,
            help: {'loyallegion' => 'Display the current loyallegion Bar taps.'}

      route /^loyallegion ([\w ]+)$/i,
            :taps_deets,
            command: true,
            help: {'loyallegion 4' => 'Display the tap 4 deets, including prices.'}

      route /^loyallegion ([<>=\w.\s]+)%$/i,
            :taps_by_abv,
            command: true,
            help: {'loyallegion >4%' => 'Display beers over 4% ABV.'}

      route /^loyallegion ([<>=\$\w.\s]+)$/i,
            :taps_by_price,
            command: true,
            help: {'loyallegion <$5' => 'Display beers under $5.'}

      route /^loyallegion (roulette|random|rand|ran|ra|r)$/i,
            :taps_by_random,
            command: true,
            help: {'loyallegion roulette' => 'Can\'t decide?  Let me do it for you!'}

      route /^loyallegionabvlow$/i,
            :taps_low_abv,
            command: true,
            help: {'loyallegionabvlow' => 'Show me the lowest abv keg.'}

      route /^loyallegionabvhigh$/i,
            :taps_high_abv,
            command: true,
            help: {'loyallegionabvhigh' => 'Show me the highest abv keg.'}

      def send_response(tap, datum, response)
        reply = "Loyal Legion tap #{tap}) #{get_tap_type_text(datum[:type])}"
        # reply += "#{datum[:brewery]} "
        reply += "#{datum[:name]}, "
        # reply += "- #{datum[:desc]}, "
        # reply += "Served in a #{datum[1]['glass']} glass.  "
        # reply += "#{datum[:remaining]}"
        reply += "#{datum[:abv]}%, "
        reply += "#{datum[:ibu]} IBU, "
        reply += "$#{datum[:price].to_s}"

        Lita.logger.info "send_response: Replying with #{reply}"

        response.reply reply
      end

      def get_source
        Lita.logger.debug 'get_source started'
        unless (response = redis.get('page_response'))
          Lita.logger.info 'No cached result found, fetching.'
          response = RestClient.get('http://loyallegionpdx.com/taplist')
          redis.setex('page_response', 1800, response)
        end
        parse_response response
      end

      # This is the worker bee- decoding the html into our "standard" document.
      # Future implementations could simply override this implementation-specific
      # code to help this grow more widely.
      def parse_response(response)
        Lita.logger.debug 'parse_response started.'
        gimme_what_you_got = {}
        noko = Nokogiri.HTML response

        noko.css('article.tap-item').each do |beer_node|
          # gimme_what_you_got
          tap_name = beer_node.css('small.tapnum').children.to_s.sub 'Tap#', ''
          next if tap_name.empty?

          beer_name = beer_node.css('div.tap-content h1').children.to_s.strip

          greyout = beer_node.css('small.grayout').children.to_s
          greyedouts = greyout.split /\|/
          beer_type = greyedouts[0].strip
          abv = greyedouts[1].match(/\d+\.*\d*/).to_s
          if greyedouts[2]
            ibu = greyedouts[2].match(/\d+/).to_s
          end

          price = beer_node.css('div.beer-price').children.first.to_s.strip.sub '$', ''

          full_text_search = "#{beer_name} #{beer_type}"

          gimme_what_you_got[tap_name] = {
          #     type: tap_type,
          #     remaining: remaining,
          #     brewery: brewery.to_s,
              name: beer_name.to_s,
              desc: beer_type.to_s,
              abv: abv.to_f,
              ibu: ibu.to_f,
              price: price,
              search: full_text_search
          }
        end
        # puts gimme_what_you_got.inspect

        gimme_what_you_got
      end

      Lita.register_handler(self)
    end
  end
end
