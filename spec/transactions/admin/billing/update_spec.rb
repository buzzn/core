require 'buzzn/transactions/admin/billing/update'

describe Transactions::Admin::Billing::Update do

  before do
    require './lib/buzzn/types/billing_config'
    CoreConfig.store Types::BillingConfig.new(vat: 1.19)
  end

  let!(:localpool) { create(:group, :localpool, fake_stats: { foo: 'bar' }) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:lpc) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:meter) do
    create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool)
  end

  let(:accounting_service) do
    Import.global('services.accounting')
  end

  let(:contract_begin) { Date.new(2019, 1, 16) }
  let(:tariff1_begin)  { Date.new(2019, 1, 1)  }
  let(:tariff2_begin)  { Date.new(2019, 3, 1)  }
  let(:billing1_begin) { Date.new(2019, 1, 18) }
  let(:billing1_end)   { Date.new(2019, 2, 25) }

  let(:tariff1) do
    create(:tariff, group: localpool, begin_date: tariff1_begin, energyprice_cents_per_kwh: 10, baseprice_cents_per_month: 300)
  end

  let(:tariff2) do
    create(:tariff, group: localpool, begin_date: tariff2_begin, energyprice_cents_per_kwh: 10, baseprice_cents_per_month: 300)
  end

  let(:contract) do
    create(:contract, :localpool_powertaker,
           begin_date: contract_begin,
           register_meta: meter.registers.first.meta,
           tariffs: [tariff1, tariff2],
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:params) do
    {
      begin_date: billing1_begin,
      last_date:  billing1_end,
    }
  end

  let!(:billingsr) do
    localpoolr.contracts.retrieve(contract.id).billings
  end

  let(:install_reading) do
    create(:reading, :setup, raw_value: 0, register: meter.registers.first, date: contract_begin - 2.day)
  end

  let(:begin_reading) do
    create(:reading, :regular, raw_value: 10, register: meter.registers.first, date: billing1_begin)
  end

  let(:end_reading) do
    create(:reading, :regular, raw_value: 10+1000, register: meter.registers.first, date: billing1_end)
  end

  let(:billing) do
    install_reading
    begin_reading
    end_reading
    result = Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                                       params: params,
                                                       contract: contract,
                                                       billing_cycle: nil)
    result.value!.object
  end

  let(:billingr) do
    localpoolr.contracts.retrieve(contract.id).billings.retrieve(billing.id)
  end

  context 'open' do

    context 'valid transactions' do
      context '-> open' do
        let(:update_params) do
          {
            status: 'open',
            updated_at: billing.updated_at.to_json
          }
        end

        let(:update_result) do
          Transactions::Admin::Billing::Update.new.(resource: billingr,
                                                    params: update_params)
        end

        it 'works' do
          expect(update_result).to be_success
          billing.reload
          expect(billing.status).to eql 'open'
        end
      end

      context '-> calculated' do

        let(:update_params) do
          {
            status: 'calculated',
            updated_at: billing.updated_at.to_json
          }
        end

        let(:update_result) do
          Transactions::Admin::Billing::Update.new.(resource: billingr,
                                                    params: update_params)
        end

        context 'payment' do

          context 'no automation set' do
            before do
              localpool.billing_detail.automatic_abschlag_adjust = false
              localpool.billing_detail.save
              localpool.reload
            end

            it 'does not generate a new payment' do
              expect(contract.payments.count).to eql 0
              expect(localpool.billing_detail.automatic_abschlag_adjust).to eql false
              expect(update_result).to be_success
              billing.reload
              contract.reload
              expect(contract.payments.count).to eql 0
              expect(billing.adjusted_payment).to be_nil
            end

          end

          context 'automation set' do
            before do
              localpool.billing_detail.automatic_abschlag_adjust = true
              localpool.billing_detail.automatic_abschlag_threshold_cents = 100 # 1 Euro
              localpool.billing_detail.save
              localpool.reload
            end

            context 'no previous payment' do
              it 'does not generate a new payment' do
                expect(contract.payments.count).to eql 0
                expect(localpool.billing_detail.automatic_abschlag_adjust).to eql true
                expect(update_result).to be_success
                billing.reload
                contract.reload
                expect(contract.payments.count).to eql 1
                expect(billing.adjusted_payment).not_to be_nil
                expect(billing.adjusted_payment.tariff).not_to be_nil
              end
            end

            context 'previous payment' do
              let!(:previous_payment) { create(:payment, price_cents: 5000, contract: contract) }
              context 'outside threshold' do
                before do
                  previous_payment.price_cents = 5000 # != 303
                  previous_payment.save
                end
                it 'does update' do
                  expect(contract.payments.count).to eql 1
                  expect(update_result).to be_success
                  billing.reload
                  contract.reload
                  expect(contract.payments.count).to eql 2
                  expect(billing.adjusted_payment).not_to be_nil
                  expect(billing.adjusted_payment.tariff).not_to be_nil
                end
              end

              context 'under threshold' do
                before do
                  previous_payment.price_cents = 300
                  previous_payment.save
                end
                it 'does update' do
                  expect(contract.payments.count).to eql 1
                  expect(update_result).to be_success
                  billing.reload
                  contract.reload
                  expect(contract.payments.count).to eql 1
                  expect(billing.adjusted_payment).to be_nil
                end
              end

              context 'in future, sign of manual update' do
                before do
                  previous_payment.price_cents = 5000
                  previous_payment.begin_date = Date.today + 23.days
                  previous_payment.save
                end
                it 'does update' do
                  expect(contract.payments.count).to eql 1
                  expect(update_result).to be_success
                  billing.reload
                  contract.reload
                  expect(contract.payments.count).to eql 1
                  expect(billing.adjusted_payment).to be_nil
                end
              end

              context 'with price_cents == -1' do
                before do
                  previous_payment.price_cents = -1
                  previous_payment.save
                end
                it 'does update but not readjust' do
                  expect(contract.payments.count).to eql 1
                  expect(update_result).to be_success
                  billing.reload
                  contract.reload
                  expect(contract.payments.count).to eql 1
                  expect(billing.adjusted_payment).to be_nil
                end
              end
            end

          end

        end

        context 'without proper billing items' do

          let(:billing) do
            install_reading
            result = Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                                               params: params,
                                                               contract: contract,
                                                               billing_cycle: nil)
            result.value!.object
          end

          it 'fails' do
            expect {update_result}.to raise_error(Buzzn::ValidationError,
                                                  '{:completeness=>["billing_items are not complete and state is not open"]}')
            billing.reload
            expect(billing.status).to eql 'open'
          end

        end

        context 'without balance' do

          it 'calculates' do
            expect(update_result).to be_success
            billing.reload
            expect(billing.status).to eql 'calculated'
            expect(billing.accounting_entry).not_to be_nil
            balance = accounting_service.balance(contract)
            expect(balance).to eql (- billing.total_amount_after_taxes*10).round
          end

        end

        context 'with a balance' do

          context 'with enough' do

            before do
              # 50 Euro
              accounting_service.book(operator, contract, 10*100*50)
            end

            it 'calculates' do
              expect(update_result).to be_success
              billing.reload
              expect(billing.status).to eql 'calculated'
              expect(billing.accounting_entry).not_to be_nil
              balance = accounting_service.balance(contract)
              expect(balance).to eql (10*100*50 - (billing.total_amount_after_taxes*10).round)
            end

          end

          context 'with just a little' do

            before do
              # 3 Euro
              accounting_service.book(operator, contract, 10*100*3)
            end

            it 'calculates' do
              expect(update_result).to be_success
              billing.reload
              expect(billing.status).to eql 'calculated'
              expect(billing.accounting_entry).not_to be_nil
              balance = accounting_service.balance(contract)
              expect(balance).to eql (10*100*3 - (billing.total_amount_after_taxes*10).round)
            end

          end

        end

      end

    end

    context 'invalid transactions' do
      allowed_transitions = StateMachine::Billing.transitions_for(:open)
      invalid_transitions = StateMachine::Billing.states - allowed_transitions

      invalid_transitions.each do |transition|
        context "-> #{transition}" do
          let(:update_params) do
            {
              status: transition.to_s,
              updated_at: billing.updated_at.to_json
            }
          end

          let(:update_result) do
            Transactions::Admin::Billing::Update.new.(resource: billingr,
                                                      params: update_params)
          end

          it 'fails' do
            expect {update_result}.to raise_error(Buzzn::ValidationError,
                                                  "{:status=>\"transition from open to #{transition} is not possible\"}")
            billing.reload
            expect(billing.status).to eql 'open'

          end
        end
      end

    end
  end

  context 'calculated' do

    context '-> documented' do

      let(:update_params) do
        billing.reload
        {
          status: 'documented',
          updated_at: billing.updated_at.to_json
        }
      end

      let(:update_result) do
        Transactions::Admin::Billing::Update.new.(resource: billingr,
                                                  params: update_params)
      end

      context 'without a payment' do

        before do
          localpool.billing_detail.automatic_abschlag_adjust = false
          localpool.billing_detail.save
          localpool.reload
          Transactions::Admin::Billing::Update.new.(resource: billingr, params: {status: 'calculated', updated_at: billing.updated_at.to_json})
          billing.reload
        end

        it 'fails' do
          expect(billing.status).to eql 'calculated'
          expect(contract.payments.count).to eql 0
          expect {update_result}.to raise_error(Buzzn::ValidationError,
                                                '{:contract=>{:current_payment=>["must be filled"]}}')
        end

      end

      context 'without fake stats and payment' do
        before do
          localpool.fake_stats = nil
          localpool.save
          localpool.reload
          Transactions::Admin::Billing::Update.new.(resource: billingr, params: {status: 'calculated', updated_at: billing.updated_at.to_json})
          billing.reload
        end

        it 'fails' do
          expect(billing.status).to eql 'calculated'
          expect(contract.payments.count).to eql 0
          expect {update_result}.to raise_error(Buzzn::ValidationError,
                                                '{:contract=>{:current_payment=>["must be filled"], :localpool=>{:fake_stats=>["must be filled"]}}}')
        end
      end

      context 'with a payment' do

        before do
          localpool.billing_detail.automatic_abschlag_adjust = true
          localpool.billing_detail.save
          localpool.reload
          Transactions::Admin::Billing::Update.new.(resource: billingr, params: {status: 'calculated', updated_at: billing.updated_at.to_json})
          billing.reload
        end

        it 'fails' do
          expect(billing.status).to eql 'calculated'
          expect(contract.payments.count).to eql 1
          expect(update_result).to be_success
          billing.reload
          expect(billing.documents.count).to eql 1
        end

      end
    end

  end

end
