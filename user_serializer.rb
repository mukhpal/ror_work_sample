class UserSerializer < ActiveModel::Serializer
  root false
  include Concerns::ImageVariants
  include Rails.application.routes.url_helpers

  attributes :id, :first_name, :last_name, :email, :username, :bio, :location, :followers_count, :user_followees_count, :complete, :tag_followees_count, :created_at, :avatar_url, :followed_by_me, :avatar_variants_urls

  has_one :featured_recipe, as: :recipeable
  has_many :featured_collections

  def filter(keys)
    keys.delete :featured_recipe unless scope && scope[:featured_recipe]
    keys.delete :featured_collections unless scope && scope[:featured_collections]
    keys
  end

  def avatar_url
    return '' unless object.avatar.attached?
    variant = object.avatar.variant(resize: '100x100')
    return rails_representation_url(variant)
  end

  def followed_by_me
    scope[:current_user_followees_ids].include?(object.id) if scope && scope[:current_user_followees_ids]
  end

  def avatar_variants_urls
    picture_urls(object.avatar)
  end
end
