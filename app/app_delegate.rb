class AppDelegate
  C = Courier::Courier.instance

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    C.parcels = [Article, Journal, Filter]

    # the left drawer will show the list of filters, as in Android, the right will show various controls,
    # replacing the Android app's 3-dot overflow menu
    @al_controller = ArticleListController.alloc.init
    @fl_controller = FilterListController.alloc.init
    @op_controller = OptionsController.alloc.init
    main_nav_controller = UINavigationController.alloc.initWithRootViewController(@al_controller)
    left_nav_controller = UINavigationController.alloc.initWithRootViewController(@fl_controller)
    right_nav_controller = UINavigationController.alloc.initWithRootViewController(@op_controller)
    drawer_controller = MMDrawerController.alloc.initWithCenterViewController(main_nav_controller,
                                                                             leftDrawerViewController: left_nav_controller,
                                                                             rightDrawerViewController: right_nav_controller)

    # finally...
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = drawer_controller
    @window.makeKeyAndVisible

    true
  end

end
