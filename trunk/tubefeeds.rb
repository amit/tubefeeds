#!/usr/bin/ruby
# tubefeeds generates RSS2.0 feed for youtube search results.
# == Authors
# 
# * Amit Chakradeo <chakradeo+spam@gmail.com>
# == Copyright
# 
# tubefeeds is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# tubefeeds is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
require 'open-uri'
require 'rubygems'
require_gem 'hpricot'
require 'hpricot'
require 'cgi'

def get_duration(runtime)
  min,sec = runtime.split(":")
  return(min.to_i * 60 + sec.to_i)
end

def get_data(doc)
  data = []
  #doc = Hpricot(open('results.html'))
  #doc.search("div.vtitle").at("a") do |e|
  doc.search("div.vEntry") do |e|
    data<< {:thumbnail=>e.at(".vimg120")[:src],
 		:permalink=>"http://www.youtube.com"+e.at(".vtitle").at("a")[:href],
		:runtime=>e.at(".runtime").inner_text,
		:description=>e.at(".vdesc").inner_text,
 		:tags=>e.at("div.vtagValue").inner_text,
		:title=>e.search("div.vtitle").at("a").inner_text,
		:credit=>e.search("div.vfacets").search("a")[-1].inner_text,
}
  end
  data
end

def get_magic(url)
  magic=url.match(/.*v=(.*)/)[1]
end

def generate_rss(searchstr)
searchstr=CGI.escape(searchstr)
entries = []
pagenum = 1
url="http://youtube.com/results?search_type=search_videos&search_query=#{searchstr}&search_sort=relevance&search_category=0&page=#{pagenum}"
data=[]
doc = Hpricot(open(url))
  
begin
#    puts "FETCHING PAGE #{pagenum}"
    data = get_data(doc)
    entries = entries + data
    pagenum = pagenum+1
end while (nil)
#end while (data.length > 0)

#puts "ENTRIES Length = #{entries.length}"
puts <<ENDOFSTR
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
<channel>
<title>Yourtube Search Results for #{searchstr}</title>
<link>http://youtube.com/results?search_query=#{searchstr}</link>
<image> 
			<url>http://youtube.com/img/pic_youtubelogo_123x63.gif</url>
			<link>http://youtube.com/results?search_query=#{searchstr}</link> 
			<title>YouTube</title> 
			<height>63</height>
			<width>123</width>
</image>
<description>Search Results for #{searchstr}</description>
ENDOFSTR
entries.each do |e|
puts <<EOSTR
<item><author>rss@youtube.com (#{e[:credit]})</author>
<title>#{e[:title]}</title>
<link>#{e[:permalink]}</link>
<description>
<![CDATA[
<img src="#{e[:thumbnail]}" border="0" />
<p>#{e[:description]}</p>
]]>
</description>
<guid isPermaLink="true">#{e[:permalink]}</guid>
<pubDate>#{Time.now.strftime('%a, %d %b %Y %T %z')}</pubDate>
<media:player url="http://youtube.com/?v=#{get_magic(e[:permalink])}"/>
<enclosure url="http://youtube.com/v/#{get_magic(e[:permalink])}" duration="#{get_duration(e[:runtime])}" type="application/x-shockwave-flash"/>
</item>
EOSTR
end 
puts "</channel></rss>"
end

if __FILE__ == $0
  generate_rss("a. r. rahman")
end
