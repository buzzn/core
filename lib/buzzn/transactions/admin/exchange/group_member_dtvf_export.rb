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
  add :export_group
  map :result

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
      raise Buzzn::ValidationError.new "Already at #{@skiped} but field #{target} was requested." \
            'Can not jump fields backwards.'
    end

    skip(target - @skiped)
  end

  # Fills a column using the given value.
  # @param [String] value to fill with.
  def column(value)
    @target << value
    skip
  end

  # Exports the given bank account.
  # @param [BankAccountResource] target to export.
  def export_bank_account(target)
    skip(4)
    column(target.iban)
    skip(2) # empty and Swift code
    column(target.holder)
    column('1') #kennzeichen hauptbankverbindung
    column(target.updated_at)
    skip
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
      raise Buzzn::ValidationError.new "#{target_person.first_name} #{target_person.last_name}'s phone number'#{target}' does not match required format. Sample (+49 89 1234567890)"
    end

    suffix = suffix.delete(' ')

    prefix + ' ' + suffix
  end

  # Exports a given person.
  # @param [PersonResource] person to export.
  def export_person(person)
    @skiped = 0

    if person.contracts.size.positive?
      column("#{person.contracts.first.contract_number}/#{person.contracts.first.contract_number_addition}")
    else
      return
    end
    skip(2)
    column(person.last_name)
    column(person.first_name)
    skip # Name (Adressattyp keine Angabe)
    column('1') # Adressattyp
    column("#{person.last_name}, #{person.first_name}")
    column(person.address.country)
    skip
    column(person.prefix == 'M' ? 'Herr' : 'Frau')
    column(person.title)
    skip(2) # Adelstitel, Namensvorsatz
    column('STR') # Adressart
    column(person.address.street)
    skip #Postfach
    column(person.address.zip)
    column(person.address.city)
    column(person.address.country)
    skip(5) # Versandzusatz,Adresszusatz, Abweichende Anrede,
    # Abw. Zustellbezeichnung 1, Abw. Zustellbezeichnung 2
    column('1') # Kennz. Korrespondenzadresse
    column(person.address.updated_at)
    skip
    column(format_phone_number(person))
    skip(3)
    column(person.email)
    skip(3)
    column(person.fax)
    skip(3)
    person.bank_accounts.each { |b| export_bank_account(b)}
    person.bank_accounts.each { |b| export_bank_account(b)}

    # Jump to SEPA field.
    jump_field(221)

    if person.contracts.size.positive?
      person.contracts.each {|c| column(c.mandate_reference)}
    end

    @target << "\n"
  end

  # Exports the given group.
  def export_group(params:, resource:, **)
    @target = StringIO.new
    resource.persons.each {|u| export_person(u) }
    @target.string
  end

  def header
    <<~HEADER
      DTVF;700;16;Debitoren/Kreditoren;5;2,01907E+16;;RE;info;;557718;38017;20190101;5;;;;;;0;;;;;;74252;4;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      Konto;Name (Adressattyp Unternehmen);Unternehmensgegenstand;Name (Adressattyp natürl. Person);Vorname (Adressattyp natürl. Person);Name (Adressattyp keine Angabe);Adressattyp;Kurzbezeichnung;EU-Land;EU-UStID;Anrede;Titel/Akad. Grad;Adelstitel;Namensvorsatz;Adressart;Straße;Postfach;Postleitzahl;Ort;Land;Versandzusatz;Adresszusatz;Abweichende Anrede;Abw. Zustellbezeichnung 1;Abw. Zustellbezeichnung 2;Kennz. Korrespondenzadresse;Adresse Gültig von;Adresse Gültig bis;Telefon;Bemerkung (Telefon);Telefon GL;Bemerkung (Telefon GL);E-Mail;Bemerkung (E-Mail);Internet;Bemerkung (Internet);Fax;Bemerkung (Fax);Sonstige;Bemerkung (Sonstige);Bankleitzahl 1;Bankbezeichnung 1;Bank-Kontonummer 1;Länderkennzeichen 1;IBAN-Nr. 1;Leerfeld;SWIFT-Code 1;Abw. Kontoinhaber 1;Kennz. Hauptbankverb. 1;Bankverb 1 Gültig von;Bankverb 1 Gültig bis;Bankleitzahl 2;Bankbezeichnung 2;Bank-Kontonummer 2;Länderkennzeichen 2;IBAN-Nr. 2;Leerfeld;SWIFT-Code 2;Abw. Kontoinhaber 2;Kennz. Hauptbankverb. 2;Bankverb 2 Gültig von;Bankverb 2 Gültig bis;Bankleitzahl 3;Bankbezeichnung 3;Bank-Kontonummer 3;Länderkennzeichen 3;IBAN-Nr. 3;Leerfeld;SWIFT-Code 3;Abw. Kontoinhaber 3;Kennz. Hauptbankverb. 3;Bankverb 3 Gültig von;Bankverb 3 Gültig bis;Bankleitzahl 4;Bankbezeichnung 4;Bank-Kontonummer 4;Länderkennzeichen 4;IBAN-Nr. 4;Leerfeld;SWIFT-Code 4;Abw. Kontoinhaber 4;Kennz. Hauptbankverb. 4;Bankverb 4 Gültig von;Bankverb 4 Gültig bis;Bankleitzahl 5;Bankbezeichnung 5;Bank-Kontonummer 5;Länderkennzeichen 5;IBAN-Nr. 5;Leerfeld;SWIFT-Code 5;Abw. Kontoinhaber 5;Kennz. Hauptbankverb. 5;Bankverb 5 Gültig von;Bankverb 5 Gültig bis;Leerfeld;Briefanrede;Grußformel;Kunden-/Lief.-Nr.;Steuernummer;Sprache;Ansprechpartner;Vertreter;Sachbearbeiter;Diverse-Konto;Ausgabeziel;Währungssteuerung;Kreditlimit (Debitor);Zahlungsbedingung;Fälligkeit in Tagen (Debitor);Skonto in Prozent (Debitor);Kreditoren-Ziel 1 Tg.;Kreditoren-Skonto 1 %;Kreditoren-Ziel 2 Tg.;Kreditoren-Skonto 2 %;Kreditoren-Ziel 3 Brutto Tg.;Kreditoren-Ziel 4 Tg.;Kreditoren-Skonto 4 %;Kreditoren-Ziel 5 Tg.;Kreditoren-Skonto 5 %;Mahnung;Kontoauszug;Mahntext 1;Mahntext 2;Mahntext 3;Kontoauszugstext;Mahnlimit Betrag;Mahnlimit %;Zinsberechnung;Mahnzinssatz 1;Mahnzinssatz 2;Mahnzinssatz 3;Lastschrift;Leerfeld;Mandantenbank;Zahlungsträger;Indiv. Feld 1;Indiv. Feld 2;Indiv. Feld 3;Indiv. Feld 4;Indiv. Feld 5;Indiv. Feld 6;Indiv. Feld 7;Indiv. Feld 8;Indiv. Feld 9;Indiv. Feld 10;Indiv. Feld 11;Indiv. Feld 12;Indiv. Feld 13;Indiv. Feld 14;Indiv. Feld 15;Abweichende Anrede (Rechnungsadresse);Adressart (Rechnungsadresse);Straße (Rechnungsadresse);Postfach (Rechnungsadresse);Postleitzahl (Rechnungsadresse);Ort (Rechnungsadresse);Land (Rechnungsadresse);Versandzusatz (Rechnungsadresse);Adresszusatz (Rechnungsadresse);Abw. Zustellbezeichnung 1 (Rechnungsadresse);Abw. Zustellbezeichnung 2 (Rechnungsadresse);Adresse Gültig von (Rechnungsadresse);Adresse Gültig bis (Rechnungsadresse);Bankleitzahl 6;Bankbezeichnung 6;Bank-Kontonummer 6;Länderkennzeichen 6;IBAN-Nr. 6;Leerfeld;SWIFT-Code 6;Abw. Kontoinhaber 6;Kennz. Hauptbankverb. 6;Bankverb 6 Gültig von;Bankverb 6 Gültig bis;Bankleitzahl 7;Bankbezeichnung 7;Bank-Kontonummer 7;Länderkennzeichen 7;IBAN-Nr. 7;Leerfeld;SWIFT-Code 7;Abw. Kontoinhaber 7;Kennz. Hauptbankverb. 7;Bankverb 7 Gültig von;Bankverb 7 Gültig bis;Bankleitzahl 8;Bankbezeichnung 8;Bank-Kontonummer 8;Länderkennzeichen 8;IBAN-Nr. 8;Leerfeld;SWIFT-Code 8;Abw. Kontoinhaber 8;Kennz. Hauptbankverb. 8;Bankverb 8 Gültig von;Bankverb 8 Gültig bis;Bankleitzahl 9;Bankbezeichnung 9;Bank-Kontonummer 9;Länderkennzeichen 9;IBAN-Nr. 9;Leerfeld;SWIFT-Code 9;Abw. Kontoinhaber 9;Kennz. Hauptbankverb. 9;Bankverb 9 Gültig von;Bankverb 9 Gültig bis;Bankleitzahl 10;Bankbezeichnung 10;Bank-Kontonummer 10;Länderkennzeichen 10;IBAN-Nr. 10;Leerfeld;SWIFT-Code 10;Abw. Kontoinhaber 10;Kennz. Hauptbankverb. 10;Bankverb 10 Gültig von;Bankverb 10 Gültig bis;Nummer Fremdsystem;Insolvent;SEPA-Mandatsreferenz 1;SEPA-Mandatsreferenz 2;SEPA-Mandatsreferenz 3;SEPA-Mandatsreferenz 4;SEPA-Mandatsreferenz 5;SEPA-Mandatsreferenz 6;SEPA-Mandatsreferenz 7;SEPA-Mandatsreferenz 8;SEPA-Mandatsreferenz 9;SEPA-Mandatsreferenz 10;Verknüpftes OPOS-Konto;Mahnsperre bis;Lastschriftsperre bis;Zahlungssperre bis;Gebührenberechnung;Mahngebühr 1;Mahngebühr 2;Mahngebühr 3;Pauschalenberechnung;Verzugspauschale 1;Verzugspauschale 2;Verzugspauschale 3;Alternativer Suchname;Status;Anschrift manuell geändert (Korrespondenzadresse);Anschrift individuell (Korrespondenzadresse);Anschrift manuell geändert (Rechnungsadresse);Anschrift individuell (Rechnungsadresse);Fristberechnung bei Debitor;Mahnfrist 1;Mahnfrist 2;Mahnfrist 3;Letzte Frist
      HEADER
  end

end
