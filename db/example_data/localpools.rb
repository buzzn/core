SampleData.localpools = OpenStruct.new(
  people_power: create(:localpool,
    name: "People Power Group (Testgruppe)",
    description: "Power to the people!",
    owner: SampleData.persons.group_owner,
    admins: [ SampleData.persons.brumbauer],
    distribution_system_operator: Organization.distribution_system_operator.first,
    transmission_system_operator: Organization.transmission_system_operator.first,
    electricity_supplier: Organization.electricity_supplier.first,
    tariffs_attrs: [
      { name: "Hausstrom - Standard" },
      { name: "Hausstrom - Reduziert", energyprice_cents_per_kwh: 24.9 },
    ]
  ),
  green_warriors: create(:localpool, name: "Green warriors (Testgruppe)",
    owner: FactoryGirl.create(:organization, :contracting_party, :with_legal_representation),
    distribution_system_operator: Organization.distribution_system_operator.last,
    transmission_system_operator: Organization.transmission_system_operator.last,
    electricity_supplier: Organization.electricity_supplier.last,
    tariffs_attrs: [
      { name: "Hausstrom - Standard" },
      { name: "Hausstrom - Reduziert", energyprice_cents_per_kwh: 24.9 },
    ]
  )
)
