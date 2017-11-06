def person(attributes)
  create(:person, :with_bank_account, :with_self_role, :with_account, attributes)
end

SampleData.persons = OpenStruct.new(
  operator:    person(first_name: 'Philipp', last_name: 'Operator', roles: { Role::BUZZN_OPERATOR => nil }),
  group_owner: person(:wolfgang),
  brumbauer:   person(first_name: 'Traudl', last_name: 'Brumbauer', prefix: 'F',
                      roles: { Role::ORGANIZATION => Organization.find_by(slug: 'hell-warm') }
  ),
  pt1:  person(first_name: 'Sabine', last_name: 'Powertaker1', title: 'Prof.', prefix: 'F'),
  pt2:  person(first_name: 'Carla', last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F'),
  pt3:  person(first_name: 'Bernd', last_name: 'Powertaker3'),
  pt4:  person(first_name: 'Karl', last_name: 'Powertaker4'),
  pt5a: person(first_name: 'Sylvia', last_name: 'Powertaker5a (zieht aus)', prefix: 'F'),
  pt5b: person(first_name: 'Fritz', last_name: 'Powertaker5b (zieht ein)'),
  pt6:  person(first_name: 'Horst', last_name: 'Powertaker6 (drittbeliefert)'),
  pt7:  person(first_name: 'Anna', last_name: 'Powertaker7 (Wechsel zu uns)', prefix: 'F'),
  pt8:  person(first_name: 'Sam',  last_name: 'Powertaker8', preferred_language: 'english'),
  pt9:  person(first_name: 'Justine', last_name: 'Powertaker9', prefix: 'F'),
  pt10: person(first_name: 'Mohammed', last_name: 'Powertaker10')
)
