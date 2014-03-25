class ArticleListController < UIViewController
  attr_accessor :filter_id

  def viewDidLoad
    super

    self.title = 'Akorn'
    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self

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
    1
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= 'ARTICLES_IDENTIFIER'
    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier)
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: @reuse_identifier)
    cell.textLabel.text = 'Article'
    cell.detailTextLabel.text = 'Journal and Authors'
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    puts "Selected row at #{indexPath.row}"
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  end

  def reload_search(filter_id)
    @filter_id = filter_id
    puts "Filter id: #{@filter_id}"
  end


end