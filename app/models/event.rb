class Event < ApplicationRecord
  belongs_to :category
  belongs_to :user

  has_many :attendances, dependent: :destroy
  has_many :users, through: :attendances, source: :user

  has_and_belongs_to_many :tags

  validates :title, presence: true, length: {maximum: 100}
  validates :place, presence: true, length: {maximum: 150}
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :content, presence: true, length: {maximum: 200}
  validates :expiration_date, presence: true
  validate :compareDate

  after_commit :create_hash_tags, on: :create

  scope :sort_by_created, ->{order created_at: :desc}
  scope :recent_post, -> {limit 3}

  def compareDate
    if end_time < start_time
      errors.add(:end_time, t("event.model.time1"))
    elsif end_time < Date.today || start_time < Date.today
      errors.add(:end_time, t("event.model.time1"))
    elsif start_time < expiration_date
      errors.add(:start_time, t("event.model.time1"))
    end
  end

  def unattend? user
    Attendance.find_by(user_id: user.id, event_id: self.id).destroy
  end

  def attendance user
    users << user
  end

  def attendance? user
    users.include? user
  end

  def expirationTime?
    self.expiration_date < Date.today
  end

  def belong? user
    self.user == user
  end

  def create_hash_tags
    event = Event.find_by id: self.id
    hashtags = self.content.scan(/#\w+/)
    hashtags.uniq.map do |hashtag|
      tag = Tag.find_or_create_by name: hashtag.downcase.delete('#')
      event.tags << tag
    end
  end
end
