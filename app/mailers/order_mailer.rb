class OrderMailer < ApplicationMailer
  def order_created_email
    @order = params[:order]
    @user = @order.sephcocco_user
    @outlet_type = determine_outlet_type(@order)
    
    mail(
      to: @user.email,
      subject: "Order Confirmation - #{@order.order_number}"
    )
  end

  def order_status_updated_email
    @order = params[:order]
    @user = @order.sephcocco_user
    @outlet_type = determine_outlet_type(@order)
    @old_status = params[:old_status]
    @new_status = @order.status
    
    mail(
      to: @user.email,
      subject: "Order Status Update - #{@order.order_number}"
    )
  end

  def order_delivered_email
    @order = params[:order]
    @user = @order.sephcocco_user
    @outlet_type = determine_outlet_type(@order)
    
    mail(
      to: @user.email,
      subject: "Order Delivered - #{@order.order_number}"
    )
  end

  def order_cancelled_email
    @order = params[:order]
    @user = @order.sephcocco_user
    @outlet_type = determine_outlet_type(@order)
    @reason = params[:reason]
    
    mail(
      to: @user.email,
      subject: "Order Cancelled - #{@order.order_number}"
    )
  end

  private

  def determine_outlet_type(order)
    case order.class.name
    when /Pharmacy/
      'pharmacy'
    when /Restaurant/
      'restaurant'
    when /Lounge/
      'lounge'
    else
      'unknown'
    end
  end
end
