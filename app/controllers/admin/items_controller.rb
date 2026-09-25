class Admin::ItemsController < Admin::BaseController
  before_action :find_item, only: %i[edit update destroy move]

  def index
    @kind = ContentItem::KINDS.key?(params[:kind]) ? params[:kind] : 'feature'
    @items = ContentItem.of(@kind)
  end

  def new
    @item = ContentItem.new(kind: ContentItem::KINDS.key?(params[:kind]) ? params[:kind] : 'feature')
    render :form
  end

  def edit = render(:form)

  def create
    @item = ContentItem.new(item_params)
    @item.save ? done(@item, 'Added') : render(:form, status: 422)
  end

  def update
    @item.update(item_params.except(:kind)) ? done(@item, 'Saved') : render(:form, status: 422)
  end

  def destroy
    @item.destroy
    done(@item, 'Deleted')
  end

  def move
    @item.move(params[:dir])
    done(@item)
  end

  private

  def find_item = (@item = ContentItem.find(params[:id]))
  def item_params = params.require(:content_item).permit(:kind, :title, :body)
  def done(item, msg = nil) = redirect_to(admin_items_path(kind: item.kind), notice: msg)
end
