SampleData.localpools = OpenStruct.new(
  people_power: create(:group, :localpool, :with_address,
    name: 'People Power Group (Testgruppe)',
    slug: 'people-power-group-testgruppe', # hard-code the slug because we share the link publicly, it shouldn't change
    description: 'Power to the people!',
    show_display_app: true,
    owner: SampleData.persons.group_owner,
    admins: [SampleData.persons.group_admin],
    distribution_system_operator: Organization::Market.distribution_system_operators.first,
    transmission_system_operator: Organization::Market.transmission_system_operators.first,
    electricity_supplier: Organization::Market.electricity_suppliers.first,
    tariffs_attrs: [
      { name: 'Hausstrom - Standard' },
      { name: 'Hausstrom - Reduziert', energyprice_cents_per_kwh: 24.9 },
    ],
    gap_contract_customer_organization: Organization::General.find_by(slug: 'hv-schneider')
                      ),
  green_warriors: create(:group, :localpool, :with_address,
    name: 'Green warriors (Testgruppe)',
    show_display_app: true,
    owner: FactoryGirl.create(:organization, :with_legal_representation),
    distribution_system_operator: Organization::Market.distribution_system_operators.last,
    transmission_system_operator: Organization::Market.transmission_system_operators.last,
    electricity_supplier: Organization::Market.electricity_suppliers.last,
    tariffs_attrs: [
      { name: 'Hausstrom - Standard' },
      { name: 'Hausstrom - Reduziert', energyprice_cents_per_kwh: 24.9 },
    ],
    gap_contract_customer_organization: Organization::General.find_by(slug: 'hv-schneider')
                        )
)
