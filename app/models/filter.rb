class Filter
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :id => :integer,
          :search_id => :string,
          :full => :string,
          :text => :string,
          :type => :string,
          :term_id => :integer

  has_many :articles

end

__END__

  public static final String COLUMN_ID = "_id";
  public static final String COLUMN_SEARCH_ID = "search_id"; // I'm assuming that there's a BSON ID on the server...
  public static final String COLUMN_FULL = "full";
  public static final String COLUMN_TEXT = "text";
  public static final String COLUMN_TYPE = "type";
  public static final String COLUMN_TERM_ID = "term_id";
