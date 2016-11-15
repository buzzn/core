# coding: utf-8
#
# http://www.bundesbank.de/Redaktion/DE/Downloads/Aufgaben/Unbarer_Zahlungsverkehr/Bankleitzahlen/merkblatt_bankleitzahlendatei.pdf
#
# iban to blz for germany: page 36 in
# https://www.swift.com/sites/default/files/resources/swift_standards_ibanregistry.pdf
#
class Bank < ActiveRecord::Base

  COLUMN = { blz: 8,
             service_type: 1,
             description: 58,
             zip: 5,
             place: 35,
             name: 27,
             nr_4_pan: 5,
             bic: 11,
             checksum_method: 2,
             id: 6,
             action: 1,
             will_delete: 1,
             next_blz: 8,
             iban_rule: 6 }

  FIELDS = [ :blz, :description, :zip, :place, :name, :bic, :id ]

  def self.attributes_protected_by_default
    # default is ["id", "type"]
    ["type"]
  end

  def self.find_by_bic(bic)
    unless result = get_by_bic(bic)
      not_found("bic=#{bic}")
    end
    result
  end

  def self.find_by_iban(iban)
    unless result = get_by_iban(iban)
      not_found("iban=#{iban}")
    end
    result
  end

  def self.update_from(data)
    split(data).each do |line|
      params = as_params(line)
      if params[:service_type] != '2' && params[:bic] != ''
        process(params)
      end
    end
  end

  private

  def self.split(data)
    # first assume they use utf-8 and fall back to latin-1
    begin
      data.split(/\r?\n/)
    rescue ArgumentError
      data.force_encoding(Encoding::ISO_8859_1).split(/\r?\n/)
    end
  end

  def self.process(params)
    if bank = get(params)
      update_or_delete(bank, params)
    else
      only_create(params)
    end
  end

  def self.as_params(line)
    params = {}
    pos = 0
    COLUMN.each do |name, len|
      last = pos + len
      params[name] = line[pos..last - 1].strip.encode(Encoding::UTF_8)
      pos = last
    end
    params  
  end

  def self.update_or_delete(bank, params)
    case params[:action]
    when 'A'
      bank.update(filter_params(params))
    when 'U'
      nil
    when 'M'
      bank.update(filter_params(params))
    when 'D'
      bank.delete
    else
      raise "unknonw action #{params[:action]}"
    end
  end

  def self.filter_params(params)
    params.reject { |k,v| ! FIELDS.include?(k) }
  end

  def self.only_create(params)
    if params[:action] != 'D'
      create!(filter_params(params))
    end
  end

  def self.get(params)
    where(id: params[:id]).limit(1).first
  end

  def self.get_by_bic(bic)
    if bic
      bic.strip!
      if bic.size < 11     
        bic += 'X' * (11 - bic.size)
      end
      where(bic: bic).limit(1).first
    end
  end

  def self.get_by_iban(iban)
    if iban
      iban.strip!
      if iban.start_with?('DE')
        where(blz: iban[4..11]).limit(1).first
      end
    end
  end

  def self.not_found(msg)
    raise Buzzn::RecordNotFound.new("#{self} with #{msg} not found")
  end
end
