module Accounting
  class Entry < ActiveRecord::Base

    self.table_name = :accounting_entries

    belongs_to :booked_by, class_name: 'Account::Base'
    belongs_to :contract, class_name: 'Contract::Base'

    before_create :check_checksum

    scope :for_contract, ->(contract) { where(contract: contract) }

    # entries are readonly
    def readonly?
      !(new_record? || !changed?)
    end

    def calculate_checksum
      ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute('LOCK TABLE accounting_entries')
        # get previous
        self.previous_checksum = Accounting::Entry.select(:checksum).last&.checksum
      end
      sha256 = Digest::SHA256.new
      sha256.update(self.previous_checksum || '')
      sha256.update(self.amount.to_s)
      sha256.update(self.created_at.to_i.to_s)
      sha256.hexdigest
    end

    private

    def check_checksum
      if self.checksum.nil?
        if self.created_at.nil?
          self.created_at = Time.now
        end
        self.checksum = calculate_checksum
      end
    end

  end
end
