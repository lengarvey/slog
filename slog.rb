require 'rubygems'
require 'sinatra'
require 'haml'
require_relative 'lib/partials.rb'
require 'mongo_mapper'
require 'omniauth'
require 'sinatra/session'
require 'rack/gridfs'
require 'joint'
require 'hpricot'
require_relative 'routes.rb'

use OmniAuth::Builder do
  provider :facebook, '187715447931456', '2e8c1a8f5d73bc8c438779c39e5f57c9'
end

MongoMapper.database = 'slog'

class Asset
  include MongoMapper::Document
  plugin Joint # add the plugin

  attachment :file # declare an attachment named image
end

class User
  include MongoMapper::Document

  key :provider, String
  key :uid, String
  key :name, String

  key :nickname, String

  key :email, String
  key :first_name, String
  key :last_name, String
  key :image, String #url of their avatar

  key :role, String
end
class Link
  include MongoMapper::Document
  key :url, String
  key :text, String
  key :article_id, String
  key :article, String
end
class Article
  include MongoMapper::Document

  key :title, String
  key :text, String
  key :date, Time
  key :author, String # id of user
  key :author_image_url, String
  key :tags, Array
  key :extract, String
  def extract_or_text
    extract || text
  end
  def get_tag_links
    links = ""
    self.tags.each do |tag|
      links += "<a href='http://bottledup.net/tag/" +tag+"'>#{tag}</a> "
    end
    return links
  end
  def first_three_tags
    links = ""
    self.tags[0..2].each do |tag|
      links += "<a href='http://bottledup.net/tag/" +tag+"'>#{tag}</a> "
    end
    return links
  end
  def html_text
    text
  end
  def nice_date
    self.date.strftime("%Y-%m-%d");
  end
  def get_author_image
    return self.author_image_url || "empty_user_image.jpg"
  end
  
  
end
class TagCloud
  def self.build
    map ="function(){this.tags.forEach(function(tag){emit(tag, 1);});}"
    reduce = "function(prev, current) {var count = 0;for (index in current) {count += current[index];}return count;}"
    Article.collection.map_reduce(map, reduce, :out => {:merge => 'tag_mr_results'})
  end
end


helpers Sinatra::Partials
set :session_fail, '/auth/facebook'
set :session_secret, 'Il0ve5dllje%%4r'

before do
  if session? then
    @logged_in = User.where(:id => session['user']).first()
  end
end

