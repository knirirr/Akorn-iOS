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
      end
      # having now got the filters the articles for each can be fetched
      fetch_articles
      puts "Finished getting searches!"
      puts "About to reload the tables!"
      # reload all the tables
      App.delegate.instance_variable_get('@fl_controller').filters = Filter.all
      App.delegate.instance_variable_get('@fl_controller').table.reloadData
      #App.delegate.instance_variable_get('@al_controller').articles = Article.all
      App.delegate.instance_variable_get('@al_controller').table.reloadData
      App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
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



  def create_filters(filters)
    Filter.destroy_all
    # this code sucks. If only I understood how to use blocks, rather than just read descriptions of them and
    # think 'that sort of makes sense, but how would I even use this?'
    new_filter('search_id' => 'all_articles',
               'full' => 'All articles',
               'text' => 'All articles',
               'type' => 'All articles downloaded to this device',
               'term_id' => 'NA')
    new_filter('search_id' => 'saved_articles',
               'full' => 'Saved articles',
               'text' => 'Saved articles',
               'type' => 'Articles starred on this device',
               'term_id' => 'NA')
    filters.each do |k,v|
      #puts "Key: #{k}, Value: #{v[0]}, Full: #{v[0]['full']}"
      filter = v[0]
      filter[:search_id] = k
      new_filter(filter)
    end
  end

  def new_filter(filter)
    puts "Creating: #{filter}"
    filter = Filter.new(:search_id => filter['search_id'],
                        :full => filter['full'],
                        :text => filter['text'],
                        :type => filter['type'],
                        :term_id => filter['id'])
    filter.save
  end

  def fetch_articles
    puts 'Fetching articles!'
    filters = Filter.all
    filters.each do |f|
      case f.search_id
      when 'saved_articles', 'all_articles'
        puts "Got: #{f.search_id}"
      else
        puts "A proper filter: #{f.search_id}"
      end
    end
  end

end

__END__
{"2c57e7b1-2527-4671-a47f-2152eb15da07"=>[{"id"=>"zooniverse", "type"=>"keyword", "text"=>"zooniverse"}], "e3801538-63c6-475d-a434-522fdfe9bb55"=>[{"type"=>"journal", "full"=>"Philosophical Transactions of the Royal Society B: Biological Sciences", "text"=>"Philosophical Transactions of the Royal Society B: Biological Sciences", "id"=>"0500ee362bcc02d7bd84db436bc6f1a6"}], "929dfb4e-de32-4c75-85da-92ee03369dcb"=>[{"type"=>"keyword", "full"=>"Climateprediction.net ", "text"=>"Climateprediction.net ", "id"=>"Climateprediction.net "}], "c729efc7-9d6c-4ae8-894a-03fbf0abeb73"=>[{"type"=>"journal", "full"=>"American Journal of Physics", "text"=>"American Journal of Physics", "id"=>"0500ee362bcc02d7bd84db436bbea9e6"}]}
  columns :id => :integer,
          :search_id => :string,
          :full => :string,
          :text => :string,
          :type => :string,
          :term_id => :integer
