require 'csv'
require 'buzzn/utils/file'

class ZipToPrice < ActiveRecord::Base

  COLUMNS_ET = {
    zip: 'PLZ',
    community: 'Ort',
    dso: 'Netzbetreiber',
    baseprice_euro_year_et: 'Grundpreis ET',
    unitprice_cents_kwh_et: 'Arbeitspreis HT ET',
    measurement_euro_year_et: 'Messstellenbetrieb ET',
    ka: 'Konzessionsabgabe (ct/kWh)',
    vnb: 'Verbandsnummer'
  }

  COLUMNS_DT = {
    zip: 'PLZ',
    community: 'Ort',
    baseprice_euro_year_dt: 'Grundpreis DT',
    unitprice_cents_kwh_dt: 'Arbeitspreis DT',
    measurement_euro_year_dt: 'Messstellenbetrieb DT',
    vnb: 'Verbandsnummer',
  }

  # some DSOs screw up our price calculation, we remove them manually
  # first is VNB, second is optional list of zip_codes where to keep them
  DSO_BY_VNB_REMOVE = [
    [9900113000007, nil],
    [9900143000001, [84435]],
    [9907497000000, nil],
    [9900638000003, nil],
    [9900632000009, nil],
    [9907001000008, nil],
    [9900251000000, nil]
  ]

  def self.from_csv(file, is_et)
    data = Buzzn::Utils::File.read(file)
    # none destructive update
    update_all(updated: false) if is_et
    CSV.parse(data.gsub(/\r\n?/, "\n"), col_sep: ';', headers: true) do |row|
      values = Hash[row.to_a].values

      if is_et
        if values.include?(nil) or values.size != COLUMNS_ET.keys.size
          logger.info "skip corrupted row: #{row}"
        else
          params = Hash[COLUMNS_ET.keys.zip(values)]
          params[:updated] = true
          create!(params)
        end
      else
        if values.include?(nil) or values.size != COLUMNS_DT.keys.size
          logger.info "skip corrupted row: #{row}"
        else
          params = Hash[COLUMNS_DT.keys.zip(values)]
          et_obj = where(:zip => params[:zip], :vnb => params[:vnb]).first
          if et_obj.nil?
            logger.info "No ET row for #{params}"
          else
            et_obj.update(params)
          end
        end
      end
    end
    where(updated: false).delete_all if is_et
  end

  def self.clean_dsos
    where(vnb: DSO_BY_VNB_REMOVE.select { |x| x[1].nil? }
                                .collect { |x| x[0] })
                                .delete_all
    DSO_BY_VNB_REMOVE.reject { |x| x[1].nil? }.each do |vnb_zip|
      where(vnb: vnb_zip[0]).where.not(zip: vnb_zip[1]).delete_all
    end
  end

  def self.to_csv(io)
    io << COLUMNS.values.join(';') << "\n"
    ZipToPrice.all.order(:zip, :state, :community, :dso).each do |i|
      row = i.attributes.values[1..-2].join(';')
      io << row << "\n"
    end
  end

  scope :by_zip, ->(zip) { where(zip: zip) }

  private

  def self.logger; @_logger ||= Buzzn::Logger.new(self); end

end
