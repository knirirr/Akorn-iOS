class AppDelegate
  C = Courier::Courier.instance

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    C.parcels = [Article, Journal, Filter]

    al_controller = ArticleListController.alloc.init
    nav_controller = UINavigationController.alloc.initWithRootViewController(al_controller)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = nav_controller
    @window.makeKeyAndVisible

    true
  end

end
