class Admin::RecipesController < Admin::BaseController
  before_action :set_recipe, only: [:change_status, :show, :edit, :update, :destroy]
  before_action :set_category_ids, only: [:new, :create, :show, :edit, :update]
  before_action :validate_deletable_recipe, only: :destroy
  before_action :set_carousal, only: %i[search carousal]

  def index
    @pending_recipes = Recipe.unapproved.search_admin_recipes(search_params[:query]).page(params[:page])
    @approved_recipes = Recipe.approved.search_admin_recipes(search_params[:query]).page(params[:page])
    @rejected_recipes = Recipe.rejected.search_admin_recipes(search_params[:query]).page(params[:page])
    @uploaded_recipes = Recipe.uploaded.search_admin_recipes(search_params[:query]).page(params[:page])
    @category_pages = CategoryPage.page(params[:category_page])
    @comments = Comment.pending.ordered_asc.includes(:tagged_users, user: [avatar_attachment: :blob]).last(2)
  end

  def pending_recipes
    @pending_recipes = Recipe.unapproved.search_admin_recipes(search_params[:query]).page(params[:page])
  end

  def approved_recipes
    @approved_recipes = Recipe.approved.search_admin_recipes(search_params[:query]).page(params[:page])
  end

  def rejected_recipes
    @rejected_recipes = Recipe.rejected.search_admin_recipes(search_params[:query]).page(params[:page])
  end

  def uploaded_recipes
    @uploaded_recipes = Recipe.uploaded.search_admin_recipes(search_params[:query]).page(params[:page])
  end

  def carousal; end

  def search; end

  def change_status
    params[:status] == Recipe::APPROVED_STATUS && @recipe.approve! || @recipe.update_attribute(:status, params[:status])
    redirect_to admin_recipes_path, notice: "Recipe #{@recipe.status} successfully!"
  end

  def show
    return if params[:comment_id].blank?

    @comment = Comment.find_by_id(params[:parent_id] || params[:comment_id])
    return if @comment.blank?

    position = @recipe.comment_position(@comment)
    page = (position.to_f / RECORDS_PER_PAGE).ceil
    @comments = @recipe.comments.ordered.without_replies.includes(Comment::WEB_ASSOCIATIONS, replies: Comment::WEB_ASSOCIATIONS).page(page)

    return @comment.mark_reviewed! if params[:parent_id].blank?

    @reply = Comment.find_by_id(params[:comment_id])
    return if @reply.blank?

    position = @comment.reply_position(@reply)
    page = (position.to_f / Comment::REPLIES_PER_PAGE).ceil
    @per_page = page * Comment::REPLIES_PER_PAGE
    @reply.mark_reviewed!
  end

  def new
    @recipe = Recipe.new
  end

  def edit
    @comments = @recipe.comments.without_replies.includes(Comment::WEB_ASSOCIATIONS, replies: Comment::WEB_ASSOCIATIONS).ordered.page(params[:page])
  end

  def create
    @recipe = Recipe.new(recipe_params)

    respond_to do |format|
      if @recipe.save
        format.html { redirect_to admin_recipe_path(@recipe), notice: 'Recipe was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @recipe.update(recipe_params)
        format.html { redirect_to admin_recipe_path(@recipe), notice: 'Recipe was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    recipe_status = @recipe.status
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_to admin_recipes_path(anchor: "#{recipe_status}-link"), notice: 'Recipe was successfully destroyed.' }
    end
  end

  def custom_carousal
    return if params[:recipe_ids].blank?

    @recipes = Recipe.find(params[:recipe_ids])
    @recipe_ids = params[:recipe_ids]
  end

  private

  def set_carousal
    @carousal_recipes = Recipe.filter_carousal_recipes(params[:category], search_params[:query], params[:page])
    @interested_recipes_hash = Recipe.interested_recipes_hash
    @recipe_ids = params[:recipe_ids]&.reject(&:empty?)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def search_params
    params.permit(:query)
  end

  def validate_deletable_recipe
    redirect_to admin_recipe_path(@recipe), alert: 'You can\'t delete non-deletable recipe.' unless @recipe.deletable?
  end

  def set_category_ids
    @category_ids = @recipe.present? ? @recipe.category_ids : []
  end

  def recipe_params
    params.require(:recipe).permit(:name, :image_rotation, :prep_time, :prep_scale, :active_time, :active_scale, :number_of_servings, :number_of_calories, :user_id, :source, :created_by, :picture, :description, :status, :external_url, :tag_list, :meal_post, recipe_ingredients_attributes: [:id, :ingredient_id, :name, :quantity, :measurement, :preparation, :_destroy], directions_attributes: [:id, :step, :details, :_destroy], category_ids: [])
  end
end
