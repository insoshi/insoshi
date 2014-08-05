require File.dirname(__FILE__) + '/../spec_helper'

describe ExchangeAndFee do

  describe "destroy" do
    before do
      ExchangeAndFee.any_instance.stub(:save_metadata)
      ExchangeAndFee.any_instance.stub(:log_activity)
      ExchangeAndFee.any_instance.stub(:calculate_account_balances)
      ExchangeAndFee.any_instance.stub(:send_payment_notification_to_worker)
      ExchangeAndFee.any_instance.stub(:withdraw_fee)
      ExchangeAndFee.any_instance.stub(:delete_calculate_account_balances)
      ExchangeAndFee.any_instance.stub(:group_has_a_currency_and_includes_both_counterparties_as_members)
      ExchangeAndFee.any_instance.stub(:worker_is_not_customer)

      @general = ExchangeAndFee.new(metadata_type: 'Offer', metadata_id: 1)
      @general.save(:validate => false)
      @fee_for_general = ExchangeAndFee.new(metadata_type: 'Exchange', metadata: @general)
      @fee_for_general.save(:validate => false)
    end

    subject { @general.destroy }

    it { expect(@fee_for_general.deleted_at).to be_nil }
    it { expect(@fee_for_general.reload.deleted_at).to be_nil }
  end
end
