require 'rubygems'
require 'sinatra'
require 'haml'
require '/home/artega/dev/sloggr/lib/partials.rb'
require 'mongo_mapper'
require 'omniauth'
require 'bb-ruby'

use OmniAuth::Builder do
  provider :facebook, '187715447931456', '2e8c1a8f5d73bc8c438779c39e5f57c9'
end

MongoMapper.database = 'slog'

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

class Article
  include MongoMapper::Document

  key :title, String
  key :text, String
  key :date, Time

  key :author, String

  key :tags, Array
  def html_text
    text.bbcode_to_html
  end
end

helpers Sinatra::Partials

enable :sessions
enable :run

before do
  if session['user'] then
    @logged_in = User.where(:id => session['user']).first()
  end
end

get '/auth/:provider/callback' do
  auth = request.env['omniauth.auth']
  @user = User.where(:provider => auth['provider'], :uid => auth['uid']).first()

  @user = User.new unless @user
  @user.provider = auth['provider']
  @user.uid = auth['uid']
  usr_info = auth['user_info']
  @user.name = usr_info['name'] if usr_info['name']
  @user.email = usr_info['email'] if usr_info['email']
  @user.nickname = usr_info['nickname'] if usr_info['nickname']
  @user.first_name = usr_info['first_name'] if usr_info['first_name']
  @user.last_name = usr_info['last_name'] if usr_info['last_name']
  @user.image = usr_info['image'] if usr_info['image']

  @user.save

  session['user'] = @user.id
  redirect '/' if @user

end

get '/article/add' do
  redirect '/' unless @logged_in.role == "admin"
  haml :add_article
end
post '/article/add' do
  redirect '/' unless @logged_in.role == "admin"
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
