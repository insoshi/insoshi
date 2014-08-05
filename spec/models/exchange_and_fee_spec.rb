require File.dirname(__FILE__) + '/../spec_helper'

describe ExchangeAndFee do
  fixtures :exchanges

  let(:general) { ExchangeAndFee.find(exchanges(:general).id) }
  let(:fee_for_general) { ExchangeAndFee.find(exchanges(:fee_for_general).id) }

  describe "destroy" do
    before do
      ExchangeAndFee.any_instance.stub(:delete_calculate_account_balances)
      ExchangeAndFee.any_instance.stub(:group_has_a_currency_and_includes_both_counterparties_as_members)
      ExchangeAndFee.any_instance.stub(:worker_is_not_customer)
    end

    subject { general.destroy }

    it { expect(fee_for_general.deleted_at).to be_nil }
    it { expect(fee_for_general.reload.deleted_at).to be_nil }
  end
end
