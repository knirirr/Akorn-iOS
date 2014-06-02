class Journal
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :journal_id => :string,
          :text => :string,
          :full => :string,
          :type => :string

end
