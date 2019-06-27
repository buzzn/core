# == Schema Information
#
# Table name: minipooldb.kommentare
#
#  vertragsnummer :integer          not null
#  kommentar      :string(1000)     not null
#  autor          :string(20)       not null
#  datum          :datetime         not null
#  id             :integer          not null, primary key
#  nummernzusatz  :integer          not null
#

class Beekeeper::Minipool::Kommentare < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.kommentare'

  def converted_attributes
    {
      author: autor,
      content: kommentar,
      created_at: datum
    }
  end

end
