# coding: utf-8
describe "Comment Model" do

  it 'filters comment', :retry => 3 do
    comment = Fabricate(:comment)
    Fabricate(:comment)

    [comment.title, comment.subject, comment.body].each do |val|

      len = val.size/2

      [val, val.upcase, val.downcase, val[0..len], val[-len..-1]].each do |value|
        comments = Comment.filter(value)
        expect(comments.first).to eq comment
      end
    end
  end


  it 'can not find anything', :retry => 3 do
    Fabricate(:comment)
    comments = Comment.filter('Der Clown ist müde und geht nach Hause.')
    expect(comments.size).to eq 0
  end


  it 'filters comment with no params', :retry => 3 do
    Fabricate(:comment)
    Fabricate(:comment)

    comments = Comment.filter(nil)
    expect(comments.size).to eq 2
  end
end
