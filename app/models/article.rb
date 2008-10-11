class Article
  include DataMapper::Resource

  #############################################################################
  # Properties
  #############################################################################
  property :id,              Integer,  :serial => true
  property :version,         Integer
  property :title,           String,   :length => 255
  property :sub_title,       String,   :length => 255
  property :slug,            Slug,     :length => 255, :index => true # Will store an SEO friendly slug
  property :state,           String,   :length => 16  # we'll use state_machine on this
  property :parent_id,       Integer   # eg. 4 part series of related articles.    
  property :rating,          Integer   # how good of a Article the user thinks it is 1..10
  property :publised_at,     DateTime  # Allow them to set publish date
  property :markup,          String,   :length => 32
  property :raw,             Text
  property :html,            Text
  property :created_at,      DateTime, :index => true
  property :updated_at,      DateTime, :index => true
  property :deleted_at,      DateTime, :index => true
  property :published_by_id, Integer,  :index => true
  property :created_by_id,   Integer,  :index => true
  property :updated_by_id,   Integer,  :index => true
  property :deleted_by_id,   Integer,  :index => true
  
  # is :versioned, version

  #############################################################################
  # Relationships
  #############################################################################
  has 1, :created_by, :child_key => [:created_by_id], :class_name => "User"
  has 1, :updated_by, :child_key => [:updated_by_id], :class_name => "User"
  has 1, :deleted_by, :child_key => [:deleted_by_id], :class_name => "User"

  has n, :comments
  has n, :blog_articles
  has n, :blogs, :through => :blog_articles
  has n, :article_authors
  has n, :authors, :through => :article_authors

  #############################################################################
  # Validations
  #############################################################################
  validates_present :raw
  validates_present :title
  
  #validates_within :markup,  :set => Formatter.formatters, :if => Proc.new {|m| m.send(:published?)}
  #validates_format :slug,    :with => /^[a-z0-9-]+$/,      :if => Proc.new {|m| m.send(:published?)}
  #validates_block  :html,    :logic  => Proc.new{|m| m.formatted_body != FORMATTING_ERROR }, 

  validates_with_block :raw do
    begin
      if markup == "textile"
        self.html = RedCloth.new(@raw).to_html
      elsif markup == "markdown"
        self.html = BlueCloth.new(@raw).to_html
      else
        return [false, "No markup was specified."]
      end
    rescue Exception => e
      return [false, e.message]
    end
    true
  end

  #############################################################################
  is_state_machine  
  #############################################################################

  # See note on start_if_not_new below
  # before :save, :start_if_not_new
  
  ### 
  # State Machine
  #
  
  States = %w(draft preview published archived deleted)
  
  is :state_machine, :initial => :new, :column => :state do
    state :draft,     :enter => Proc.new {|entity| entity.change_state(:draft)}
    state :preview,   :enter => Proc.new {|entity| entity.change_state(:preview)}
    state :published, :enter => Proc.new {|entity| entity.change_state(:published)}
    state :archived,  :enter => Proc.new {|entity| entity.change_state(:archived)}
    state :deleted,   :enter => Proc.new {|entity| entity.change_state(:deleted)}
  
    # This should be triggered automatically when someone first saves an article.
    #event :start do
    #  transition :from => :draft,  :to => :preview
    #end
    
    event :publish do
      transition :from => :draft,     :to => :published
      transition :from => :preview,   :to => :published
    end
    
    event :preview do
      transition :from => :draft,     :to => :preview
    end
    
    event :archive do
      transition :from => :draft,     :to => :archived
      transition :from => :preview,   :to => :archived
      transition :from => :published, :to => :archived
    end
    
    event :unarchive do
      transition :from => :archived, :to => :published
    end
    
    event :delete do
      transition :from => :draft,     :to => :deleted
      transition :from => :preview,   :to => :deleted
      transition :from => :published, :to => :deleted
    end
    
  end
  
  # When we change state we run these call backs
  # We could probably inject a bit of audit logging here so we keep track of date and times of state changes
  def change_state(state)
    self.send("callback_#{state.to_s}")
    save!
  end
  
  # Callbacks
  
  def callback_draft
    draft!
  end
  
  def callback_preview
    preview!
  end
  
  def callback_published
    published!
  end
  
  def callback_archived
    archived!
  end
  
  def callback_deleted
    deleted!
  end

end
