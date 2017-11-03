SampleData.localpools = OpenStruct.new(
  people_power: create(:localpool, :people_power, owner: SampleData.persons.group_owner,
    admins: [ SampleData.persons.brumbauer] ,
    # FIXME: to be renamed to group_tariff
    prices_attrs: [
      { name: "Hausstrom - Standard" },
      { name: "Hausstrom - Reduziert", energyprice_cents_per_kilowatt_hour: 24.9 },
    ]
  )
)
