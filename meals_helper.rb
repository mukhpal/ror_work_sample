module MealsHelper
  MAX_PERCENT_X = 82.freeze
  MAX_PERCENT_Y = 88.freeze

  def get_hash_tags(tags)
    tags.join(' ')
  end

  def get_thumb_image_name(meal)
    (current_user.present? && meal.liked_by?(current_user.id)) ? 'thumb_liked.svg' : 'thumb.svg'
  end

  def get_thumb_action_url(meal)
    (current_user.present? && meal.liked_by?(current_user.id)) ? unlike_meal_path(meal) : like_meal_path(meal)
  end

  def get_tag_position_css(percent_x, percent_y)
    percent_x = MAX_PERCENT_X if percent_x > MAX_PERCENT_X
    percent_y = MAX_PERCENT_Y if percent_y > MAX_PERCENT_Y

    "top: #{percent_y}%; left: #{percent_x}%"
  end

  def likes_link(meal)
    content_tag(:span, class: 'like-count') do
      (link_to "#{ pluralize(meal.likes_count, 'like') }", liked_users_meal_path(meal), title: 'Likes', data: { target: '#shared_modal', toggle: 'modal' }, remote: true, onclick: "$('#shared_modal').modal()") if meal.likes_count > 0
    end
  end

  def get_next_page_params(user)
    return {
      controller: 'meals',
      action: 'index'
    } if current_user == user

    {
      controller: 'users',
      action: 'meals'
    }
  end

end
