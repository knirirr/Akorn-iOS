class OptionsController < UIViewController

  def viewDidLoad
    super

    self.title = 'Options'
    view.backgroundColor = UIColor.whiteColor
    width = view.frame.size.width

    # filters
    # settings
    # website
    # changelog

    # filters button
    @filter_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @filter_button.frame = CGRectMake(20,72,0,0)
    @filter_button.setTitle('Edit filters', forState: UIControlStateNormal)
    @filter_button.addTarget(self,  action: :edit_filters,  forControlEvents: UIControlEventTouchUpInside)
    @filter_button.sizeToFit
    view.addSubview(@filter_button)

    # options button
    @settings_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @settings_button.frame = CGRectMake(20,@filter_button.frame.origin.y + @filter_button.frame.size.height + 12 ,0,0)
    @settings_button.setTitle('Settings', forState:  UIControlStateNormal)
    @settings_button.addTarget(self, action: :edit_settings, forControlEvents: UIControlEventTouchUpInside)
    @settings_button.sizeToFit
    view.addSubview(@settings_button)

    # website
    @website_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @website_button.frame =   CGRectMake(20,@settings_button.frame.origin.y + @settings_button.frame.size.height + 12 ,0,0)
    @website_button.setTitle('Website', forState:  UIControlStateNormal)
    @website_button.addTarget(self, action: :view_website, forControlEvents: UIControlEventTouchUpInside)
    @website_button.sizeToFit
    view.addSubview(@website_button)

    # a changelog button may eventually have to be added here
    # should there perhaps be an image here?

  end

  def edit_filters
    # modal filter editing controller
    puts 'Would edit filters'
    close_drawer
  end

  def edit_settings
    # modal options controller?
    alert = UIAlertView.alloc.initWithTitle('Settings',
                                            message: 'Please use the main iOS settings app',
                                            delegate: self,
                                            cancelButtonTitle: 'OK',
                                            otherButtonTitles: nil)
    alert.show

  close_drawer
  end

  def view_website
    App.open_url('http://akorn.org')
  end

  def view_changelog
    puts 'Would view changelog'
    close_drawer
  end

  def close_drawer
    App.window.delegate.toggleDrawerSide MMDrawerSideRight, animated:true, completion: nil
  end

end