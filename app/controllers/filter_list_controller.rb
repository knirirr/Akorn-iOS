class FilterListController < UIViewController

  def viewDidLoad
    super

    self.title = 'Filters'
    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self

    @filters = [
        {:title => 'All articles', :subtitle => 'All articles saved on this device'},
        {:title => 'Saved articles', :subtitle => 'All articles starred on this device'},
    ]

  end

  def tableView(tableView, numberOfRowsInSection: section)
    @filters.length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= 'FILTERS_IDENTIFIER'
    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier)
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: @reuse_identifier)
    cell.textLabel.text = @filters[indexPath.row][:title]
    cell.detailTextLabel.text = @filters[indexPath.row][:subtitle]
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    puts "Selected filter: #{@filters[indexPath.row].inspect}"
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    App.window.delegate.toggleDrawerSide MMDrawerSideLeft, animated:true, completion: nil
    # pass the id of the current filter back to the main activity so it may reload the table
    App.delegate.instance_variable_get('@al_controller').reload_search(indexPath.row)
  end

end