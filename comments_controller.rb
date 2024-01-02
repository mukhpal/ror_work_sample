class Api::V1::CommentsController < Api::BaseController
  include Concerns::Api::V1::Docs::CommentsDoc

  before_action :set_commentable, only: %i[create index create_reply]
  before_action :set_comment, only: %i[replies create_reply toggle_like]

  param_group :doc_create_comment
  def create
    @comment = @commentable.comments.new(body: params[:body], user: current_user)
    @comment.replace_users_with_ids(params[:data])
    return success_response(message: 'success', data: CommentSerializer.new(@comment).as_json) if @comment.save
    four_twenty_two(message: @comment.errors.full_messages.to_sentence)
  end

  param_group :doc_list_comments
  def index
    @comments = @commentable.comments.without_replies.ordered.includes(Comment::API_ASSOCIATIONS, replies: Comment::API_ASSOCIATIONS).page(params[:page]).per(params[:per_page])
    success_response(get_list_response(@comments, @comments.total_count, ENTITIES[:comment], current_user: current_user))
  end

  param_group :doc_list_replies
  def replies
    @replies = @comment.paginated_replies(params[:page], params[:per_page]).includes(Comment::API_ASSOCIATIONS)
    success_response(get_list_response(@replies, @replies.total_count, ENTITIES[:comment], current_user: current_user))
  end

  param_group :doc_create_reply
  def create_reply
    @reply = @comment.replies.new(body: params[:body], user: current_user, commentable: @commentable)
    @reply.replace_users_with_ids(params[:data])
    return success_response(message: 'success', data: CommentSerializer.new(@reply).as_json) if @reply.save
    four_twenty_two(message: @reply.errors.full_messages.to_sentence)
  end

  param_group :doc_toggle_like
  def toggle_like
    @comment.toggle_like!(current_user.id)
    success_response(message: 'success', data: { liked: @comment.likeables.pluck(:user_id).include?(current_user.id) })
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_commentable
    resource, id = request.path.split('/')[2, 2]
    @commentable = resource.singularize.classify.constantize.find(id)
  end
end
