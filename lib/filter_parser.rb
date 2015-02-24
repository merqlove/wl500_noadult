require 'open-uri'
require 'rubygems'
require 'nokogiri'

class FilterParser
  attr_writer :sources

  def initialize(params = {})
    params.each do |attr, value|
      public_send("#{attr}=", value)
    end if params
  end

  def list
    @sources.map { |source| single(source) }.flatten.compact.uniq
  end

  private

  def single(source)
    doc = Nokogiri::HTML(open(source[:url]))
    doc.encoding = 'utf-8'

    doc.css(source[:query]).map do |link|
      filter_path link.attribute('href').to_s.downcase, source[:clean]
    end
  end

  def filter_path(path, clean)
    return path unless path
    path = path.sub(clean, '') if clean
    if path.include?('reddit.com')
      path = path.sub('http://', '')
    else
      path = path.split('/')[2]
    end
    path.sub('www.', '').sub(/(\?.*)/i, '') if path
  end
end
