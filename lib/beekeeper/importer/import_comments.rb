# coding: utf-8
class Beekeeper::Importer::ImportComments

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    @logger.section = 'import-comments'
  end

  def find_comments(contract_number, contract_number_addition)
    Beekeeper::Minipool::Kommentare.where(:vertragsnummer => contract_number,
                                          :nummernzusatz => contract_number_addition).collect { |c| c.converted_attributes }
  end

  def run(localpool)
    localpool.contracts.each do |contract|
      find_comments(contract.contract_number, contract.contract_number_addition).each do |attr|
        logger.info("created comment for #{contract.full_contract_number}", extra_data: attr)
        comment = Comment.create(attr)
        comment.created_at = attr[:created_at]
        comment.save
        contract.comments << comment
      end
    end
    localpool.meters.each do |meter|
      contract_number, contract_number_addition = meter.legacy_buzznid.split('/')
      find_comments(contract_number, contract_number_addition).each do |attr|
        logger.info("created comment for #{meter.legacy_buzznid}", extra_data: attr)
        comment = Comment.create(attr)
        comment.created_at = attr[:created_at]
        comment.save
        meter.comments << comment
      end
      # extract berechnet* Stuff
      msb_gerät = Beekeeper::Minipool::MsbGerät.find_by(vertragsnummer: contract_number, nummernzusatz: contract_number_addition)
      if msb_gerät.berechnet_any?
        comment = Comment.create(author: 'Beekeeper Importer', content: msb_gerät.berechnet_comment)
        meter.comments << comment
      end
    end
  end

end
