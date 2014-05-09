class ArticleListController < UIViewController
  attr_accessor :filter_id, :table, :articles

  def viewDidLoad
    super

    self.title = 'Articles'
    navbar_height = 64
    #table_frame = CGRectMake(0,navbar_height, self.view.bounds.size.width, self.view.bounds.size.height - navbar_height)
    #@table = UITableView.alloc.initWithFrame(table_frame)
    #@table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    #self.view.addSubview(@table)
    @table = UITableView.new
    @table.dataSource = self
    @table.delegate = self
    @table.addPullToRefreshWithActionHandler(
        Proc.new do
          load_data
        end
    )
    reload_search(@filter_id)

    # investigate this to see what can be done about re-drawing the view on orientation
    # changes; at present these are disabled, but could be re-enabled.
    Motion::Layout.new do |layout|
      layout.view view
      layout.subviews "table" => @table
      layout.metrics "top" => navbar_height, "width" => self.view.frame.size.width, "height" => self.view.frame.size.height
      layout.vertical "|-top-[table(==height)]"
      layout.horizontal "|[table(==width)]|"
    end



    # buttons for the drawers
    # The MMDrawerController should be the delegate, so the toggleDrawerSide method is passed
    # to that in the show_filters/options methods by means of bubble-wrap's 'App'
    leftDrawerButton = MMDrawerBarButtonItem.alloc.initWithTarget self, action: 'show_filters'
    navigationItem.setLeftBarButtonItem leftDrawerButton, animated: true

  end

  def show_filters
    App.window.delegate.toggleDrawerSide MMDrawerSideLeft, animated:true, completion: nil
  end

  def tableView(tableView, numberOfRowsInSection: section)
    #@articles.length
    # sum of number of articles per publication date
    #@articles.values.collect {|v| v.length}.reduce(:+)
    rows_for_section(section).count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= 'ARTICLES_IDENTIFIER'
    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier)
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: @reuse_identifier)
    if !@articles.empty?
      cell.textLabel.text = row_for_index_path(indexPath).title
      cell.detailTextLabel.text = row_for_index_path(indexPath).journal
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      if row_for_index_path(indexPath).favourite == 1
        cell.setTextColor(UIColor.orangeColor)
      else
        cell.setTextColor(UIColor.blackColor)
      end
    end
    #cell.textLabel.lineBreakMode = UILineBreakModeWordWrap
    #cell.textLabel.numberOfLines = 0
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    #puts "Selected row at #{indexPath.row}"
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    view_controller = ArticleViewController.alloc.init
    # set article ID here
    view_controller.article_id = row_for_index_path(indexPath).article_id
    self.navigationController.pushViewController(view_controller, animated: true)
  end

  def tableView(tableView, titleForHeaderInSection: section)
    sections[section]
  end

  def sections
    @articles.keys.sort {|x,y| y <=> x }
  end

  def rows_for_section(section_index)
    @articles[self.sections[section_index]]
  end

  def row_for_index_path(index_path)
    rows_for_section(index_path.section)[index_path.row]
  end

  def numberOfSectionsInTableView(tableView)
    self.sections.count
  end

  def reload_search(filter_id)
    @filter_id = filter_id
    puts "Reloading search: #{filter_id}"
    @articles = {}
    if filter_id.nil? || filter_id == 'all_articles'
      orig_array = Article.all
    else
      filter = Filter.where('search_id').eq(filter_id).first
      orig_array = []
      filter.articles.each do |aid|
        orig_array << Article.where(:article_id).eq(aid).first
      end
    end
    # may crash here in circumstances where an old filter is hanging around -
    # this needs to be investigated later
    if !orig_array.nil?
      @articles = orig_array.group_by{|h| h.published_at_date}
    end

    #puts "Articles: #{@articles}"
    @table.reloadData
  end

  def load_data
    email = NSUserDefaults.standardUserDefaults['email']
    password = NSUserDefaults.standardUserDefaults['password']
    if email.empty? and password.empty?
      @table.pullToRefreshView.stopAnimating
      App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
      new_account_controller = NewAccountController.alloc.init
      new_account_controller.delegate = self
      nav_controller = UINavigationController.alloc.initWithRootViewController(new_account_controller)
      self.presentViewController(nav_controller, animated: true, completion: nil)
    else
      @atask = AkornTasks.new
      @atask.sync(@filter_id)
    end
  end

  def dismiss_new_account_controller(new_account_controller)
    dismissViewControllerAnimated(true, completion: nil)
  end


end