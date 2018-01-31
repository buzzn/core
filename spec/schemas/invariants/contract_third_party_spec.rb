require 'buzzn/schemas/invariants/contract/localpool_third_party'

describe 'Schemas::Invariants::Contract::LocalpoolThirdParty' do

  entity(:person)       { create(:person) }
  entity(:organization) { create(:organization) }
  entity(:localpool)    { create(:localpool) }

  entity(:third_party)             { create(:contract, :localpool_third_party,   localpool: localpool) }
  entity(:register) { third_party.register }

    shared_examples "invariants of contracting party" do |label|

      let(:tested_invariants) { third_party.invariant.errors[:"#{label}"] }

      subject { tested_invariants }

      context "when there is no party" do
        before do
          third_party.send("#{label}=", nil)
        end
        it { is_expected.to be_nil }
      end

      context "when there is a person party" do
        before do
          third_party.send("#{label}=", person)
        end
        it { is_expected.to eq(['cannot be defined']) }
      end

      context "when there is a organization party" do
        before do
          third_party.send("#{label}=", organization)
        end
        it { is_expected.to eq(['cannot be defined']) }
      end
    end

    shared_examples "invariants of contracting party bank-account" do |label|

      entity(:bank_account) { create(:bank_account) }

      let(:tested_invariants) { third_party.invariant.errors[:"#{label}_bank_account"] }

      subject { tested_invariants }

      context "when there is no bank_account" do
        before do
          third_party.send("#{label}_bank_account=", nil)
        end
        it { is_expected.to be_nil }
      end

      context "when there is a bank-account" do
        before do
          third_party.send("#{label}_bank_account=", bank_account)
        end
        it { is_expected.to eq(['cannot be defined']) }
      end
    end

  shared_examples "invariants of collections" do |label|

    let(:tariff) { create(:tariff) }
    let(:payment) { create(:payment, contract: third_party) }

    let(:tested_invariants) { third_party.invariant.errors[:"#{label}s"] }

    subject { tested_invariants }

    context "when there is #{label}" do
      before do
        third_party.send("#{label}s") << send(label)
      end
      it { is_expected.to eq(['size must be 0']) }
    end

    context "when there is no #{label}" do
      before do
        third_party.send("#{label}s").clear
      end
      it { is_expected.to be_nil }
    end
  end

  describe 'tariffs' do
    it_behaves_like "invariants of collections", :tariff
  end

  describe 'payments' do
    it_behaves_like "invariants of collections", :payment
  end

  describe "customer" do
    it_behaves_like "invariants of contracting party", :customer
    it_behaves_like "invariants of contracting party bank-account", :customer
  end

  describe "contractor" do
    it_behaves_like "invariants of contracting party", :contractor
    it_behaves_like "invariants of contracting party bank-account", :contractor
  end
end
