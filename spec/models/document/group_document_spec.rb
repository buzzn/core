describe GroupDocument do

  entity!(:document) { Document.create('test/contract/file.jpg', File.read('spec/data/test.pdf'))}
  entity!(:group) { create(:group) }

  it 'does not allow double entries' do
    GroupDocument.create(document_id: document.id, group_id: group.id)
    expect do
      GroupDocument.create(document_id: document.id, group_id: group.id)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

end