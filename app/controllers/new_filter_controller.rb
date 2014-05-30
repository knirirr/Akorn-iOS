class NewFilterController <  UIViewController
  include BubbleWrap
  attr_accessor :delegate, :offset, :first_responder


  def viewDidLoad
    super

    # a nice, plain white background
    view.backgroundColor = UIColor.whiteColor
    self.title = 'Add Filter'
    @width = self.view.frame.size.width

    # don't want an account, or already have one? Then get rid of this modal dialog!
    leftButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target: self, action: :cancel_action)
    self.navigationItem.leftBarButtonItem  = leftButton
    rightButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target: self, action: :submit_action)
    self.navigationItem.rightBarButtonItem = rightButton

    # the keyboard needs to be dismissed by tapping on the background
    recogniser = UITapGestureRecognizer.alloc.initWithTarget(self, action:'hideKeyboard')
    self.view.addGestureRecognizer(recogniser)

    # if no journals are present yet (due to not having synced) then autocomplete won't work
    @items = Journal.all.collect {|j| j.full }
    if @items.empty?
      App.alert('No journals available!', {cancel_button_title: 'OK', message: 'Please sync and try again.'})
    end

    # list of 'widgets' with filter string and text. These will be read through to concoct a filter when the
    # submit button is pressed...
    @widgets = []
    @tag_count = 1

    # scroll view for the entire contents
    height = 5
    sv_frame = self.view.bounds
    @scroll_view = UIScrollView.alloc.initWithFrame(sv_frame)
    @scroll_view.delegate = self
    @scroll_view.bounces = true
    @scroll_view.scrollsToTop = true
    @scroll_view.alwaysBounceVertical = true
    @scroll_view.pagingEnabled = false
    @scroll_view.scrollEnabled = true
    self.view.addSubview(@scroll_view)

    # description of why an account is needed
    create_blurb = 'Filters may have multiple terms, either journal titles or keywords. Type a term or journal and tap \'add\' to add it. When you\'ve added enough terms you may send them to the server by tapping \'done\'. After adding or removing filters you\'ll need to resync manually.'
    font = UIFont.systemFontOfSize 12
    @blurb_view = Blurb.new(create_blurb, height, sv_frame.size.width,font).label
    @scroll_view.addSubview(@blurb_view)

    ################################################################################
    # search boxes for typing in keyword or journal; journal names to autocomplete #
    ################################################################################

    # keyword box
    height = @blurb_view.frame.origin.y + @blurb_view.frame.size.height + 5
    sb_frame = CGRectMake(5,height,@scroll_view.frame.size.width * 0.8, 30)
    @keyword_search_box = UITextField.alloc.initWithFrame(sb_frame)
    @keyword_search_box.borderStyle = UITextBorderStyleRoundedRect
    @keyword_search_box.textAlignment = UITextAlignmentCenter
    @keyword_search_box.placeholder = 'Type a keyword...'
    @keyword_search_box.delegate = self
    @scroll_view.addSubview(@keyword_search_box)

    # keyword add button
    ab_frame = CGRectMake(@keyword_search_box.frame.origin.x + @keyword_search_box.frame.size.width, height,@scroll_view.frame.size.width * 0.2, 30)
    @keyword_add_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @keyword_add_button.frame = ab_frame
    @keyword_add_button.setTitle('Add', forState: UIControlStateNormal)
    @keyword_add_button.addTarget(self, action: :add_keyword, forControlEvents: UIControlEventTouchUpInside)
    @scroll_view.addSubview(@keyword_add_button)


    # journal box
    height = @keyword_search_box.frame.origin.y + @keyword_search_box.frame.size.height + 5
    sb_frame = CGRectMake(5,height,@scroll_view.frame.size.width * 0.8, 30)
    @journal_search_box = MLPAutoCompleteTextField.alloc.initWithFrame(sb_frame)
    @journal_search_box.autoCompleteTableAppearsAsKeyboardAccessory = true
    @journal_search_box.borderStyle = UITextBorderStyleRoundedRect
    @journal_search_box.textAlignment = UITextAlignmentCenter
    @journal_search_box.placeholder = 'Type a journal title...'
    @journal_search_box.autoCompleteDataSource = self
    @journal_search_box.autoCompleteDelegate = self
    @journal_search_box.setAutoCompleteTableBackgroundColor(UIColor.whiteColor)
    @journal_search_box.delegate = self
    @scroll_view.addSubview(@journal_search_box)

    # journal add button
    ab_frame = CGRectMake(@journal_search_box.frame.origin.x + @journal_search_box.frame.size.width, height,@scroll_view.frame.size.width * 0.2, 30)
    @journal_add_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @journal_add_button.frame = ab_frame
    @journal_add_button.setTitle('Add', forState: UIControlStateNormal)
    @journal_add_button.addTarget(self, action: :add_journal, forControlEvents: UIControlEventTouchUpInside)
    @scroll_view.addSubview(@journal_add_button)

  end

  def autoCompleteTextField(textField, possibleCompletionsForString: string)
    @items
  end

  def autoCompleteTextField(textField, didSelectAutoCompleteString: selectedString,
                                       withAutoCompleteObject: selectedObject,
                                       forRowAtIndexPath: indexPath)
    shift_down = AkornKeyboard.shift_up(textField.frame)
    scroll_frame = @scroll_view.frame
    scroll_frame.origin.y += shift_down
    if @offset
      UIView.animateWithDuration(0.3, animations: lambda { @scroll_view.frame = scroll_frame }, completion: lambda { |finished| @offset = false })
    end
    @first_responder = nil
    textField.resignFirstResponder
  end

  def textFieldShouldReturn(textField)
    shift_down = AkornKeyboard.shift_up(textField.frame)
    scroll_frame = @scroll_view.frame
    scroll_frame.origin.y += shift_down
    if @offset
      UIView.animateWithDuration(0.3, animations: lambda { @scroll_view.frame = scroll_frame }, completion: lambda { |finished| @offset = false })
    end
    @first_responder = nil
    textField.resignFirstResponder
  end

  def textFieldDidBeginEditing(textField)
    @first_responder = textField
    return if @offset
    shift_up = AkornKeyboard.shift_up(textField.frame)
    return if shift_up == 0
    # grab our current frame and modify it so it's visible
    scroll_frame = @scroll_view.frame
    scroll_frame.origin.y -= shift_up

    # animate the replacement of the current frame with the new one
    UIView.animateWithDuration(0.3, animations: lambda { @scroll_view.frame = scroll_frame }, completion: lambda { |finished| @offset = true })
  end

  def hideKeyboard
    if !@first_responder.nil?
      if @offset
        scroll_frame = @scroll_view.frame
        shift_up = AkornKeyboard.shift_up(@first_responder.frame)
        if shift_up != 0
          scroll_frame.origin.y += shift_up
          UIView.animateWithDuration(0.3, animations: lambda { @scroll_view.frame = scroll_frame },
                                     completion: lambda { |finished| @offset = false })
        end
      end

      @first_responder.resignFirstResponder
      @first_responder = nil
    end
  end

  def viewDidUnload
    super
    @items = []
  end

  def cancel_action
    delegate.dismiss_new_filter(self)
  end

  def submit_action
    # this unspeakable horror should look through each of the "widgets" the user has created
    # and check to see if they are journal or keyword searches, then assemble a string to post
    # to the server in order to create the filter. As .to_s for a JSON array produces a string
    # which the server accepts but then misreads I have instead assembled my own string in a
    # tedious manner.
    sending = []
    if @widgets.length == 0
      App.alert('No filters!', {cancel_button_title: 'OK', message:  'Please specify some journal or keyword filters.'})
      return
    end
    @widgets.each do |w|
      hash = {'type' => '', 'id' => '', 'text' => ''}
      w.subviews.each do |s|
        if s.is_a?(UILabel)
          if s.text == 'journal' or s.text == 'keyword'
            hash['type'] = s.text
          else
            journal = Journal.where(:full).eq(s.text).first
            if !journal.nil?
              hash['id'] = journal.journal_id
              hash['full'] = s.text # 'full' isn't used for keyword searches
            else
              hash['id'] = 'NA'
            end
            hash['text'] = s.text
          end
        end
      end
      #sending << JSON.generate(hash)
      sending << hash
    end


    # finally - toooo the server!
    url = AkornTasks.url
    email = NSUserDefaults.standardUserDefaults['email']
    password = NSUserDefaults.standardUserDefaults['password']
    query_data = {query: sending.to_s.gsub(/=>/,':')}
    login_data = {username: email, password: password}

    puts "Sending: #{sending.to_s.gsub(/=>/,':')}"

    HTTP.post("#{url}/login", {payload: login_data}) do |response|    # get the users filters
      #puts "About to get filters!"
      if response.ok?
        cookie = response.headers['Set-Cookie']
        HTTP.post("#{url}/searches", {cookie: cookie, payload: query_data}) do |response|
          if response.status_code == 200
            query_id = JSON.parse(response.body.to_str)['query_id']
            #puts "Query ID: #{query_id}"
            # create a new filter locally
            new_filter = Filter.new(:search_id => query_id, :search_terms => sending, :articles => [])
            new_filter.save
            send_filter = Hash.new
            send_filter[query_id] = new_filter.search_terms
            #App.delegate.instance_variable_get('@fl_controller').filters = Filter.all
            App.delegate.instance_variable_get('@fl_controller').table.reloadData

            # sync to get articles associated with that filter
            # this will need some sort of spinner whilst the sync takes place
            @indicator = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhiteLarge)
            @indicator.center = view.center
            view.addSubview(@indicator)
            @indicator.hidesWhenStopped = true
            @indicator.startAnimating
            @atask = AkornTasks.new
            @atask.fetch_articles(send_filter,@indicator)

            # finally, exit once the filter has been created
            cancel_action
          else
            puts "Error: #{response.status_code.to_s}"
            App.alert("Error #{response.status_code.to_s}", {cancel_button_title: 'OK', message: 'Unfortunately, your filter could not be created. This might be a problem with the server and so you may wish to email for assistance.'})
          end
        end
      elsif response.status_code.to_s =~ /40\d/
        App.alert('Login failed!')
        App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
      else
        App.alert("Login failed with message: #{response.error_message}")
        App.delegate.instance_variable_get('@al_controller').table.pullToRefreshView.stopAnimating
      end
    end
  end

  # this is a bit of a hack, sorry
  def add_journal
    add_filter('journal')
  end

  def add_keyword
    add_filter('keyword')
  end

  def add_filter(type)
    #puts "TC1: #{@tag_count}"
    if type == 'keyword'
      @keyword_search_box.resignFirstResponder
      text = @keyword_search_box.text
      @keyword_search_box.text = nil
    else
      @journal_search_box.resignFirstResponder
      text = @journal_search_box.text
      @journal_search_box.text = nil
    end

    if text.empty?
      return
    end


    # two labels are needed
    frame = CGRectMake(5, 5, @scroll_view.frame.size.width - 40, 0)
    filter_name = UILabel.alloc.initWithFrame(frame)
    filter_name.text = text
    filter_name.font = UIFont.boldSystemFontOfSize 14
    filter_name.textColor = UIColor.whiteColor
    filter_name.numberOfLines = 0
    filter_name.lineBreakMode = UILineBreakModeWordWrap
    filter_name.sizeToFit

    frame_type = CGRectMake(5, filter_name.frame.size.height + 5, filter_name.frame.size.width - 30, 0)
    type_name = UILabel.alloc.initWithFrame(frame_type)
    type_name.text = type
    type_name.font = UIFont.systemFontOfSize 12
    type_name.textColor = UIColor.whiteColor
    type_name.sizeToFit

    total_widget_height = filter_name.frame.size.height + type_name.frame.size.height + 10

    # close button - needs to know the widget height
    frame_close = CGRectMake(@scroll_view.frame.size.width - 35, 5, 20, total_widget_height - 10)
    close_button =  UIButton.buttonWithType(UIButtonTypeRoundedRect)
    close_button.tintColor = UIColor.whiteColor
    close_button.frame = frame_close
    close_button.tag = @tag_count
    close_icon =  Mic.ionIcon(:androidClose, withSize:20)
    close_button.setAttributedTitle(close_icon.attributedString,  forState: UIControlStateNormal)
    close_button.titleLabel.setTextAlignment(UITextAlignmentCenter)
    close_button.addTarget(self,  action: 'remove_widget:',  forControlEvents: UIControlEventTouchUpInside)


    # actually add the widget
    if @widgets.length == 0
      widget_frame = CGRectMake(5,@journal_search_box.frame.origin.y + @journal_search_box.size.height + 5, @width-10,total_widget_height)
    else
      widget_frame = CGRectMake(5,@widgets.last.frame.origin.y + @widgets.last.frame.size.height + 5,@width-10,total_widget_height)
    end
    new_widget = UIView.alloc.initWithFrame(widget_frame)
    new_widget.backgroundColor = '#00a56d'.to_color
    new_widget.layer.cornerRadius = 10.0
    new_widget.tag = @tag_count
    @widgets << new_widget
    new_widget.addSubview(filter_name)
    new_widget.addSubview(type_name)
    new_widget.addSubview(close_button)
    @scroll_view.addSubview(new_widget, animated: true, lambda: {} )

    resize_scrollview
    @tag_count += 1
    #puts "TC2: #{@tag_count}"
  end

  def remove_widget(sender)
    #@widgets.each {|w| puts "Widget tag: #{w.tag}"}
    if @widgets.length > 0
      # pop one off
      # remove from view
      @widgets.each do |w|
        if w.tag == sender.tag
          @widgets.delete(w)
          w.removeFromSuperview
        end
      end
      @widgets.compact!
      move_widgets_up if @widgets.length > 0
      resize_scrollview
    else
      puts 'Nothing to remove'
    end
  end

  def move_widgets_up
    starting_y = @journal_search_box.frame.origin.y + @journal_search_box.size.height + 5
    @widgets.each do |widget|
      index = @widgets.index(widget)
      frame = widget.frame
      if index == 0
        frame.origin.y = starting_y
        UIView.animateWithDuration(0.3, animations: lambda { widget.frame = frame}, completion: nil)
      else
        new_y = @widgets[index - 1].frame.origin.y + @widgets[index - 1].frame.size.height + 5
        frame.origin.y = new_y
        UIView.animateWithDuration(0.3, animations: lambda { widget.frame = frame}, completion: nil)
      end
    end
  end

  def resize_scrollview
    total_height = 5 + @journal_search_box.frame.origin.y + @journal_search_box.size.height
    @widgets.each do |w|
      total_height += w.frame.size.height + 5
    end
    @scroll_view.contentSize = [self.view.bounds.size.width, total_height]
  end

  def dealloc
    #puts "This must be printed #{self}"
    super
  end

end