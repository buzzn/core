require_relative 'filterable'
require_relative '../uploaders/person_image_uploader'

class Person < ActiveRecord::Base

  self.table_name = :persons

  include Filterable

  belongs_to :address
  belongs_to :customer_number, foreign_key: :customer_number

  has_and_belongs_to_many :roles
  has_many :bank_accounts, foreign_key: :owner_person_id
  has_many :contracts, class_name: 'Contract::Base', foreign_key: 'customer_person_id'

  before_destroy :has_contracts?

  mount_uploader :image, PersonImageUploader

  enum prefix: {
         female: 'F',
         male:   'M'
       }

  enum titles: {
         prof: 'Prof.',
         dr: 'Dr.',
         prof_dr: 'Prof. Dr.'
       }

  enum preferred_language: {
         german:  'de',
         english: 'en'
       }

  def has_contracts?
    self.contracts.any?
  end

  def self.search_attributes
    [:first_name, :last_name, :email]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def contact_email
    self.email
  end

  def contracts
    Contract::Base.where(customer_person: self)
  end

  # roles related methods

  def has_role?(name, resource = nil)
    !detect_role(name, resource).nil?
  end

  def detect_role(name, resource)
    if resource
      type = resource.class.to_s
      roles.find {|r| r.attributes['name'] == name && r.resource_id == resource.id && r.resource_type == type }
    else
      roles.find {|r| r.attributes['name'] == name }
    end
  end

  def add_role(name, resource = nil)
    self.roles << find_role(name, resource)
  end

  def remove_role(name, resource = nil)
    self.roles.delete find_role(name, resource)
  end

  def find_role(name, resource)
    if resource
      Role.where(name: name, resource_id: resource.id, resource_type: resource.class).first || Role.new(name: name, resource_id: resource.id, resource_type: resource.class)
    else
      Role.where(name: name, resource_id: nil, resource_type: nil).first || Role.new(name: name)
    end
  end
  private :find_role

  scope :with_roles, ->(resource = nil, *names) {
    rel = joins('INNER JOIN persons_roles ON persons_roles.person_id = persons.id').joins('INNER JOIN roles ON persons_roles.role_id = roles.id')
    if resource
      rel = rel.where('roles.resource_id=?', resource.id)
    end
    if !names.empty?
      rel = rel.where('roles.name in (?)', names)
    end
    rel
  }

end
