class MealPlanSerializer < ActiveModel::Serializer
  root false
  include Concerns::ImageVariants
  include Rails.application.routes.url_helpers

  attributes :id, :name, :avatar_url, :created_at, :updated_at, :avatar_variants_urls

  def avatar_url
    return '' unless object.picture.attached?
    variant = object.picture.variant(resize: '400x400')
    return rails_representation_url(variant)
  end

  def avatar_variants_urls
    picture_urls(object.picture)
  end
end
