class ArticleListController < UIViewController

  def viewDidLoad
    super

    self.title = 'Akorn'
    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self

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


end