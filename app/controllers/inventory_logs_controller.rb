class InventoryLogsController < ApplicationController
  def new
    @inventory_log = InventoryLog.new
    @products = Product.active  # Only active products (not soft-deleted)
  end

  def index
    # Fetch only inventory logs related to active (non-deleted) products
    @inventory_logs = InventoryLog.joins(:product)
                                  .where(products: { deleted_at: nil })  # Exclude soft-deleted products
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
      @products = Product.active  # Only show active products in the dropdown
      render :new
    end
  end

  private

  def inventory_log_params
    params.require(:inventory_log).permit(:product_id, :quantity, :operation)
  end
end
