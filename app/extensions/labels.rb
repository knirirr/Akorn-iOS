class Blurb
  attr_accessor :label

  def initialize(text, height, svwidth,font)
    frame = CGRectMake(5,height, svwidth - 5,0)
    @label = UILabel.alloc.initWithFrame(frame)
    @label.text = text
    @label.lineBreakMode = UILineBreakModeWordWrap
    @label.numberOfLines = 0
    @label.font = font
    @label.sizeToFit
  end

end

class CentreBlurb < Blurb

  def initialize(text, height, svwidth,font)
    super
    @label.textAlignment = UITextAlignmentCenter
    @label.center = CGPointMake(svwidth/2,height + (0.5 * @label.frame.size.height))
  end

end

class FilterBlurb
  attr_accessor :widget

  def initialize(type,name,frame)
    @widget = UIView.alloc.initWithFrame(frame)
    @widget.backgroundColor = UIColor.whiteColor
    @widget.layer.cornerRadius = 10.0 # see URL to fix this later
    @label = UILabel.alloc.initWithFrame(frame)
    @label.text = text
    @label.lineBreakMode = UILineBreakModeWordWrap
    @label.numberOfLines = 0
    @label.font = font
    @label.sizeToFit
  end

end