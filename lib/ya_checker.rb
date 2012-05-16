require "ya_checker/version"
require 'yaml'
require "em-synchrony"
require "em-synchrony/em-http"
require 'getoptlong'
require 'rack'
require 'nokogiri'

module YaChecker
  class Processor
    def initialize
      opts = GetoptLong.new([ '--number', '-n', GetoptLong::OPTIONAL_ARGUMENT ], 
        [ '--url', '-u', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--help', '-h', GetoptLong::NO_ARGUMENT ])
      opts.each do |opt, arg|
        case opt
          when '--number'
            @number = arg.to_i
          when '--url'
            @url = arg
          when '--help'
            puts help_message
        end
      end
      if ARGV.length != 1
        puts "Missing arguments: url and number (try --help)"
        exit 0
      end

      @number ||= 1
      @keywords = ARGV
      puts "number: #{@number}, argv: #{ARGV}"
    end

    def process
      responses = []
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
        
        responses.map{|keyword, http| puts "#{keyword}: #{extract_url(http.response)}" }
        EventMachine.stop
      end

    end       

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
    
    def help_message
      puts <<-EOF
DESCRIPTION
  checker - retrieves search results for keyword from xml.yandex.ru and returns url from particular position.

SYNOPSIS
  checker [KEYWORD...] [OPTIONS]

  -h, --help:
     show help

  --number x, -n x:
     url position number in response

  --url [name]:
     xml.yandex url

  KEYWORD - words should to be found in yandex search
      EOF
    end      
  end
end
