class Api::V1::SearchController < Api::BaseController
  include Concerns::Api::V1::Docs::SearchDoc

  param_group :doc_search_all
  def index
    non_deletable_records = [User.non_deletable, Recipe.non_deletable, Tag.non_deletable, Category.non_deletable].flatten if params[:query].blank?
    records = non_deletable_records && Kaminari.paginate_array(non_deletable_records) || PgSearch.multisearch(params[:query]).includes(:searchable)
    paged_records = records.page(params[:page]).per(params[:per_page])

    success_response(message: 'success', data: serialize_search_response(paged_records), total_records: records.size)
  end

  private

  def serialize_search_response(list)
    scope = {
      current_user_category_ids: current_user.category_ids,
      current_user_tag_ids: current_user.tag_followees_ids,
      current_user_followees_ids: current_user.user_followees_ids
    } if list.present?
    if list.is_a? ActiveRecord::Relation
      list.map do |item|
        searchable_type = item.searchable_type.demodulize
        "#{searchable_type}Serializer".constantize.new(item.searchable.becomes(searchable_type.constantize), scope: scope).as_json.merge(searchable_type: searchable_type)
      end
    else
      list.map do |item|
        searchable_type = item.class.name
        "#{searchable_type}Serializer".constantize.new(item.becomes(searchable_type.constantize), scope: scope).as_json.merge(searchable_type: searchable_type)
      end
    end
  end
end
