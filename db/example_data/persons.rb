def person(attributes)
  create(:person, :with_bank_account, :with_self_role, :with_account, attributes)
end

SampleData.persons = OpenStruct.new(
  operator:    Person.find_by_email('dev+ops@buzzn.net'),
  group_owner: person(first_name: 'Wolfgang', last_name: 'Owner', title: 'Dr.', email: 'dev+owner@buzzn.net'),
  group_admin:   person(first_name: 'Adrian', last_name: 'Admin', prefix: 'F', email: 'dev+mgr@buzzn.net',
                      roles: { Role::ORGANIZATION => Organization.find_by(slug: 'people-power-group-testgruppe') }
                       ),
  pt1:  person(first_name: 'Sabine', last_name: 'Powertaker1', title: 'Prof.', prefix: 'F', email: 'dev+pt1@buzzn.net'),
  pt2:  person(first_name: 'Carla', last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F', email: 'dev+pt2@buzzn.net'),
  pt3:  person(first_name: 'Maria', last_name: 'Mentor', prefix: 'F', email: 'dev+pt3@buzzn.net'),
  pt4:  person(first_name: 'Karl', last_name: 'Powertaker4', email: 'dev+pt4@buzzn.net'),
  pt5a: person(first_name: 'Sylvia', last_name: 'Powertaker5a (zieht aus)', prefix: 'F', email: 'dev+pt5a@buzzn.net'),
  pt5b: person(first_name: 'Fritz', last_name: 'Powertaker5b (zieht ein)', email: 'dev+pt5b@buzzn.net'),
  pt6:  person(first_name: 'Horst', last_name: 'Powertaker6 (drittbeliefert)', email: 'dev+pt6@buzzn.net'),
  pt7:  person(first_name: 'Anna', last_name: 'Powertaker7 (Wechsel zu uns)', prefix: 'F', email: 'dev+pt7@buzzn.net'),
  pt8:  person(first_name: 'Sam',  last_name: 'Powertaker8', preferred_language: 'english', email: 'dev+pt8@buzzn.net'),
  pt9:  person(first_name: 'Justine', last_name: 'Powertaker9', prefix: 'F', email: 'dev+pt9@buzzn.net'),
  pt10: person(first_name: 'Mohammed', last_name: 'Powertaker10', email: 'dev+pt10@buzzn.net')
)
