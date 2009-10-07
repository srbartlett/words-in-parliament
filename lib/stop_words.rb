
class StopWords

  def self.words
    @@stopwords ||= File.open('stopwords.txt').collect do |sw|
      sw.downcase.strip
    end
  end

end

