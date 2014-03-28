class AkornTasks
  include BubbleWrap

  # sync latest filters, articles and journals
  def sync
    # login first
    authCookie = self.login
    url = self.url

    #return if authCookie.nil?

    # get the users filters
    puts "About to get filters!"
    HTTP.get("#{url}/searches", {cookie: authCookie}) do |response|
      filters = JSON.parse(response.body.to_str)
      if !filters.nil?
        create_filters(filters)
        fetch_articles(filters)
      end
      # having now got the filters the articles for each can be fetched
      puts "Finished getting searches!"
      puts "About to reload the tables!"
      # reload all the tables
      App.delegate.instance_variable_get('@fl_controller').filters = Filter.all
      App.delegate.instance_variable_get('@fl_controller').table.reloadData
      # some table reloading has been moved to fetch_articles to make sure
      # it is fired at the last possible moment
      puts 'Sync finished!'
    end
  end

  # get the login token required for all further posts
  def login
    email = NSUserDefaults.standardUserDefaults['email']
    password = NSUserDefaults.standardUserDefaults['password']
    url = self.url
    data = {username: email, password: password}
    cookie = nil

    HTTP.post("#{url}/login", {payload: data}) do |response|
      if response.ok?
        cookie = response.headers['Set-Cookie']
      elsif response.status_code.to_s =~ /40\d/
        App.alert('Login failed!')
      else
        App.alert("Login failed with message: #{response.error_message}")
      end
    end
    cookie
  end

  def url
    server_port = NSUserDefaults.standardUserDefaults['server_port']
    if server_port == 'Development'
      @url = "http://akorn.org:8000/api"
    else
      @url = "http://akorn.org/api"
    end
  end



  # REWORK TO IMPLEMENT AN ARRAY TYPE
  def create_filters(filters)
    Filter.destroy_all
    # this code sucks. If only I understood how to use blocks, rather than just read descriptions of them and
    # think 'that sort of makes sense, but how would I even use this?'
    new_filter('all_articles',
               [{'full' => 'All articles',
                 'text' => 'All articles',
                 'type' => 'All articles downloaded to this device',
                 'term_id' => 'NA'}])
    new_filter('saved_articles',
               [{'full' => 'Saved articles',
                 'text' => 'Saved articles',
                 'type' => 'Articles starred on this device',
                 'term_id' => 'NA'}])
    filters.each do |k,v|
      new_filter(k,v)
    end
  end

  def new_filter(id,array)
    puts "Creating: #{id},#{array}"
    filter = Filter.new(:search_id => id, :search_terms => array)
    filter.save
  end

=begin
  Now the searches have been obtained, it's finally time to get the articles. According to the website devs:
  http://akorn.org/api/articles?skip=0&limit=20&k=hello%7Cmilo&j=f45f136fbd14caa156e5b4b846113877%7Cf45f136fbd14caa156e5b4b8461113e9%7Cf45f136fbd14caa156e5b4b8460b3344
  It looks like the "keyword" type items are being put in the k argument and the journal ids from the "journal"
  type items are being put in the j argument, joined together with whatever %7C is
  un-urlencoded, possibly a "+" symbol.
  ...oh, it's a pipe!
=end

  def fetch_articles(filters)
    puts 'Fetching articles!'
    articles = Article.find { |article| article.favourite != 1 }
    articles.each { |article| article.delete }
    url = self.url

    filters.each do |k,v|
      puts "Articles for filter #{k}, #{v[0]['type']}"
      #if v[0]['type'] == 'keyword'
      #  article_url = "#{url}/articles.xml?skip=0&limit=20&k=#{v[0]['text']}"
      #else
      #  article_url = "#{url}/articles.xml?skip=0&limit=20&j=#{v[0]['id']}"
      #end
    end

     #App.delegate.instance_variable_get('@al_controller').articles = Article.all
     App.delegate.instance_variable_get('@al_controller').table.reloadData
     App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
  end

end

__END__
[{'full' => 'All articles', 'text' => 'All articles', 'type' => 'All articles downloaded to this device', 'term_id' => 'NA'}]
