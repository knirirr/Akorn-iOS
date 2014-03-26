class Article
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :id => :integer,
          :title => :string,
          :article_id => :string,
          :journal => :string,
          :link => :string,
          :abstract => :string,
          :authors => :string,
          :published_at_date => :string,
          :published_at_time => :string,
          :read => :integer,
          :favourite => :integer

  belongs_to :filter
end

__END__
  public static final String COLUMN_ID = "_id";
  public static final String COLUMN_TITLE = "title";
  public static final String COLUMN_ARTICLE_ID = "article_id";
  public static final String COLUMN_JOURNAL = "journal";
  public static final String COLUMN_LINK = "link";
  public static final String COLUMN_ABSTRACT = "abstract";
  public static final String COLUMN_AUTHORS = "authors";
  public static final String COLUMN_DATE = "date_published";
  public static final String COLUMN_TIME = "time_published";
  public static final String COLUMN_READ = "read";
  public static final String COLUMN_FAVOURITE = "favourite";
