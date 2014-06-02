class Filter
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include MotionModel::Validatable

  columns :search_id => :string,
          :search_terms => :array,
          :articles => :array

  #has_many :articles

end

__END__
    new_filter('all_articles',
               [{'full' => 'All articles',
                 'text' => 'All articles',
                 'type' => 'All articles downloaded to this device',
                 'term_id' => 'NA'}])
    new_filter('saved_articles',
               [{'full' => 'Saved articles',
                 'text' => 'Saved articles',
                 'type' => 'Articles starred on this device',
                 'term_id' => 'NA'}])

          # change everything below this to an array type, for multiple-term searches
          #:full => :string,
          #:text => :string,
          #:type => :string,
          #:term_id => :string

