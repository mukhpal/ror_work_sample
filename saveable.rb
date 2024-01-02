module Meals::Saveable
  extend ActiveSupport::Concern

  def save_to_recipe_box!(user)
    meal_recipe_ids = self.recipes.approved.pluck(:id)

    if meal_recipe_ids.count > 0
      user_recipe_ids = user.linked_recipes.non_rejected.pluck(:id)

      # Remove those recipe ids which are already linked with user
      new_recipe_ids = meal_recipe_ids - user_recipe_ids

      if new_recipe_ids.empty?
        self.errors.add(:'Recipe(s)', 'already exist in Recipe Box')
        raise ActiveRecord::RecordInvalid.new(self)
      end

      user.interested_recipes << new_recipe_ids.map{ |r_id| InterestedRecipe.new(user_id: user.id, recipe_id: r_id, status: InterestedRecipe::STATUS[:saved]) }

      return true if user.save
      raise ActiveRecord::RecordInvalid.new(user)
    else
      self.errors.add(:Meal, 'has no Recipes to save to the Recipe Box')
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end
end
