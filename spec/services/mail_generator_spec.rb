require 'tempfile'

describe Services::MailGenerator do

  class Content < OpenStruct
  end

  entity!(:tempdir) { Dir.mktmpdir('buzzn') }

  after(:all) do
    # remove example files
    FileUtils.remove_entry(tempdir, true)
  end

  entity(:generator) { Services::MailGenerator.new(tempdir) }

  simple_html_content = %{
doctype html
html
  body
    h1 \#{header}
    p \#{text}
}

  entity!(:simple_html) do
    name = File.join(tempdir, 'simple.html.slim')
    File.open(name, 'w') { |file| file.write(simple_html_content) }
    name
  end

  simple_text_content = %{
<%= header %>

-------------

<%= text %>
}

  entity!(:simple_text) do
    name = File.join(tempdir, 'simple.text.erb')
    File.open(name, 'w') { |file| file.write(simple_text_content) }
    name
  end

  entity(:simple_content) do
    {
      :header => 'The Idea',
      :text => 'the idea is to remain in a state of constant departure while always arriving'
    }
  end

  # entities end

  it 'renders text' do
    html = generator.render_text('simple', Content.new(simple_content))
    expect(html).to eq %{
#{simple_content[:header]}\n
-------------\n
#{simple_content[:text]}
}

  end

  it 'renders html' do
    html = generator.render_html('simple', Content.new(simple_content))
    expect(html).to eq %{<!DOCTYPE html>
<html>
  <body>
    <h1>
      #{simple_content[:header]}
    </h1>
    <p>
      #{simple_content[:text]}
    </p>
  </body>
</html>}
  end

end
