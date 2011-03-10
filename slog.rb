require 'rubygems'
require 'sinatra'
require 'haml'
require 'lib/partials.rb'
require 'mongo_mapper'

MongoMapper.database = 'slog'

class Article
  include MongoMapper::Document

  key :title, String
  key :text, String
  key :date, Time

  key :author, String

  key :tags, Array

  many :comments

end

class Comment
  include MongoMapper::EmbeddedDocument

  key :date, Time
  key :author, String
  key :text, String

end

helpers Sinatra::Partials

get '/article/add' do
  haml :add_article
end
post '/article/add' do
  @article = Article.new
  @article.title = params[:title]
  @article.text = params[:text]
  @article.date = Time.now
  @article.save

  haml :article
end
get '/article/:id' do |id|
  @article = Article.where(:id => id).first()
  haml :view_article
end
post '/article/:id/comment' do |id|
  @article = Article.where(:id => id).first()
  pass unless @article
  comment = Comment.new
  comment.author = params[:author]
  comment.date = Time.now
  comment.text = params[:comment]
  @article.comments << comment
  @article.save
  haml :view_article

end
get '/' do
  @articles = Article.sort(:date.desc).all()
  @home = "active"
  haml :index
end

get '/*' do
  "Blank page"
end
