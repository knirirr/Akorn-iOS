class NewAccountController < UIViewController
  include BubbleWrap
  attr_accessor :delegate

  def viewDidLoad
    super

    # a nice, plain white background
    view.backgroundColor = UIColor.whiteColor
    self.title = 'Akorn'

    # don't want an account, or already have one? Then get rid of this modal dialog!
    leftButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target: self, action: :cancel_action)
    self.navigationItem.leftBarButtonItem  = leftButton


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
    # don't forget to set size

    # article title
    font = UIFont.boldSystemFontOfSize 20
    @title_view = CentreBlurb.new('Create Account',height,sv_frame.size.width,font).label
    @scroll_view.addSubview(@title_view)

    # description of why an account is needed
    height = @title_view.frame.origin.y + @title_view.frame.size.height + 5
    create_blurb = "Akorn requires an account in order to sync with the server. You may create this by supplying your email address, password and password confirmation below.\n\nIf you\'ve already got an account then please enter your username and password in the main settings app."
    font = UIFont.systemFontOfSize 12
    @blurb_view = Blurb.new(create_blurb, height, sv_frame.size.width,font).label
    @scroll_view.addSubview(@blurb_view)

    # email (this isn't checked by the server)
    email_frame = CGRectMake(5,@blurb_view.frame.origin.y + @blurb_view.frame.size.height + 5,sv_frame.size.width - 10,30)
    @email = UITextField.alloc.initWithFrame(email_frame)
    @email.borderStyle = UITextBorderStyleRoundedRect
    @email.textAlignment = UITextAlignmentCenter
    @email.placeholder = 'Email address'
    @email.autocapitalizationType = false
    @email.delegate = self
    @scroll_view.addSubview(@email)

    # password
    password_frame = CGRectMake(5,@email.frame.origin.y + @email.frame.size.height + 5,sv_frame.size.width - 10,30)
    @password = UITextField.alloc.initWithFrame(password_frame)
    @password.borderStyle = UITextBorderStyleRoundedRect
    @password.textAlignment = UITextAlignmentCenter
    @password.placeholder = 'Password'
    @password.secureTextEntry = true
    @password.delegate = self
    @scroll_view.addSubview(@password)

    # password confirmation
    password_confirmation_frame = CGRectMake(5,@password.frame.origin.y + @password.frame.size.height + 5,sv_frame.size.width - 10,30)
    @password_confirmation = UITextField.alloc.initWithFrame(password_confirmation_frame)
    @password_confirmation.borderStyle = UITextBorderStyleRoundedRect
    @password_confirmation.textAlignment = UITextAlignmentCenter
    @password_confirmation.placeholder = 'Password confirmation'
    @password_confirmation.secureTextEntry = true
    @password_confirmation.delegate = self
    @scroll_view.addSubview(@password_confirmation)

    # submit button!
    @submit_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @submit_button.frame = CGRectZero
    @submit_button.setTitle('Submit!', forState: UIControlStateNormal)
    @submit_button.addTarget(self, action: :submit_action, forControlEvents: UIControlEventTouchUpInside)
    @submit_button.sizeToFit
    @submit_button.center = [sv_frame.size.width/2,  @password_confirmation.frame.origin.y + @password_confirmation.frame.size.height + 20]
    @scroll_view.addSubview(@submit_button)

    # set the height of the scrollview
    @scroll_view.contentSize = [self.view.bounds.size.width, @title_view.frame.size.height + @email.frame.size.height + @password.frame.size.height + @password_confirmation.frame.size.height + @submit_button.frame.size.height + 20]

  end

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
  end

  def cancel_action
    delegate.dismiss_new_account_controller(self)
  end

  def submit_action
    email = @email.text
    pass = @password.text
    pass2 = @password_confirmation.text

    if email.empty? or pass.empty? or pass2.empty?
      App.alert('Account creation failed!', {cancel_button_title: 'OK', message: 'Please complete all the fields in order to submit.'})
      return
    end

    # having got to this point it's time to try a background query. This will be done here rather than in akorn_tasks.rb in order that
    # this controller can be dismissed via cancel_action upon the successful creation of the account whilst allowing the user to keep
    # trying if something goes wrong
    url = AkornTasks.url
    data = {email: email, password1: pass, password2: pass2}

    HTTP.post("#{url}/register", {payload: data}) do |response|    # get the users filters
      # success will be a code 200
      puts "Status code: #{response.status_code}"
      if response.status_code == 200
        #App::Persistence['email'] = email
        #App::Persistence['password'] = pass
        NSUserDefaults.standardUserDefaults['email'] = email
        NSUserDefaults.standardUserDefaults['password'] = pass
        App.alert('Success!', {cancel_button_title: 'OK', message:  'You may now create filters and sync to see articles.'})
        self.dismissViewControllerAnimated(true, completion: lambda {} )
      elsif response.status_code.to_s =~ /40\d/
        puts "Body: #{response.body}"
        json = JSON.parse(response.body.to_str)
        if !json['errors']['email'].nil?
          email_errors = json['errors']['email'].join("\n")
        end
        if !json['errors']['password2'].nil?
          password_errors = !json['errors']['password2'].join("\n")
        end
        errors = [email_errors, password_errors].join("\n")

        App.alert('Account creation failed!', {cancel_button_title: 'OK', message:  errors})
      else
        App.alert("Account creation failed with message: #{response.error_message}")
      end
    end
  end

end