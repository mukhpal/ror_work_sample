class Category < ApplicationRecord
  include PgSearch

  paginates_per 20

  has_many :recipe_categories, dependent: :destroy
  has_many :recipes, through: :recipe_categories
  has_many :user_categories
  has_many :users, through: :user_categories, dependent: :destroy

  multisearchable against: [:name]
  pg_search_scope :filter_by_name, against: :name, using: { tsearch: { prefix: true } }

  scope :interests, -> { where(interest: true) }
  scope :order_by_sequence, -> { where.not(sequence: nil).order(:sequence) }
  scope :search_by_interest, -> (interest) { order_by_sequence.where(interest: interest) }
  scope :non_deletable, -> { where(deletable: false) }

  validates :name, presence: true

  def self.default_search_params(params)
    params[:interest] || [true, false]
  end
end
