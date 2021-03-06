class Guide < ActiveRecord::Base
  PUBLISHED = 'Published'
  DRAFT = 'Draft'
  UNPUBLISHED = 'Unpublished'
  C3 = 'c3'
  PARTISAN = 'partisan'
  NONPARTISAN = 'c3'

  has_many :contests, :dependent => :destroy, :include => :choices, :order => 'contests.position'
  has_many :links, :dependent => :destroy
  has_one :image, :dependent => :destroy
  has_one :attached_pdf, :dependent => :destroy

  belongs_to :user
  belongs_to :theme

  has_many :pledges
  has_many :members, :through => :pledges, :source => :user

  has_many :comments, :order => 'created_at DESC'

  before_validation :create_permalink
  validates_presence_of :name, :date, :city, :state

  validates_format_of :permalink, :with => /^[-_[:alnum:]]+$/
  validates_uniqueness_of :permalink, :scope => :date, :message => "not unique for this election date"

  def validate
    if permalink.nil? || permalink.empty?
      if name.nil? || name.empty?
        errors.add_to_base "Did i mention that name can't be blank? (permalink error)"
      else
        errors.add('permalink', "can't be blank")
      end
    end
  end

  def after_save
    GuidePromoter.deliver_approval_request( { :guide => self } ) if @recently_published && c3?
    GuidePromoter.deliver_publish_notification(self) if @recently_published
  end
=begin
  acts_as_ferret :fields => { :name => {:boost => 3}, 
                              :city => {},
                              :state => {},
                              :description => {:boost => 2.5},
                              :index_contest_choice_titles => {:boost => 2},
                              :index_contest_choice_descriptions => {:boost => 1.5} }
=end

  def index_contest_choice_titles
    index_contest_choices(:name)
  end

  def index_contest_choice_descriptions
    index_contest_choices(:description)
  end

  def index_contest_choices(attr)
    @index = Array.new
    self.contests.each do |contest|
      contest.choices.each do |choice|
        @index << choice.send(attr).to_s
      end
    end
    @index.join(" ")
  end

  def to_liquid
    liquid = { 'id' => id, 'name' => name, 'city' => city, 'state' => state, 'date' => date.strftime('%B %e, %Y'), 'description' => description, 'contests' => contests, 'theme' => theme, 'endorsed' => endorsed?, 'permalink' => permalink_url, 'c3' => c3? }
    if image
      liquid.merge!(  { 'image_link' => image.public_filename, 'image_name' => image.filename, 'image_thumb' => image.public_filename('thumb') } )
    end
    if attached_pdf
      liquid.merge!( { 'pdf_name' => attached_pdf.filename, 'pdf_link' => attached_pdf.public_filename } )
    end
    liquid
  end

  def permalink_url
    if date && permalink
      "/#{date.year}/#{permalink}"
    else
      "/guides/show/#{id}"
    end
  end

  def make_permalink(options = {})
    return '/guides/show/' + id if options.empty?
    "/#{options[:year]}/#{options[:permalink]}"
  end

  def publish
    @recently_published = true if !self.status or self.status == DRAFT
    self.status = PUBLISHED
  end

  def unpublish
    self.status = DRAFT
  end

  def is_published?
    published?
  end

  def published?
    PUBLISHED == status
  end

  def self.count_published
    count(:conditions => "status = '#{Guide::PUBLISHED}'")
  end

  def approve(user)
    update_attributes(:approved_at => Time.now, :approved_by => user)
  end

  def approved?
    !c3? || !approved_at.nil?
  end

  def self.with_approved
    Guide.with_scope({ :find => { :conditions => "approved_at IS NOT NULL OR legal IS NULL OR legal != '#{Guide::NONPARTISAN}'" } }) do
      yield
    end
  end

  def self.with_published
    Guide.with_scope({ :find => { :conditions => "status = '#{Guide::PUBLISHED}'" } }) do
      yield
    end
  end

  def self.with_c3
    Guide.with_scope({ :find => { :conditions => "legal = '#{Guide::C3}'" },
                       :create => { :legal => Guide::C3 }}) do
      yield
    end
  end

  named_scope :future, {:conditions => ["date > ?", Time.now]}

  named_scope :published, {:conditions => ["status = ?", PUBLISHED]}
  named_scope :draft, {:conditions => ["status = ?", DRAFT]}

  named_scope :legal, lambda {|status|
    { :conditions => (status == NONPARTISAN) ? "legal = '#{Guide::NONPARTISAN}'" : "legal IS NULL OR legal <> '#{Guide::NONPARTISAN}'" }
  }

  named_scope :in_progress, {:conditions => "status IS NULL"}
  named_scope :nonpartisan, {:conditions => ["legal = ?", NONPARTISAN]}
  named_scope :partisan,    {:conditions => ["legal IS NULL OR LEGAL <> ?", NONPARTISAN]}

  def owner?(u)
    u == user
  end

  def c3?
    NONPARTISAN == legal
  end

  def candidate_contests
    contests.find_all_by_type 'Candidate'
  end

  def member?(u)
    members.include?(u)
  end

  def add_member(u)
    return if member?(u)
    Pledge.create(:user => u, :guide => self)
    GuidePromoter.deliver_join_notification(self, u)
    update_attribute(:num_members, members.count)
    u.blocs(true)
    members(true)
  end

  def remove_member(u)
    pledge = pledges.find_by_user_id(u.id)
    return unless pledge
    pledge.destroy
    update_attribute(:num_members, members.count)
    u.blocs(true)
    members(true)
  end

  def blank?
    !name && !permalink && !description && !city && !status && !endorsed && !approved_at && !approved_by && contests.empty? && members.empty?
  end

  protected
  # from acts_as_urlnameable
  def create_permalink
    if permalink.nil? || permalink.empty?
      self.permalink = name.to_s.downcase.strip
    end
    self.permalink = permalink.gsub(/[^-_\s[:alnum:]]/, ' ').squeeze(' ').tr(' ', '-')
    true
  end

  def validate_on_create
    if !date.nil?
      errors.add 'date', 'must be upcoming election' if date.to_date < Time.now.to_date
    end
  end
end
