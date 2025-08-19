# app/controllers/api/v1/concerns/analytics_controller_helper.rb
module Api::V1::Concerns::AnalyticsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [:index, :total_products, :total_payment_received, :total_orders, :total_unresolved_chats, :unresolved_chats, :monthly_payments, :monthly_orders, :yearly_payments, :yearly_orders]
  end

  def index
    month = params[:month]&.to_i || Date.current.month
    year = params[:year]&.to_i || Date.current.year
    
    render json: {
      total_products: total_products_count,
      total_payment_received: total_payment_received_amount,
      total_orders: total_orders_count,
      total_unresolved_chats: total_unresolved_chats_count,
      unresolved_chats: unresolved_chats_list,
      monthly_payments: monthly_payments_amount,
      monthly_orders: monthly_orders_count,
      yearly_payments: yearly_payments_amount,
      yearly_orders: yearly_orders_count,
      period_info: {
        month: month,
        year: year,
        month_name: Date::MONTHNAMES[month],
        is_current_month: month == Date.current.month && year == Date.current.year,
        is_current_year: year == Date.current.year
      }
    }
  end

  def total_products
    render json: { total_products: total_products_count }
  end

  def total_payment_received
    render json: { total_payment_received: total_payment_received_amount }
  end

  def total_orders
    render json: { total_orders: total_orders_count }
  end

  def total_unresolved_chats
    render json: { total_unresolved_chats: total_unresolved_chats_count }
  end

  def unresolved_chats
    render json: { unresolved_chats: unresolved_chats_list }
  end

  def monthly_payments
    render json: { 
      monthly_payments: monthly_payments_amount,
      period_info: {
        month: params[:month]&.to_i || Date.current.month,
        year: params[:year]&.to_i || Date.current.year,
        month_name: Date::MONTHNAMES[params[:month]&.to_i || Date.current.month]
      }
    }
  end

  def monthly_orders
    render json: { 
      monthly_orders: monthly_orders_count,
      period_info: {
        month: params[:month]&.to_i || Date.current.month,
        year: params[:year]&.to_i || Date.current.year,
        month_name: Date::MONTHNAMES[params[:month]&.to_i || Date.current.month]
      }
    }
  end

  def yearly_payments
    render json: { 
      yearly_payments: yearly_payments_amount,
      period_info: {
        year: params[:year]&.to_i || Date.current.year
      }
    }
  end

  def yearly_orders
    render json: { 
      yearly_orders: yearly_orders_count,
      period_info: {
        year: params[:year]&.to_i || Date.current.year
      }
    }
  end

  def overview_performance
    year = params[:year]&.to_i || Date.current.year
  
    # Get range for the whole year
    start_date = Date.new(year, 1, 1)
    end_date   = start_date.end_of_year
  
    # Group completed orders by month
    orders_count = order_class
                     .where(status: 'completed', created_at: start_date..end_date)
                     .group("EXTRACT(MONTH FROM created_at)")
                     .count
  
    # Map all 12 months to ensure missing months return 0
    months_data = (1..12).map do |m|
      {
        month: Date::MONTHNAMES[m],
        orders_count: orders_count[m.to_f] || 0
      }
    end
  
    render json: months_data
  end  


  private

  def total_products_count
    product_class.count
  end

  def total_payment_received_amount
    payment_class.where(status: 'completed').sum(:amount)
  end

  def total_orders_count
    order_class.count
  end

  def total_unresolved_chats_count
    message_class.where(status: ['open', 'pending']).count
  end

  def unresolved_chats_list
    message_class.where(status: ['open', 'pending'])
                 .includes(:sephcocco_user, product_association_name)
                 .limit(5)
                 .map do |message|
      {
        id: message.id,
        user_name: message.sephcocco_user&.name || 'Anonymous',
        product_name: message.send(product_association_name)&.name || 'Unknown Product',
        status: message.status,
        created_at: message.created_at,
        last_message: message.chats&.last&.dig('message') || 'No messages'
      }
    end
  end

  def monthly_payments_amount
    month = params[:month]&.to_i || Date.current.month
    year = params[:year]&.to_i || Date.current.year
    
    # Validate month and year
    return 0 unless (1..12).include?(month) && year > 1900
    
    target_date = Date.new(year, month, 1)
    month_range = target_date.beginning_of_month..target_date.end_of_month
    payment_class.where(status: 'completed', created_at: month_range).sum(:amount)
  end

  def monthly_orders_count
    month = params[:month]&.to_i || Date.current.month
    year = params[:year]&.to_i || Date.current.year
    
    # Validate month and year
    return 0 unless (1..12).include?(month) && year > 1900
    
    target_date = Date.new(year, month, 1)
    month_range = target_date.beginning_of_month..target_date.end_of_month
    order_class.where(created_at: month_range).count
  end

  def yearly_payments_amount
    year = params[:year]&.to_i || Date.current.year
    
    # Validate year
    return 0 unless year > 1900
    
    year_range = Date.new(year, 1, 1).beginning_of_year..Date.new(year, 12, 31).end_of_year
    payment_class.where(status: 'completed', created_at: year_range).sum(:amount)
  end

  def yearly_orders_count
    year = params[:year]&.to_i || Date.current.year
    
    # Validate year
    return 0 unless year > 1900
    
    year_range = Date.new(year, 1, 1).beginning_of_year..Date.new(year, 12, 31).end_of_year
    order_class.where(created_at: year_range).count
  end

  # Abstract methods that must be implemented by each controller
  def product_class; raise NotImplementedError; end
  def payment_class; raise NotImplementedError; end
  def order_class; raise NotImplementedError; end
  def message_class; raise NotImplementedError; end
  def product_association_name; raise NotImplementedError; end
end 