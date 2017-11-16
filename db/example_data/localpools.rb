SampleData.localpools = OpenStruct.new(
  people_power: create(:localpool, :people_power,
    owner: SampleData.persons.group_owner,
    admins: [ SampleData.persons.brumbauer],
    distribution_system_operator: Organization.distribution_system_operator.first,
    transmission_system_operator: Organization.transmission_system_operator.first,
    electricity_supplier: Organization.electricity_supplier.first,
    tariffs_attrs: [
      { name: "Hausstrom - Standard" },
      { name: "Hausstrom - Reduziert", energyprice_cents_per_kwh: 24.9 },
    ]
  )
)
