describe Services::Health do

  it 'info' do
    info = subject.info
    expect(info).to eq(maintenance: 'off',
                       build: {version: 'not-available',
                               timestamp: 'not-available'},
                       database: 'alive',
                       redis: 'alive',
                       healthy: true)
  end
end
