class FilterListController < UIViewController
  attr_accessor :table, :filters

  def viewDidLoad
    super

    self.title = 'Filters'
    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self
    @filters = Filter.all
    #puts "FL controller loaded #{@filters.length} filters"

    # button to add more filters
    add_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target: self, action: :new_filter)
    add_button.setTintColor(UIColor.whiteColor)
    navigationItem.setLeftBarButtonItem add_button

  end

  def tableView(tableView, numberOfRowsInSection: section)
    @filters.length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= 'FILTERS_IDENTIFIER'
    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier)
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: @reuse_identifier)
    cell.textLabel.text = @filters[indexPath.row].search_terms.collect {|s| s['text']}.join ' | '
    cell.detailTextLabel.text = @filters[indexPath.row].search_terms.collect {|s| s['type']}.join ' | '
    #cell.textLabel.lineBreakMode = UILineBreakModeWordWrap
    #cell.textLabel.numberOfLines = 0
    cell
  end

  #def tableView(tableView, heightForRowAtIndexPath: indexPath)
  #  80 # work out a better way of doing this
  #end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    if !@filters[indexPath.row].nil?
      #puts "Selected filter: #{@filters[indexPath.row].search_id}"
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      App.window.delegate.toggleDrawerSide MMDrawerSideLeft, animated:true, completion: nil
      # pass the id of the current filter back to the main activity so it may reload the table
      App.delegate.instance_variable_get('@al_controller').reload_search(@filters[indexPath.row].search_id)
    end
  end

  def tableView(tableView, editingStyleForRowAtIndexPath: indexPath)
    case @filters[indexPath.row].search_id
      when 'saved_articles', 'all_articles'
        UITableViewCellEditingStyleNone
      else
        UITableViewCellEditingStyleDelete
    end
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    if editingStyle == UITableViewCellEditingStyleDelete
      #f = @filters.delete_at(indexPath.row)
      #p.destroy
      #destroy_filter(f.s)
      #tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
      #tableView.reloadData
      filter_id = @filters[indexPath.row].search_id
      @atask = AkornTasks.new
      @atask.delete_filter(filter_id)
    end
  end


  def new_filter
    new_filter_controller = NewFilterController.alloc.init
    new_filter_controller.delegate = self
    nav_controller = UINavigationController.alloc.initWithRootViewController(new_filter_controller)
    self.presentViewController(nav_controller, animated: true, completion: nil)
  end

  def dismiss_new_filter(new_filter_controller)
    dismissViewControllerAnimated(true, completion: nil)
  end

end