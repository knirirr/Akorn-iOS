class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)

    # get some data
    puts 'Loading data!'
    Article.deserialize_from_file('akorn_articles.dat')
    Filter.deserialize_from_file('akorn_filters.dat')
    Journal.deserialize_from_file('akorn_journals.dat')

    # the left drawer will show the list of filters, as in Android, the right will show various controls,
    # replacing the Android app's 3-dot overflow menu
    @al_controller = ArticleListController.alloc.init
    @fl_controller = FilterListController.alloc.init
    main_nav_controller = UINavigationController.alloc.initWithRootViewController(@al_controller)
    left_nav_controller = UINavigationController.alloc.initWithRootViewController(@fl_controller)
    drawer_controller = MMDrawerController.alloc. initWithCenterViewController(main_nav_controller,
                                                                               leftDrawerViewController: left_nav_controller,
                                                                               rightDrawerViewController: nil)

    # N.B. this causes sliding the drawer to work in all circumstances, which might not be ideal if a user
    # selects a filter when looking at an article detail
    #drawer_controller.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll
    #drawer_controller.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll

    UINavigationBar.appearance.barTintColor = '#00a56d'.to_color
    UINavigationBar.appearance.setTitleTextAttributes({
      UITextAttributeFont => UIFont.fontWithName('Helvetica Neue', size:24),
      UITextAttributeTextShadowColor => UIColor.colorWithWhite(0.0, alpha:0.4),
      UITextAttributeTextColor => UIColor.whiteColor
    })
    UINavigationBar.appearance.tintColor = UIColor.whiteColor # white buttons

    # finally...
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = drawer_controller
    @window.makeKeyAndVisible

    true
  end


  def applicationDidEnterBackground(application)
    Article.serialize_to_file('akorn_articles.dat')
    Filter.serialize_to_file('akorn_filters.dat')
    Journal.serialize_to_file('akorn_journals.dat')
    puts 'Data saved!'
  end


end
