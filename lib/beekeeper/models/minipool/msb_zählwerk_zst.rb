# == Schema Information
#
# Table name: minipooldb.msb_zählwerk_zst
#
#  vertragsnummer  :integer          not null
#  nummernzusatz   :integer          not null
#  zählwerkID      :integer          not null
#  ablesezeitpunkt :string(16)
#  messwert        :float            not null
#  ablesegrund     :string(60)       not null
#  qualitaet       :string(60)       not null
#  ableser         :string(25)       not null
#  zaehlernummer   :string(45)       not null
#  statuszst       :string(45)       not null
#  id              :integer          not null, primary key
#

class Beekeeper::Minipool::MsbZählwerkZst < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.msb_zählwerk_zst'

  include Beekeeper::ImportWarnings

  def converted_attributes
    @converted_attributes ||= {
      raw_value: messwert * 1000,
      value:     messwert * 1000,
      comment:   ablesegrund =~ /Gerätewechsel/i ? zaehlernummer : '',
      date:      Date.parse(ablesezeitpunkt),
      unit:      'Wh',
      reason:    map_reason,
      quality:   map_quality,
      source:    map_source,
      status:    map_status,
      read_by:   map_read_by,
    }
  end

  REASON_MAP = {
    'Geräteeinbau' => 'IOM',
    'Gerätewechsel 1' => 'COM1',
    'Gerätewechsel 2' => 'COM2',
    'Geräteausbau' => 'ROM',
    'Turnusablesung' => 'PMR',
    'Zwischenablesung' => 'COT',
    'Vertragswechsel' => 'COS',
    'Geräteparameteränderung' => 'CMP',
    'Bilanzierungsgebietswechsel' => 'COB'
  }


  def map_reason
    REASON_MAP[ablesegrund.strip]
  end

  QUALITY_MAP = {
    '20 - Nicht verwendbarer Wert' => '20',
    '67 - Ersatzwert, geschätzt, veranschl.' => '67',
    '79 - Energiemenge summiert' => '79',
    '187 - Prognosewert' => '187',
    '220 - Abgelesener Wert' => '220',
    '201 - Vorschlagswert' => '201',
  }

  def map_quality
    QUALITY_MAP[qualitaet.strip]
  end

  def map_source
    if ableser.strip == 'bM'
      'SM'
    else
      'MAN'
    end
  end

  STATUS_MAP = {
    'Z84' => 'Z84',
    'Z86' => 'Z86',
  }

  def map_status
    STATUS_MAP[statuszst.strip]
  end

  READ_BY_MAP = {
    'bM' => 'BN',
    'LSN' => 'SN',
    'Kunde/LSG' => 'SG',
    'VNB' => 'VNB'
  }

  def map_read_by
    READ_BY_MAP[ableser.strip]
  end
end
