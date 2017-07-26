# coding: utf-8
# frozen-string-literal: true
class Person < ContractingParty
  self.table_name = :persons

  # roles stuff
  resourcify
  rolify role_join_table_name: :persons_roles

  include Filterable

  has_one :address, as: :addressable, dependent: :destroy

  # TODO remove this when decided on how to make the attachments (Document)
  mount_uploader :image, PictureUploader

  # prefixes
  FEMALE = 'F'
  MALE = 'M'
  enum prefix: {
         female: FEMALE,
         male:   MALE
       }
  PREFIXES = [FEMALE, MALE].freeze

  # titles
  DR = 'Dr.'
  PROF = 'Prof.'
  PROF_DR = 'Prof. Dr.'
  enum titles: {
         prof: PROF,
         dr: DR,
         prof_dr: PROF_DR
       }
  TITLES = [DR, PROF, PROF_DR].freeze

  # preferred languages
  GERMAN = 'de'
  ENGLISH = 'en'
  enum preferred_language: {
         german:  GERMAN,
         english: ENGLISH
       }
  PREFERRED_LANGUAGES = [GERMAN, ENGLISH].freeze

  validate :validate_invariants

  def validate_invariants
  end

  scope :restricted, ->(uuids) do
    where(id: uuids)
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

  # permissions helpers

  scope :permitted, ->(uuids) { where(id: uuids) }
end
