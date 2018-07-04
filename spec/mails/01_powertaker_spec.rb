describe Mail::PowerTaker do

  # TODO: write factory for this once form_content is defined
  entity(:form_content) do
    {
      moving_in: true,
      moving_in_date: Date.today,
      counter_id: 1337,
      count_id: 'DE',
      previous_a_conto: 42,
      estimated_kwh: 1984,
      message: '',
      reference: '',
      customer: {
        name: 'Peter',
        last_name: 'Powertaker',
        gender: 'M',
        phone: '01777777777',
        email: 'peter.powertaker@buzzn.net'
      },
      previous_supplier: {
        name: 'Wattenfall',
        customer_no: 'DE-777',
        contract_no: '666'
      },
      partner: {
        name: 'Community eG',
        represented_by: 'Somebody Responsible',
        address: {
          street: 'Greenstreet 1',
          addition: nil,
          zip: 77777,
          city: 'TransitionTown'
        }
      }
    }
  end

  subject { Mail::PowerTaker.new(form_content) }

  it 'renders text' do
    text = subject.to_text
    expect(text.length).to be > 0
  end

  it 'renders html' do
    html = subject.to_html
    expect(html.length).to be > 0
  end
end
