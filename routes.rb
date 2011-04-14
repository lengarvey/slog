require 'sinatra-authentication'
use Rack::Session::Cookie, :secret => 'CHANGEME'
set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + "auth_views/"

after '/signup' do
  if request.post? && @user.valid && @user.id then
    puts "after signup"
  end
end

# assets and upoading
# access an asset
get '/assets/:id' do |id|
  asset = Asset.where(:id => id).first()
  file = asset.file

  [200, {'Content-Type' => file.content_type}, [file.read]]
end

# upload an asset
post '/upload' do
  login_required
  redirect '/' unless current_user.admin? 
  asset = Asset.create(:file => params[:file][:tempfile])
  asset.file_name = params[:file][:filename]
  asset.save
  partial :asset, :locals => {:asset => asset}
end



def add_or_edit(params, id = nil)
  article = if id
    Article.where(:id => id).first
  else
    Article.new
  end

  article.title = params[:title]
  article.text = params[:text]
  doc = Hpricot(article.text)
  index = 1
  article.extract = doc.search("//p")[0..1].flatten

  article.date = Time.now if article.new_record?
  article.author = current_user.name
  article.author_image_url = current_user.image
  article.tags = params[:tags].downcase.delete(" ").split(',')
  article.save!
  
  #extract links out of the text too!
  doc.search("//a").each do |link|
    nlink = Link.where(:href => link.attributes['href']).first() || Link.new
    nlink.href = link.attributes['href']
    nlink.text = link.inner_html
    nlink.article_id = article._id
    nlink.article = article.title
    nlink.save!
  end
  article
end

get '/archives' do
  @tags = TagCloud.build.find()
  @thash = @tags.map do |tag|
    {"text" => "#{tag['_id']}", "weight" => (tag['value'] * 10).to_i, "url" => "/tag/#{tag['_id']}"}
  end
  
  @articles = Article.sort(:date.desc).all()
  @home = "active"
  @title = "bottledup.net archives - aged to perfection"
  haml :index, :ugly => true
end

get '/links' do
  @links = Link.sort(:id.desc).all();
  @tags = TagCloud.build.find()
  @thash = @tags.map do |tag|
    {"text" => "#{tag['_id']}", "weight" => (tag['value'] * 10).to_i, "url" => "/tag/#{tag['_id']}"}
  end
  @link = "active"
  @title = "bottledup.net links - symbolic thirst quenching"
  haml :links 
end

# article display, adding, editing, deleting
#
post '/article/add' do
  login_required
  redirect '/' unless current_user.admin? 
  @article = add_or_edit(params)
  redirect "/article/#{@article.id}"
end
get '/article/:id' do |id|
  @article = Article.where(:id => id).first()
  pass unless @article
  @tags = TagCloud.build.find()
  @thash = []
  @tags.each do |tag|
    @thash << {"text" => "#{tag['_id']}", "weight" => (tag['value'] * 10).to_i, "url" => "/tag/#{tag['_id']}"}
  end
  @title = "bottledup.net - #{@article.title}"
  haml :view_article, :ugly => true
end
get '/article/add' do
  login_required
  redirect '/' unless current_user.admin? 
  @assets = Asset.sort(:id.desc).all()
  haml :add_article, :layout => :add_layout
end
post '/article/:id' do |id|
  login_required
  redirect '/' unless current_user.admin? 
  @article = add_or_edit(params, id)
  redirect "/article/#{@article.id}"
end
get '/article/:id/edit' do |id|
  login_required
  redirect '/' unless current_user.admin? 
  @assets = Asset.sort(:id.desc).all()
  @article = Article.where(:id => id).first()
  haml :edit, :layout => :add_layout 
end
get '/article/:id/delete' do |id|
  login_required
  redirect '/' unless current_user.admin? 
  @article = Article.where(:id => id).first()
  @article.delete
  redirect '/'
end

# index and tags
get '/' do
  @tags = TagCloud.build.find()
  @thash = @tags.map do |tag|
    {"text" => "#{tag['_id']}", "weight" => (tag['value'] * 10).to_i, "url" => "/tag/#{tag['_id']}"}
  end
  
  @articles = Article.sort(:date.desc).all()
  @home = "active"
  @title = "bottledup.net - programming uncorked"
  haml :index, :ugly => true
end

get '/tag/:tag' do |ptag|
  @tags = TagCloud.build.find()
  @thash = []
  @tags.each do |tag|
    @thash << {"text" => "#{tag['_id']}", "weight" => (tag['value'] * 10).to_i, "url" => "/tag/#{tag['_id']}"}
  end
  @articles = Article.where(:tags => ptag).all()
  @title = "bottledup.net - #{ptag}"
  haml :index
end

get '/*' do
  redirect '/'
end
