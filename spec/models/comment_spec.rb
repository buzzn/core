# coding: utf-8
describe "Comment Model" do

  it 'filters comment' do
    comment = Fabricate(:comment)
    Fabricate(:comment)

    [comment.title, comment.subject, comment.body].each do |val|
      
      [val, val.upcase, val.downcase, val[0..50], val[-50..-1]].each do |value|
        comments = Comment.filter(value)
        expect(comments.first).to eq comment
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:comment)
    comments = Comment.filter('Der Clown ist müde und geht nach Hause.')
    expect(comments.size).to eq 0
  end


  it 'filters comment with no params' do
    Fabricate(:comment)
    Fabricate(:comment)

    comments = Comment.filter(nil)
    expect(comments.size).to eq 2
  end
end
