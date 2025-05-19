
class ReportsController < ApplicationController
  before_action :authenticate_user!
  def index
    @categories = Category.all

    if params[:start_date].present? && params[:end_date].present?
      @start_date = Date.parse(params[:start_date])
      @end_date = Date.parse(params[:end_date])
      logs_scope = InventoryLog
                     .includes(:product)
                     .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)

      if params[:category_id].present?
        logs_scope = logs_scope.joins(:product).where(products: { category_id: params[:category_id] })
        @selected_category = Category.find_by(id: params[:category_id])
      end

      @stock_ins = logs_scope.where(operation: "stock_in")
      @stock_outs = logs_scope.where(operation: "stock_out")
    else
      @stock_ins = []
      @stock_outs = []
    end
  end
end
