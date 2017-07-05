describe NewRelic::Agent::Instrumentation::Roda do

  def app
    CoreRoda # this defines the active application for this test
  end

  # adopted from https://github.com/mikz/newrelic-roda
  it "traces" do
    allow_any_instance_of(NewRelic::Agent::Instrumentation::Roda).to receive(:perform_action_with_newrelic_trace).and_yield
    get "/heartbeat"
    expect(response).to have_http_status(200)
  end
end
