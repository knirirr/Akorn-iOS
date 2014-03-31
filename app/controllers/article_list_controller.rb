class ArticleListController < UIViewController
  attr_accessor :filter_id, :table, :articles

  def viewDidLoad
    super

    self.title = 'Articles'
    navbar_height = 64
    table_frame = CGRectMake(0,navbar_height, self.view.bounds.size.width, self.view.bounds.size.height - navbar_height)
    @table = UITableView.alloc.initWithFrame(table_frame)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self
    @table.addPullToRefreshWithActionHandler(
        Proc.new do
          load_data
        end
    )

    #@articles = [
    #    {:title => 'Article #1', :journal => 'Journal #1'},
    #]
    #@count = 1
    reload_search(@filter_id)


    # buttons for the drawers
    # The MMDrawerController should be the delegate, so the toggleDrawerSide method is passed
    # to that in the show_filters/options methods by means of bubble-wrap's 'App'
    leftDrawerButton = MMDrawerBarButtonItem.alloc.initWithTarget self, action: 'show_filters'
    navigationItem.setLeftBarButtonItem leftDrawerButton, animated: true
    rightDrawerButton = MMDrawerBarButtonItem.alloc.initWithTarget self, action: 'show_options'
    navigationItem.setRightBarButtonItem rightDrawerButton, animated: true


  end

  def show_filters
    App.window.delegate.toggleDrawerSide MMDrawerSideLeft, animated:true, completion: nil
  end

  def show_options
    App.window.delegate.toggleDrawerSide MMDrawerSideRight, animated:true, completion: nil
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @articles.length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= 'ARTICLES_IDENTIFIER'
    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier)
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: @reuse_identifier)
    if !@articles.empty?
      cell.textLabel.text = @articles[indexPath.row].title
      cell.detailTextLabel.text = @articles[indexPath.row].journal
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
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
    self.navigationController.pushViewController(view_controller, animated: true)
  end

  def reload_search(filter_id)
    @filter_id = filter_id
    #puts "Reloading search: #{filter_id}"
    if filter_id.nil? || filter_id == 'all_articles'
      @articles = Article.order(:published_at_date).all
    else
      filter = Filter.where('search_id').eq(filter_id).first
      @articles = []
      filter.articles.each do |aid|
        @articles << Article.order(:published_at_date).where(:article_id).eq(aid).first
      end
    end
    @table.reloadData
  end

  def load_data
    @atask = AkornTasks.new
    @atask.sync(@filter_id)
    #Dispatch::Queue.main.after(1) {
    #Dispatch::Queue.main.async {
      #@count += 1
      #@articles << {:title => "Article ##{@count}", :journal => "Journal ##{@count}"}
      #puts "Articles: #{@articles.inspect}"
      #output = AkornTasks.sync
      #puts "Got output: #{output}"
      #@atask = AkornTasks.new
      #@atask.sync
      #puts 'load_data finished!'
      #@table.reloadData
      #App.delegate.instance_variable_get('@fl_controller').filters = Filter.all
      #App.delegate.instance_variable_get('@fl_controller').table.reloadData
      #@table.pullToRefreshView.stopAnimating
    #}
  end


end