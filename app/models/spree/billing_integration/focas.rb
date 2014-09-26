class Spree::BillingIntegration::Focas < Spree::BillingIntegration
  preference :merchant_id, :string
  preference :mer_id,      :string
  preference :terminal_id, :string

  def provider_class
    ActiveMerchant::Billing::Integrations::Focas
  end
end