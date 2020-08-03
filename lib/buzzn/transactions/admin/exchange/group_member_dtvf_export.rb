# coding: utf-8

require_relative '../exchange'
require_relative '../../../transactions'
require_relative '../../../schemas/transactions/admin/exchange/group_member_dtvf_export.rb'
require 'stringio'

# Exports the group's members as a csv.
class Transactions::Admin::Exchange::GroupMemberDtvfExport < Transactions::Base

  validate :schema
  authorize :allowed_roles

  add :warnings
  add :header
  map :export_group

  def schema
    Schemas::Transactions::Admin::Exchange::GroupMemberDtvfExport
  end

  def allowed_roles(permission_context:)
    permission_context.exchange.group.create
  end

  def warnings
    []
  end

  def result(warnings:, header:, export_group:, **)
    # The dtvf importer used by iswarwatt does not support utf8 encoding.
    (header + export_group).encode(Encoding.find('ISO-8859-1'))
  end

  # Skips fields, which will not be filled.
  # @param [number] Count of skipped fields, default 1.
  def skip(count = 1)
    @target << ';' * count
    @skiped += count
  end

  # Skips untils a specified field is reached.
  # @param [number] target to write the next field into.
  def jump_field(target)
    if @skiped > target
      raise Buzzn::ValidationError.new({field: ["Already at #{@skiped} but field #{target} was requested." \
            'Can not jump fields backwards.']})
    end

    skip(target - @skiped)
  end

  # Converts a phone number into the format:
  #   +[countrycode][space][citycode][space][number]
  # @param [person] target_person The person whos phone number to convert.
  # @return [String] the convererted number.
  def format_phone_number(target_person)
    target = target_person.phone
    if target.nil? || target.empty?
      return ''
    end

    prefix = ''
    suffix = ''
    target = target.sub(/-/, ' ')
    target = target.sub(%r{\/}, ' ')
    if target.starts_with?('+')
      prefix = target.sub(/\+([0-9]+) ?([0-9]*).*/, '+\1 \2')
      suffix = target.sub(/\+[0-9]+ ?([0-9]*)(.*)/, '\2')
    elsif target.start_with?('0')
      prefix = target.sub(/0 ?([0-9]*).*/, '+49 \1')
      suffix = target.sub(/0 ?([0-9]*)(.*)/, '\2')
    else
      raise Buzzn::ValidationError.new({phone_number: ["#{target_person.first_name} #{target_person.last_name}'s phone number'#{target}' does not match required format. Sample (+49 89 1234567890)"]}, target_person)
    end

    suffix = suffix.delete(' ')

    prefix + ' ' + suffix
  end

  def account_number(contract)
    sprintf("6%i%.3i",
            contract.contract_number % 100,
            contract.contract_number_addition)
  end

  def table(contract)
    person = contract.contact
    {
      'Konto' => account_number(contract),
      'Name (Adressattyp Unternehmen)' => person.last_name,
      'Unternehmensgegenstand' => '',
      'Name (Adressattyp natürl. Person)' => person.last_name,
      'Vorname (Adressattyp natürl. Person)' => person.first_name,
      'Name (Adressattyp keine Angabe)' => '',
      'Adressattyp' => '',
      'Kurzbezeichnung' => '',
      'EU-Land' => person.address.country,
      'EU-UStID' => '',
      'Anrede' => person.prefix == 'M' ? 'Herr' : 'Frau',
      'Titel/Akad. Grad' => person.title,
      'Adelstitel' => '',
      'Namensvorsatz' => '',
      'Adressart' => '',
      'Straße' => person.address.street,
      'Postfach' => '',
      'Postleitzahl' => person.address.zip,
      'Ort' => person.address.city,
      'Land' => person.address.country,
      'Versandzusatz' => '',
      'Adresszusatz' => '',
      'Abweichende Anrede' => '',
      'Abw. Zustellbezeichnung 1' => '',
      'Abw. Zustellbezeichnung 2' => '',
      'Kennz. Korrespondenzadresse' => '',
      'Adresse Gültig von' => person.address.updated_at,
      'Adresse Gültig bis' => '',
      'Telefon' => format_phone_number(person),
      'Bemerkung (Telefon)' => '',
      'Telefon GL' => '',
      'Bemerkung (Telefon GL)' => '',
      'E-Mail' => person.email,
      'Bemerkung (E-Mail)' => '',
      'Internet' => '',
      'Bemerkung (Internet)' => '',
      'Fax' => person.fax,
      'Bemerkung (Fax)' => '',
      'Sonstige' => '',
      'Bemerkung (Sonstige)' => '',
      'Bankleitzahl 1' => '',
      'Bankbezeichnung 1' => '',
      'Bank-Kontonummer 1' => '',
      'Länderkennzeichen 1' => '',
      'IBAN-Nr. 1' => person.bank_accounts.to_a[0]&.iban,
      'SWIFT-Code 1' => '',
      'Abw. Kontoinhaber 1' => person.bank_accounts.to_a[0]&.holder,
      'Kennz. Hauptbankverb. 1' => '',
      'Bankverb 1 Gültig von' => person.bank_accounts.to_a[0]&.updated_at,
      'Bankverb 1 Gültig bis' => '',
      'Bankleitzahl 2' => '',
      'Bankbezeichnung 2' => '',
      'Bank-Kontonummer 2' => '',
      'Länderkennzeichen 2' => '',
      'IBAN-Nr. 2' => person.bank_accounts.to_a[1]&.iban,
      'SWIFT-Code 2' => '',
      'Abw. Kontoinhaber 2' => person.bank_accounts.to_a[1]&.holder,
      'Kennz. Hauptbankverb. 2' => '',
      'Bankverb 2 Gültig von' => person.bank_accounts.to_a[1]&.updated_at,
      'Bankverb 2 Gültig bis' => '',
      'Bankleitzahl 3' => '',
      'Bankbezeichnung 3' => '',
      'Bank-Kontonummer 3' => '',
      'Länderkennzeichen 3' => '',
      'IBAN-Nr. 3' => person.bank_accounts.to_a[2]&.iban,
      'SWIFT-Code 3' => '',
      'Abw. Kontoinhaber 3' => person.bank_accounts.to_a[2]&.holder,
      'Kennz. Hauptbankverb. 3' => '',
      'Bankverb 3 Gültig von' => person.bank_accounts.to_a[2]&.updated_at,
      'Bankverb 3 Gültig bis' => '',
      'Bankleitzahl 4' => '',
      'Bankbezeichnung 4' => '',
      'Bank-Kontonummer 4' => '',
      'Länderkennzeichen 4' => '',
      'IBAN-Nr. 4' => person.bank_accounts.to_a[3]&.iban,
      'SWIFT-Code 4' => '',
      'Abw. Kontoinhaber 4' => person.bank_accounts.to_a[3]&.holder,
      'Kennz. Hauptbankverb. 4' => '',
      'Bankverb 4 Gültig von' => person.bank_accounts.to_a[3]&.updated_at,
      'Bankverb 4 Gültig bis' => '',
      'Bankleitzahl 5' => '',
      'Bankbezeichnung 5' => '',
      'Bank-Kontonummer 5' => '',
      'Länderkennzeichen 5' => '',
      'IBAN-Nr. 5' => person.bank_accounts.to_a[4]&.iban,
      'SWIFT-Code 5' => '',
      'Abw. Kontoinhaber 5' => person.bank_accounts.to_a[4]&.holder,
      'Kennz. Hauptbankverb. 5' => '',
      'Bankverb 5 Gültig von' => person.bank_accounts.to_a[4]&.updated_at,
      'Bankverb 5 Gültig bis' => '',
      'Briefanrede' => '',
      'Grußformel' => '',
      'Kunden-/Lief.-Nr.' => '',
      'Steuernummer' => '',
      'Sprache' => '',
      'Ansprechpartner' => '',
      'Vertreter' => '',
      'Sachbearbeiter' => '',
      'Diverse-Konto' => '',
      'Ausgabeziel' => '',
      'Währungssteuerung' => '',
      'Kreditlimit (Debitor)' => '',
      'Zahlungsbedingung' => '',
      'Fälligkeit in Tagen (Debitor)' => '',
      'Skonto in Prozent (Debitor)' => '',
      'Kreditoren-Ziel 1 Tg.' => '',
      'Kreditoren-Skonto 1 %' => '',
      'Kreditoren-Ziel 2 Tg.' => '',
      'Kreditoren-Skonto 2 %' => '',
      'Kreditoren-Ziel 3 Brutto Tg.' => '',
      'Kreditoren-Ziel 4 Tg.' => '',
      'Kreditoren-Skonto 4 %' => '',
      'Kreditoren-Ziel 5 Tg.' => '',
      'Kreditoren-Skonto 5 %' => '',
      'Mahnung' => '',
      'Kontoauszug' => '',
      'Mahntext 1' => '',
      'Mahntext 2' => '',
      'Mahntext 3' => '',
      'Kontoauszugstext' => '',
      'Mahnlimit Betrag' => '',
      'Mahnlimit %' => '',
      'Zinsberechnung' => '',
      'Mahnzinssatz 1' => '',
      'Mahnzinssatz 2' => '',
      'Mahnzinssatz 3' => '',
      'Lastschrift' => '',
      'Mandantenbank' => '',
      'Zahlungsträger' => '',
      'Indiv. Feld 1' => '',
      'Indiv. Feld 2' => '',
      'Indiv. Feld 3' => '',
      'Indiv. Feld 4' => '',
      'Indiv. Feld 5' => '',
      'Indiv. Feld 6' => '',
      'Indiv. Feld 7' => '',
      'Indiv. Feld 8' => '',
      'Indiv. Feld 9' => '',
      'Indiv. Feld 10' => '',
      'Indiv. Feld 11' => '',
      'Indiv. Feld 12' => '',
      'Indiv. Feld 13' => '',
      'Indiv. Feld 14' => '',
      'Indiv. Feld 15' => '',
      'Abweichende Anrede (Rechnungsadresse)' => '',
      'Adressart (Rechnungsadresse)' => '',
      'Straße (Rechnungsadresse)' => '',
      'Postfach (Rechnungsadresse)' => '',
      'Postleitzahl (Rechnungsadresse)' => '',
      'Ort (Rechnungsadresse)' => '',
      'Land (Rechnungsadresse)' => '',
      'Versandzusatz (Rechnungsadresse)' => '',
      'Adresszusatz (Rechnungsadresse)' => '',
      'Abw. Zustellbezeichnung 1 (Rechnungsadresse)' => '',
      'Abw. Zustellbezeichnung 2 (Rechnungsadresse)' => '',
      'Adresse Gültig von (Rechnungsadresse)' => '',
      'Adresse Gültig bis (Rechnungsadresse)' => '',
      'Bankleitzahl 6' => '',
      'Bankbezeichnung 6' => '',
      'Bank-Kontonummer 6' => '',
      'Länderkennzeichen 6' => '',
      'IBAN-Nr. 6' => person.bank_accounts.to_a[5]&.iban,
      'SWIFT-Code 6' => '',
      'Abw. Kontoinhaber 6' => person.bank_accounts.to_a[5]&.holder,
      'Kennz. Hauptbankverb. 6' => '',
      'Bankverb 6 Gültig von' => person.bank_accounts.to_a[5]&.updated_at,
      'Bankverb 6 Gültig bis' => '',
      'Bankleitzahl 7' => '',
      'Bankbezeichnung 7' => '',
      'Bank-Kontonummer 7' => '',
      'Länderkennzeichen 7' => '',
      'IBAN-Nr. 7' => person.bank_accounts.to_a[6]&.iban,
      'SWIFT-Code 7' => '',
      'Abw. Kontoinhaber 7' => person.bank_accounts.to_a[6]&.holder,
      'Kennz. Hauptbankverb. 7' => '',
      'Bankverb 7 Gültig von' => person.bank_accounts.to_a[6]&.updated_at,
      'Bankverb 7 Gültig bis' => '',
      'Bankleitzahl 8' => '',
      'Bankbezeichnung 8' => '',
      'Bank-Kontonummer 8' => '',
      'Länderkennzeichen 8' => '',
      'IBAN-Nr. 8' => person.bank_accounts.to_a[7]&.iban,
      'SWIFT-Code 8' => '',
      'Abw. Kontoinhaber 8' => person.bank_accounts.to_a[7]&.holder,
      'Kennz. Hauptbankverb. 8' => '',
      'Bankverb 8 Gültig von' => person.bank_accounts.to_a[7]&.updated_at,
      'Bankverb 8 Gültig bis' => '',
      'Bankleitzahl 9' => '',
      'Bankbezeichnung 9' => '',
      'Bank-Kontonummer 9' => '',
      'Länderkennzeichen 9' => '',
      'IBAN-Nr. 9' => person.bank_accounts.to_a[8]&.iban,
      'SWIFT-Code 9' => '',
      'Abw. Kontoinhaber 9' => person.bank_accounts.to_a[8]&.holder,
      'Kennz. Hauptbankverb. 9' => '',
      'Bankverb 9 Gültig von' => person.bank_accounts.to_a[8]&.updated_at,
      'Bankverb 9 Gültig bis' => '',
      'Bankleitzahl 10' => '',
      'Bankbezeichnung 10' => '',
      'Bank-Kontonummer 10' => '',
      'Länderkennzeichen 10' => '',
      'IBAN-Nr. 10' => person.bank_accounts.to_a[9]&.iban,
      'SWIFT-Code 10' => '',
      'Abw. Kontoinhaber 10' => person.bank_accounts.to_a[9]&.holder,
      'Kennz. Hauptbankverb. 10' => '',
      'Bankverb 10 Gültig von' => person.bank_accounts.to_a[9]&.updated_at,
      'Bankverb 10 Gültig bis' => '',
      'Nummer Fremdsystem' => '',
      'Insolvent' => '',
      'SEPA-Mandatsreferenz 2' => person.contracts.to_a[1]&.mandate_reference,
      'SEPA-Mandatsreferenz 3' => person.contracts.to_a[2]&.mandate_reference,
      'SEPA-Mandatsreferenz 1' => person.contracts.to_a[0]&.mandate_reference,
      'SEPA-Mandatsreferenz 4' => person.contracts.to_a[3]&.mandate_reference,
      'SEPA-Mandatsreferenz 5' => person.contracts.to_a[4]&.mandate_reference,
      'SEPA-Mandatsreferenz 6' => person.contracts.to_a[5]&.mandate_reference,
      'SEPA-Mandatsreferenz 7' => person.contracts.to_a[6]&.mandate_reference,
      'SEPA-Mandatsreferenz 8' => person.contracts.to_a[7]&.mandate_reference,
      'SEPA-Mandatsreferenz 9' => person.contracts.to_a[8]&.mandate_reference,
      'SEPA-Mandatsreferenz 10' => person.contracts.to_a[9]&.mandate_reference,
      'Verknüpftes OPOS-Konto' => '',
      'Mahnsperre bis' => '',
      'Lastschriftsperre bis' => '',
      'Zahlungssperre bis' => '',
      'Gebührenberechnung' => '',
      'Mahngebühr 1' => '',
      'Mahngebühr 2' => '',
      'Mahngebühr 3' => '',
      'Pauschalenberechnung' => '',
      'Verzugspauschale 1' => '',
      'Verzugspauschale 2' => '',
      'Verzugspauschale 3' => '',
      'Alternativer Suchname' => '',
      'Status' => '',
      'Anschrift manuell geändert (Korrespondenzadresse)' => '',
      'Anschrift individuell (Korrespondenzadresse)' => '',
      'Anschrift manuell geändert (Rechnungsadresse)' => '',
      'Anschrift individuell (Rechnungsadresse)' => '',
      'Fristberechnung bei Debitor' => '',
      'Mahnfrist 1' => '',
      'Mahnfrist 2' => '',
      'Mahnfrist 3' => '',
      'Letzte Frist' => ''
    }
    end

  def header
    <<~HEADER
      DTVF;700;16;Debitoren/Kreditoren;5;2,01907E+16;;RE;info;;557718;38017;20190101;5;;;;;;0;;;;;;74252;4;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      HEADER
  end

  # Exports the given group.
  def export_group(params:, resource:, header:, **)
    target = StringIO.new
    target << header
    head, *tail = resource.contracts.select{|c| c.is_a? Contract::LocalpoolPowerTakerResource}.map {|u| table(u) }
    target << head.keys.join(';')
    target << "\n" << head.values.join(';')
    tail.each{|p| target << "\n" << p.values.join(';')}
    target.string
  end
end
