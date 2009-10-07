require 'stop_words'

class Speech
  attr_accessor :sid, :time, :speeker, :content


  def initialize sid, time, speeker, content
    @sid = sid
    @time = time
    @speeker = speeker
    @content = content
  end

  def words
    content.downcase.split(/[^a-zA-Z]/)
  end

  def words_without_stopwords
    words.select do |word|
      !StopWords.words.include?(word.downcase.strip)
    end
  end

end

