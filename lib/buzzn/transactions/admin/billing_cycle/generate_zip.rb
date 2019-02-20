require 'zip'

require_relative '../billing_cycle'
class Transactions::Admin::BillingCycle::GenerateZip < Transactions::Base

  add :generate_status_file
  add :generate_zip
  map :wrap_up

  def generate_status_file(resource:, params:)
    status = "Rechnungsnummer;Vertragsnummer;Marktlokation;Status\r\n"
    resource.object.billings.sort_by { |x| x.contract.contract_number_addition }.each do |b|
      status += "#{b.full_invoice_number};#{b.contract.full_contract_number};#{b.contract.register_meta.name};#{b.status}\r\n"
    end
    status
  end

  def generate_zip(resource:, params:, generate_status_file:)
    zio = StringIO.new('')
    buffer = ::Zip::OutputStream.write_buffer(zio) do |zos|
      zos.put_next_entry('status.csv', nil, ::Zip::Entry::STORED)
      zos << generate_status_file
      resource.object.billings.each do |b|
        document = b.documents.order(:created_at).last
        unless document.nil?
          zos.put_next_entry(document.filename, nil, ::Zip::Entry::STORED)
          zos << document.read
        end
      end
    end
    buffer
  end

  def wrap_up(generate_zip:, **)
    generate_zip
  end

end
