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
    puts "FL controller loaded #{@filters.length} filters"

  end

  def tableView(tableView, numberOfRowsInSection: section)
    @filters.length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= 'FILTERS_IDENTIFIER'
    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier)
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: @reuse_identifier)
    cell.textLabel.text = 'Placeholder title' #@filters[indexPath.row].search_terms[0].text # do a join here
    cell.detailTextLabel.text = 'Placeholder journal' #@filters[indexPath.row].type
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap
    cell.textLabel.numberOfLines = 0
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    80 # work out a better way of doing this
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    if !@filters[indexPath.row].nil?
      puts "Selected filter: #{@filters[indexPath.row].search_id}"
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      App.window.delegate.toggleDrawerSide MMDrawerSideLeft, animated:true, completion: nil
      # pass the id of the current filter back to the main activity so it may reload the table
      App.delegate.instance_variable_get('@al_controller').reload_search(@filters[indexPath.row].search_id)
    end
  end

end