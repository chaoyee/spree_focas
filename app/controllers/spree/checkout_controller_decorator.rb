module Spree
  CheckoutController.class_eval do

    # prevent the ActionController::InvalidAuthenticityToken error
    protect_from_forgery except: :focas_notify  

    def focas_notify
      notification = ActiveMerchant::Billing::Integrations::Focas::Notification.new(request.raw_post)

      puts notification.inspect

      @order = Spree::Order.find_by_id(params[:order_id])
  
      if notification.complete?
        # payment is compeleted
        payment_method = Spree::PaymentMethod.find_by_id(params[:payment_method_id])
        payment = @order.payments.create({ amount: @order.total,                                            
                                           payment_method: payment_method})
        payment.started_processing!
        payment.complete!

        @order.update_attributes({ state: "complete", completed_at: Time.now, payment_total: @order.total })

        until @order.state == "complete"
          if @order.next!
            @order.update!
            state_callback(:after)
          end
        end
  
        @order.finalize!
  
        flash.notice = Spree.t(:order_processed_successfully) + ", no:#{notification.lidm}"
        redirect_to orders_path
      else
        # payment is failed
        flash[:error] = Spree.t(:payment_has_been_cancelled) + " status:#{notification.status}, errcode:#{notification.errcode}"
        redirect_to edit_order_path(@order)
      end
  
      puts '1|OK,  status: 200'
    end

    def redirect_to_focas
      @order = Spree::Order.find_by_id(params[:id])
      @payment_method_id = params[:payment_method_id]
      @preferences = Spree::PaymentMethod.find_by_id(params[:payment_method_id]).preferences
      if @preferences[:merchant_id].empty? || @preferences[:mer_id].empty? || @preferences[:terminal_id].empty?
        flash[:error] = Spree.t(:focas_parameters_are_not_set)
        redirect_to :back
        return
      end  
      render layout: false
    end
  end
end
