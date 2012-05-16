require 'ya_checker'
require 'webmock/rspec'

describe YaChecker::Processor do 
  it "should process" do
    url = "http://xmlsearch.yandex.ru/xmlsearch?user=ANY&key=KEY"
    keywords = %w[ruby vim]
    ya_checker = YaChecker::Processor.new url, keywords, 2 
    
    keywords.each do |keyword|
      xml = ya_checker.send :xml_request, keyword
      stub_request(:post, url).with(:body => xml).
        to_return(:body => "<search><url>1</url><url>#{keyword}</url></search>")
    end
    
    res = ya_checker.process
    keywords.each_with_index do |keyword, index|
      res[index].should eql [keyword.to_sym, keyword]
    end
  end
end
