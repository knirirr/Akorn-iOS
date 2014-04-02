class ArticleViewController < UIViewController
  attr_accessor :article_id

  # BubbleWrap UIActivityViewController needed for sharing options

  def viewDidLoad
    super

    # we wouldn't get very far without this
    @article = Article.where(:article_id).eq(@article_id).first

    # favourites filter loaded here as it might be needed
    @favourites_filter = Filter.where('search_id').eq('saved_articles').first

    # no title so there's room for buttons
    #self.title = 'Article'

    # buttons to share, visit website and bookmark this article
    # https://github.com/clearsightstudio/ProMotion/issues/386
    share_image = Mic.ionIcon(:ios7UploadOutline, withSize: 22).imageWithSize(CGSizeMake(20, 20))
    site_image = Mic.ionIcon(:ios7WorldOutline, withSize: 22).imageWithSize(CGSizeMake(20, 20))
    favourite_image = Mic.ionIcon(:ios7StarOutline, withSize: 22).imageWithSize(CGSizeMake(20, 20))
    view.backgroundColor = UIColor.whiteColor
    share_button = UIBarButtonItem.alloc.initWithImage(share_image, style: UIBarButtonItemStyleBordered, target: self, action: :sharing_action)
    share_button.setTintColor(UIColor.whiteColor)
    site_button = UIBarButtonItem.alloc.initWithImage(site_image, style: UIBarButtonItemStyleBordered, target: self, action: :visit_journal)
    site_button.setTintColor(UIColor.whiteColor)
    @favourite_button = UIBarButtonItem.alloc.initWithImage(favourite_image, style: UIBarButtonItemStyleBordered, target: self, action: :toggle_favourite)
    if @article.favourite == 1
      @favourite_button.setTintColor(UIColor.orangeColor)
    else
      @favourite_button.setTintColor(UIColor.whiteColor)
    end
    navigationItem.rightBarButtonItems = [@favourite_button, site_button, share_button]



    # scroll view for the entire contents
    height = 5
    sv_frame = self.view.bounds
    @scroll_view = UIScrollView.alloc.initWithFrame(sv_frame)
    @scroll_view.delegate = self
    @scroll_view.bounces = true
    @scroll_view.scrollsToTop = true
    @scroll_view.alwaysBounceVertical = true
    @scroll_view.pagingEnabled = false
    @scroll_view.scrollEnabled = true
    self.view.addSubview(@scroll_view)
    # don't forget to set size

    # article title
    font = UIFont.boldSystemFontOfSize 20
    @title_view = Blurb.new(@article.title,height,sv_frame.size.width,font).label
    @scroll_view.addSubview(@title_view)

    # article authors
    height = @title_view.frame.origin.y + @title_view.frame.size.height + 5
    font = UIFont.systemFontOfSize 15
    @auth_view = Blurb.new(@article.authors,height,sv_frame.size.width,font).label
    @scroll_view.addSubview(@auth_view)

    # article journal
    height = @auth_view.frame.origin.y + @auth_view.frame.size.height + 5
    font = UIFont.italicSystemFontOfSize 15
    text = "#{@article.journal}, #{@article.published_at_date} #{@article.published_at_time}"
    @journal_view = Blurb.new(text,height,sv_frame.size.width,font).label
    @scroll_view.addSubview(@journal_view)

    # article link
    height = @journal_view.frame.origin.y + @journal_view.frame.size.height + 5
    font = UIFont.systemFontOfSize 12
    @article_link = Blurb.new(@article.link,height,sv_frame.size.width,font).label
    @scroll_view.addSubview(@article_link)

    # article abstract
    height = @article_link.frame.origin.y + @article_link.frame.size.height + 5
    font = UIFont.systemFontOfSize 12
    @abstract_view = Blurb.new(@article.abstract.gsub(/\n\s+/,' '),height,sv_frame.size.width,font).label
    @scroll_view.addSubview(@abstract_view)


    # essential to allow proper scrolling if the abstract is too large to fit on the screen
    @scroll_view.contentSize = [sv_frame.size.width, @abstract_view.frame.origin.y + @abstract_view.frame.size.height]
  end

  def visit_journal
    App.open_url(@article.link)
  end

  def sharing_action
    #puts 'Link sharing!'
    #App.alert('Share Link', {message: 'This code hasn\'t been written yet. Sorry.', cancel_button_title: 'FRC!'})
    activityItems = []
    #[:title, :authors, :journal, :link, :abstract].each do |stuff|
    [:title, :link].each do |stuff|
      if stuff == :journal
        activityItems << "#{@article.send(stuff)}, #{@article.send(:published_at_date)} #{@article.send(:published_at_time)}\n"
      elsif stuff == :abstract
        activityItems << @article.send(stuff).gsub(/\n\s+/,' ') + "\n"
      else
        activityItems << @article.send(stuff) + "\n"
      end
    end
    activityItems << "Shared from the Akorn app for iOS\n"
    sharing_controller = UIActivityViewController.alloc.initWithActivityItems(activityItems, applicationActivities: nil)
    self.presentViewController(sharing_controller, animated: true, completion: nil)
  end

  def toggle_favourite
    if @article.favourite == 0
      @article.favourite = 1
      @article.save
      @favourite_button.setTintColor(UIColor.orangeColor)
      @favourites_filter.articles << @article.article_id
      @favourites_filter.save
      #puts "Making favourite: #{@favourites_filter.articles}, #{@article.favourite}"
    elsif @article.favourite == 1
      @article.favourite = 0
      @article.save
      @favourite_button.setTintColor(UIColor.whiteColor)
      @favourites_filter.articles.delete @article.article_id
      @favourites_filter.save
      #puts "Unmaking favourite: #{@favourites_filter.articles}, #{@article.favourite}"
    end
    App.delegate.instance_variable_get('@al_controller').table.reloadData
  end

end
