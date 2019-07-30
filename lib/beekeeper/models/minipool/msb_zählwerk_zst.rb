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
      raw_value: value,
      value:     value,
      comment:   comment,
      date:      Date.parse(ablesezeitpunkt),
      unit:      'Wh',
      reason:    map_reason,
      quality:   map_quality,
      source:    map_source,
      status:    statuszst.strip,
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

  def comment
    if ablesegrund =~ /Gerätewechsel/i
      "Zählernummer: #{zaehlernummer}"
    end
  end

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

  READ_BY_MAP = {
    'bM' => 'BN',
    'LSN' => 'SN',
    'Kunde/LSG' => 'SG',
    'VNB' => 'VNB'
  }

  def map_read_by
    READ_BY_MAP[ableser.strip]
  end

  # beekeeper stores the value in kWh (as double), we store it in Wh (as integer). So if we just multiply the beekeeper
  # value by 1000, we sometimes get floating point math errors like these:
  # 132479.2 * 1000 = 132479200.00000001
  def value
    (BigDecimal.new(messwert.to_s) * 1000).round
  end

end
