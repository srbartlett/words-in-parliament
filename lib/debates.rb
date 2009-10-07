require 'hpricot'
require 'open-uri'
require 'speech'

class Debates

  LOCATION_URI = 'http://data.openaustralia.org/scrapedxml/representatives_debates/'

  attr_reader :speeches

	@@cache = {}
  
	def initialize speeches
    @speeches = speeches 
  end

  def self.all_debates
    page = Hpricot(open(LOCATION_URI))
    debate_anchors = page.search('//a').select { |a| a[:href].include? '.xml'}
    debate_anchors.collect { |a| DateTime.parse(a[:href].gsub('.xml','')) }
  end

  def self.for year, month, day 
    key = "#{year}-#{month}-#{day}.xml"
		debates = from_cache key
		if debates.nil? then
			speeches = []
		  Hpricot.XML(open(LOCATION_URI + key)).search("//speech").collect do |speech|
			  speeches << Speech.new(speech[:id], speech[:time], speech[:speakername], (speech/"//*/text()").join)
			end 
			debates = Debates.new(speeches)
			add_to_cache key, debates
		end
		debates
  end

  def words
    @speeches.collect do |speech|
      speech.words_without_stopwords
    end.flatten
  end

  def top_most_frequent_words top_n = 20
    @top_most ||= calc_top_words top_n
  end

  private

  def self.add_to_cache key, debates
		@@cache[key] = debates
	end
 
  def self.from_cache key
		@@cache[key]
	end

	def calc_top_words top_n
    word_count =Hash.new(0)
    words.each { |word| word_count[word] += 1  unless word.empty?}
    word_count = word_count.sort_by {|x,y| -y }
    top_n = word_count.size > top_n.to_i ? top_n.to_i : word_count.size
    word_count[0..top_n-1].map { |w| {:word => w[0], :frequency => w[1], :max_frequency => word_count.first[1]} }
  end

end

