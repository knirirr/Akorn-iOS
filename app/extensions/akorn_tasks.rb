class AkornTasks
  attr_accessor :filter_id
  include BubbleWrap

  # sync latest filters, articles and journals
  def sync(filter_id)
    @filter_id = filter_id
    # login first
    url = AkornTasks.url
    email = NSUserDefaults.standardUserDefaults['email']
    password = NSUserDefaults.standardUserDefaults['password']
    data = {username: email, password: password}
    cookie = nil


    HTTP.post("#{url}/login", {payload: data}) do |response|    # get the users filters
      #puts "About to get filters!"
      if response.ok?
        cookie = response.headers['Set-Cookie']
        HTTP.get("#{url}/searches", {cookie: @auth_cookie}) do |response|
          filters = JSON.parse(response.body.to_str)
          if !filters.nil?
            create_filters(filters)
            fetch_articles(filters)
            fetch_journals
          end
          # having now got the filters the articles for each can be fetched
          #puts 'Finished getting searches!'
          #puts 'About to reload the tables!'
          # reload all the tables
          App.delegate.instance_variable_get('@fl_controller').filters = Filter.all
          App.delegate.instance_variable_get('@fl_controller').table.reloadData
          #App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
          # some table reloading has been moved to fetch_articles to make sure
          # it is fired at the last possible moment
          #puts 'Tables reloaded!'
          #puts 'Sync finished!'
        end
      elsif response.status_code.to_s =~ /40\d/
        App.alert('Login failed!')
        App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
      else
        App.alert("Login failed with message: #{response.error_message}")
        App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
      end
    end
  end


  def self.url
    server_port = NSUserDefaults.standardUserDefaults['server_port']
    if server_port == 'Development'
      @url = "http://akorn.org:8000/api"
    else
      @url = "http://akorn.org/api"
    end
  end



  # This dodgy code should purge and re-create all filters except the two default ones
  def create_filters(filters)
    puts "New filters: #{filters.length}"
    @delete = []
    @keep = []
    Filter.all.each do |f|
      #puts "SID: #{f.search_id}, #{f.search_terms}"
      unless f.search_id == 'all_articles' or f.search_id == 'saved_articles'
        #puts "Deleting: #{f.search_id}, #{f.search_terms}"
        @delete << f.search_id
      end
    end
    # the two default filters need to be created if this is the first run and they don't
    # already exist
    if Filter.where(:search_id).eq('all_articles').first.class != Filter
      new_filter('all_articles',
               [{'text' => 'All articles',
                 'type' => 'All articles downloaded to this device',
                 'id' => 'NA'}])
                 #'term_id' => 'NA'}])
    end
    if Filter.where(:search_id).eq('saved_articles').first.class != Filter
      new_filter('saved_articles',
               [{'text' => 'Saved articles',
                 'type' => 'Articles starred on this device',
                 'term' => 'NA'}])
                 #'term_id' => 'NA'}])
    end

    # finally create new filters for searches which have just been synced
    filters.each do |k,v|
      new_filter(k,v)
    end

    #puts "Keep: #{@keep}"
    #puts "Delete: #{@delete}"
    #puts "Really delete: #{@delete - @keep}"

    @obsolete = @delete - @keep
    @obsolete.each {|f| Filter.where(:search_id).eq(f).first.delete}

  end

  def new_filter(id,array)
    if Filter.where(:search_id).eq(id).first.class == Filter
      #puts "Already got: #{id}, #{array}"
      @keep << id
      return
    else
      #puts "Creating: #{id},#{array}"
      filter = Filter.new(:search_id => id, :search_terms => array, :articles => [])
      filter.save
    end
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
    #puts 'Fetching articles!'
    url = AkornTasks.url
    articles = Article.find { |article| article.favourite != 1 }
    articles.each { |article| article.delete }
    filters.each do |k,v|
      article_url = "#{url}/articles.xml?skip=0&limit=20"
      v.each do |section|
        #puts "Articles for filter #{k}, #{section['type']}"
        if section['type'] == 'keyword'
          article_url += "&k=#{section['text']}"
        else
          article_url += "&j=#{section['id']}"
        end
      end
      # fetch all the articles
      #puts "Final URL: #{article_url}"
      HTTP.get(article_url, {cookie: @auth_cookie}) do |response|
        #filters = JSON.parse(response.body.to_str)
        #puts "Body: #{response.body.to_str}"
        # authors, id, journal, abstract, link, date_published
        next if response.body.nil?

        rxml = RXMLElement.elementFromXMLString(response.body.to_str, encoding:NSUTF8StringEncoding)
        rxml.iterate('article', usingBlock:lambda { |a|
          authors = []
          fields = {
            'id' => '',
            'title' => '',
            'journal' => '',
            'abstract' => '',
            'link' => '',
            'date_published' => ''
          }
          # authors must be put into an array and joined to produce a single author string with commas
          a.iterate('authors', usingBlock:lambda { |b|
            b.iterate('author', usingBlock:lambda { |c|
              #puts "C: #{c.text}"
              authors << c.text
            })
          })
          # for each other field only the string is required, although for the date this will be split
          # into date and time. Date will be used for the key of a hash so that the table can be displayed
          # with section headers by date
          fields.each_key do |key|
            a.iterate(key, usingBlock:lambda { |value|
              fields[key] = value.text
            })
          end
          ## create the new article and save it
          existing_article = Article.where(:article_id).eq(fields['id']).first
          if existing_article.nil?
            new_article = Article.new(:title => fields['title'],
                                      :article_id => fields['id'],
                                      :journal => fields['journal'],
                                      :link => fields['link'],
                                      :abstract => fields['abstract'],
                                      :authors => authors.join(', '),
                                      :published_at_date => fields['date_published'].split('T')[0],
                                      :published_at_time => fields['date_published'].split('T')[1],
                                      :read => 0,
                                      :favourite => 0)
            new_article.save
            filter = Filter.where(:search_id).eq(k).first
            if !filter.articles.include?(new_article.article_id)
              filter.articles << new_article.article_id
            end
            filter.save
          end
        })
        #puts "Reloading!"
        # this is here to make sure the table is reloaded after each filter's articles
        # are synced; it's done this way because all the network calls are async, rather
        # than this whole class is it is in the Android app
        App.delegate.instance_variable_get('@al_controller').reload_search('all_articles')
      end
    end

  end

  # this should do an async filter delete and update the filter_list_controller's table
  def delete_filter(filter_id)
    url = AkornTasks.url
    email = NSUserDefaults.standardUserDefaults['email']
    password = NSUserDefaults.standardUserDefaults['password']

    data = {username: email, password: password}
    cookie = nil

    HTTP.post("#{url}/login", {payload: data}) do |response|    # get the users filters
      #puts "About to get filters!"
      if response.ok?
        cookie = response.headers['Set-Cookie']
        HTTP.get("#{url}/remove_search?query_id=#{filter_id}", {cookie: @auth_cookie}) do |response|
          # success will be a code 204
          puts "Status code: #{response.status_code}"
          if response.status_code == 204
            # refresh the list if it works
            filter = Filter.where(:search_id).eq(filter_id).first
            filter.delete
            App.delegate.instance_variable_get('@fl_controller').filters = Filter.all
            App.delegate.instance_variable_get('@fl_controller').table.reloadData
            #App.delegate.instance_variable_get('@al_controller').table.reloadData
          else
            App.alert('Failed to delete filter!')
          end
        end
      elsif response.status_code.to_s =~ /40\d/
        App.alert('Login failed!')
        App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
      else
        App.alert("Login failed with message: #{response.error_message}")
        App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
      end
    end
  end

  # I'm not so worried about this one finishing before the sync notification finishes
  def fetch_journals
    url = AkornTasks.url
    on_device = Journal.all.collect {|j| j.journal_id}
    #puts "OD: #{on_device.length}"
    on_server = []
    HTTP.get("#{url}/journals") do |response|
      if response.status_code == 200
        journals = JSON.parse(response.body.to_str)
        journals.each do |j|
          on_server << j['id']
          #puts "Journal: #{j['id']}"
          #if on_device.include?(j['id'])
          #  next
          #else
          if Journal.where(:journal_id).eq(j['id']).length < 1
            new_journal = Journal.new(:journal_id => j['id'],
                                      :text => j['text'],
                                      :full => j['full'],
                                      :type => j['type'])
            #puts "NJ: #{new_journal}"
            new_journal.save
          end
        end



        no_longer_needed = on_device - on_server
        #puts "No longer needed: #{no_longer_needed}"
        puts "On server: #{on_server.length}"
        puts "On device: #{on_device.length}"
        puts "No longer needed: #{no_longer_needed.length}"
        begin
          no_longer_needed.each do |j|
            puts "Trying to delete: #{j}"
            Journal.where(:journal_id).eq(j).first.delete
          end
        rescue Exception => e
          puts "Failed to delete journal: #{e.message}"
        end

      else
        puts "Failed to get journals: #{response.status_code}"
      end
      App.delegate.instance_variable_get('@al_controller').table.reloadData
      App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
    end
  end

end

__END__
[{'full' => 'All articles', 'text' => 'All articles', 'type' => 'All articles downloaded to this device', 'term_id' => 'NA'}]
