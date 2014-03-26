class Journal
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :id => :integer,
          :journal_id => :string,
          :text => :string,
          :full => :string,
          :type => :string

end

__END__
public static final String COLUMN_ID = "_id";
public static final String COLUMN_JOURNAL_ID = "journal_id";
public static final String COLUMN_TEXT = "text";
public static final String COLUMN_FULL = "full";
public static final String COLUMN_TYPE = "type";