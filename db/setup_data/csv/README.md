How the data in here gets imported:

### `person.csv`

is the first file to be imported since it has no dependencies to the other files.


### `organizations.csv`

goes next.
- `Organization.buzzn` and `Organization.germany` are set as "global" variables. The energy specifications are created and assigned from seeds in code, nothing to do here.
- When all of the fields `street`, `city`, `zip`, `state` and `country`are filled, and address record is created for the organization. When one field is empty, no address is created, since it can't be saved incomplete.

### `organization_market_functions.csv`

is last.

- the column `organization_id` must exactly match the name of the organization in order to be assigned correctly.
-  the `contact_person_id`  must exactly match the last name of the person to be assigned contact.
