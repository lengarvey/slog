
get '/assets/:id' do |id|
  asset = Asset.where(:id => id).first()
  file = asset.file
  [200, {'Content-Type' => file.content_type}, [file.read]]
end

post '/upload' do
  #redirect '/' unless @logged_in and @logged_in.role == "admin"
  #params.to_s
  asset = Asset.create(:file => params[:file][:tempfile])
  asset.save
  "/gridfs/#{asset.id}"
  #redirect request.referrer
end

get '/logout' do
  session_end!
  redirect '/'
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
  @user.image = "https://graph.facebook.com/#{@user.uid}/picture"
  @user.save
  session_start!
  session['user'] = @user.id
  redirect '/' if @user

end
get '/tag/:tag' do |tag|
  @tags = TagCloud.build.find()
  @thash = []
  @tags.each do |tag|
    @thash << {"text" => "#{tag['_id']}", "weight" => (tag['value'] * 10).to_i, "url" => "/tag/#{tag['_id']}"}
  end
  @articles = Article.where(:tags => tag).all()
  haml :index
end

get '/article/add' do
  redirect '/' unless @logged_in.role == "admin"
  haml :add_article, :layout => :add_layout
end
post '/article/add' do
  redirect '/' unless @logged_in.role == "admin"
  @article = Article.new
  @article.title = params[:title]
  @article.text = params[:text]
  doc = Hpricot(@article.text)
  index = 1
  extract = ""
  doc.search("//p").each do |element|
    extract += element.to_html
    break if index == 2
    index += 1
  end
  @article.extract = extract
  

  @article.date = Time.now
  @article.author = @logged_in.name
  @article.author_image_url = @logged_in.image
  @article.tags = params[:tags].downcase.delete(" ").split(',')
  @article.save
  
  #extract links out of the text too!
  doc.search("//a").each do |link|
    nLink = Link.where(:url => link.attributes['href'])
    nLink = Link.new unless nLink
    nlink.url = link.attributes['href']
    nLink.text = link.inner_html
    nLink.article_id = @article._id
    nLink.article = @article.title
    nLink.save
  end

  redirect "/article/#{@article.id}"
end
get '/article/:id/edit' do |id|
  redirect '/' unless @logged_in.role == "admin"
  @article = Article.where(:id => id).first()
  haml :edit, :layout => :add_layout 
end
get '/article/:id/delete' do |id|
  redirect '/' unless @logged_in.role == "admin"
  @article = Article.where(:id => id).first()
  @article.delete
  redirect '/'
end
post '/article/:id' do |id|
  redirect '/' unless @logged_in.role == "admin"
  @article = Article.where(:id => id).first()
  @article.title = params[:title]
  @article.text = params[:text]
  doc = Hpricot(@article.text)
  index = 1
  extract = ""
  doc.search("//p").each do |element|
    extract += element.to_html
    break if index == 2
    index += 1
  end
  @article.extract = extract
  @article.author = @logged_in.name
  @article.author_image_url = @logged_in.image
  @article.tags = params[:tags].downcase.delete(" ").split(',')
  @article.save
  #extract links out of the text too!
  doc.search("//a").each do |link|
    nLink = Link.where(:url => link.attributes['href'])
    nLink = Link.new unless nLink
    nlink.url = link.attributes['href']
    nLink.text = link.inner_html
    nLink.article_id = @article._id
    nLink.article = @article.title
    nLink.save
  end
  redirect "/article/#{@article.id}"
end
get '/article/:id' do |id|
  @tags = TagCloud.build.find()
  @thash = []
  @tags.each do |tag|
    @thash << {"text" => "#{tag['_id']}", "weight" => (tag['value'] * 10).to_i, "url" => "/tag/#{tag['_id']}"}
  end
  @article = Article.where(:id => id).first()
  haml :view_article, :ugly => true
end
get '/' do
  @tags = TagCloud.build.find()
  @thash = []
  @tags.each do |tag|
    @thash << {"text" => "#{tag['_id']}", "weight" => (tag['value'] * 10).to_i, "url" => "/tag/#{tag['_id']}"}
  end
  
  @articles = Article.sort(:date.desc).all()
  @home = "active"
  haml :index, :ugly => true
end

get '/*' do
  redirect '/'
end
