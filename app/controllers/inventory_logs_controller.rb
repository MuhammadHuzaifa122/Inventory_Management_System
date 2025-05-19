class InventoryLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_inventory_logs

  def new
    @inventory_log = InventoryLog.new
    @products = Product.active
  end

  def index
    @inventory_logs = InventoryLog.joins(:product)
                                  .where(products: { deleted_at: nil })
                                  .includes(:product)
                                  .order(created_at: :desc)
  end

  def create
    @inventory_log = InventoryLog.new(inventory_log_params)

    if @inventory_log.save
      product = @inventory_log.product
      if @inventory_log.operation == "stock_in"
        product.increment!(:stock, @inventory_log.quantity)
      elsif @inventory_log.operation == "stock_out"
        product.decrement!(:stock, @inventory_log.quantity)
      end

      redirect_to products_path, notice: "Stock updated successfully."
    else
      @products = Product.active
      render :new
    end
  end

  private

  def inventory_log_params
    params.require(:inventory_log).permit(:product_id, :quantity, :operation)
  end

  def authorize_inventory_logs
    authorize InventoryLog
  end
end
