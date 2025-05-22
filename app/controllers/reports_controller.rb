class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_reports

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

def fetch
  if params[:start_date].present? && params[:end_date].present?
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    @stock_ins = InventoryLog.includes(:product).where(operation: "stock_in", created_at: start_date.beginning_of_day..end_date.end_of_day)
    @stock_outs = InventoryLog.includes(:product).where(operation: "stock_out", created_at: start_date.beginning_of_day..end_date.end_of_day)

    render partial: "report_results", locals: { stock_ins: @stock_ins, stock_outs: @stock_outs, start_date: start_date, end_date: end_date }
  else
    render plain: "Invalid date range", status: :unprocessable_entity
  end
end

  private

  def authorize_reports
    authorize :report, :index?
  end
end
