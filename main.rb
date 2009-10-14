$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'debates'
require 'json'


get '/' do
  redirect 'index.html'
end

get '/api/representatives/words/for/:year/:month/:day/top:n/ngram:n' do |year, month, day, top_n, ngram| 
  content_type :json  
  Debates.for(year, month, day).top_most_frequent_words(ngram.to_i, top_n.to_i).to_json
end

get '/api/representatives/words/last' do 
  content_type :json 
  last_day = Debates.all_debates.last.strftime("%Y-%m-%d").to_json
end

