require "em-synchrony"
require "em-synchrony/em-http"
require "em-synchrony/fiber_iterator"
require 'getoptlong'
require 'nokogiri'

module YaChecker
  class Processor
    def initialize(url, keywords, number)
      @url = url
      @number = number
      @keywords = keywords
      @map = init_map keywords
    end

    def process 
      uri = URI.parse @url

      EventMachine.synchrony do
        EM::Synchrony::FiberIterator.new(@keywords, @keywords.size).each do |keyword|
          request = EventMachine::HttpRequest.new(uri)
          response = request.post(:body => xml_request(keyword))
          parse_results response, keyword
        end
        EventMachine.stop
      end
      @map
    end       
    

    private
      def xml_request keyword
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>   
          <request>   
            <query>#{keyword}</query>
            <groupings>
              <groupby attr=\"d\" mode=\"deep\" groups-on-page=\"10\"  docs-in-group=\"1\" />   
            </groupings>  
          </request>"
      end

      def extract_url response
        doc = Nokogiri::XML(response)
        urls = doc.xpath('//url').map do |link|
          link.content
        end
        urls[@number - 1]
      end
      
      def init_map keywords
        keywords.inject({}){|hash, k| hash[k] = nil; hash}
      end

      def parse_results response, keyword
        url = extract_url(response.response)
        @map[keyword] = url
        print_results
      end

      def print_results
        @map.each do |keyword, url|
          break if url.nil?

          puts "#{keyword}: #{@map[keyword]}" 
          @map.delete keyword 
        end
      end

  end
end

