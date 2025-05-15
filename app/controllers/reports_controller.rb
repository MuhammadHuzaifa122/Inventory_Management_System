class ReportsController < ApplicationController
def index
  if params[:start_date].present? && params[:end_date].present?
    @start_date = Date.parse(params[:start_date])
    @end_date = Date.parse(params[:end_date])
    @stock_ins = InventoryLog.where(operation: "stock_in", created_at: @start_date.beginning_of_day..@end_date.end_of_day)
    @stock_outs = InventoryLog.where(operation: "stock_out", created_at: @start_date.beginning_of_day..@end_date.end_of_day)
  else
    @stock_ins = []
    @stock_outs = []
  end
end
end
