class ArticleViewController < UIViewController
  attr_accessor :article_id

  # BubbleWrap UIActivityViewController needed for sharing options

  def viewDidLoad
    super

    self.title = 'Article view'
    view.backgroundColor = UIColor.whiteColor
    rightDrawerButton = MMDrawerBarButtonItem.alloc.initWithTarget self, action: 'show_options'
    navigationItem.setRightBarButtonItem rightDrawerButton, animated: true

  end

  def show_options
    App.window.delegate.toggleDrawerSide MMDrawerSideRight, animated:true, completion: nil
  end

end