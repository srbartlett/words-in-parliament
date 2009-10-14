require 'hpricot'
require 'open-uri'
require 'speech'
require 'stop_words'

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
      #Hpricot.XML(open('./2009-09-15.xml')).search("//speech").collect do |speech|
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
      speech.words.select do |word|
        yield word
      end 
    end.flatten
  end

  def top_most_frequent_words ngram, top_n = 20
    calc_top_words ngram, top_n
  end


  private

  def self.add_to_cache key, debates
    @@cache[key] = debates
  end
 
  def self.from_cache key
    @@cache[key]
  end

  def calc_top_words ngram, top_n
    ngrams = Hash.new(0)
    if ngram > 1 then
      ngram = 3 if ngram > 3
      all_words = words { |word| true unless word.empty? } 
    
      (all_words.length-2).times do |i|
        tuple = []
        ngram.times { |posn| tuple << all_words[posn + i] } 
        ngrams[tuple.join(' ')] += 1
      end
    else
      words do |word|
        !StopWords.words.include?(word.downcase.strip)
      end.each { |word| ngrams[word] += 1  unless word.empty?}
    end
    ngrams = ngrams.sort_by {|x,y| -y }
    
    top_n = ngrams.size > top_n.to_i ? top_n.to_i : ngrams.size
    ngrams[0..top_n-1].map { |w| {:word => w[0], :frequency => w[1], :max_frequency => ngrams.first[1]} }
  end

end

