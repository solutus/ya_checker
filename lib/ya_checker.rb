require "ya_checker/version"
require 'yaml'
require "em-synchrony"
require "em-synchrony/em-http"
require 'getoptlong'
require 'nokogiri'
require 'yaml'

module YaChecker
  class Processor
    def initialize(url,keywords, number)
      @url = url
      @number = number
      @keywords = keywords
    end

    def process
      result = []
      uri = URI.parse @url
      EventMachine.synchrony do
        multi = EventMachine::Synchrony::Multi.new
        @keywords.each do |keyword|
          request = EventMachine::HttpRequest.new(uri)
          multi.add keyword.to_sym, request.apost(:body => xml_request(keyword))
        end
        
        puts "simultaneous requests started"
        responses = multi.perform.responses[:callback]
        puts "http requests completed"
        result = responses.map{|keyword, http| [keyword, extract_url(http.response)] }
        EventMachine.stop
      end
      result
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
      
  end
end

