# Meter #

is the central model which can be real or a virtual meter. with virtual meter there are two kinds which differs in the type of register they have

* formula register where the readings is calculated from additions and substractions
* substiture register where the whole group of the meter is used to calculate the reading for it.

the Meter::Base is responsible to track the meter changes.

## Real Meter ##

The have the Meter::Edifact one-to-one relation and one or two Register::Real.

## Virtual Meter ##

They do not have the edifact data and have exactly one register, either Register::Substitute or Register::Virtual. Each Meter::FormulaPart associates a Register::Base with the Meter::Virtual.

Meter change on virtual meter happens whenever there is a meter change in any of the associated registers. Only then it is possible to get the readings correct, as a reading on a virtual register depends on all its associated registers.

# Register #

The register itself is actually just the link between the meter and Register::Meta data and carries all the Reading::Simple, i.e. it has no attributes on its own.

All the data for the register is in Register::Meta. This data does not change on meter changes !

## Register::Substitute ##

This substitute registers uses the Kirchoffsche Law which states that in a network node the sum of all current is 0, sum of all consumers is equal the sum of all producers. if we miss one consumer or one producer we can us this substitute register to calculate its energy. note also that in real life the internal grid also consumes power about 10-60W during the day (numbers can be found in the server log for some bubble requests).

## Register::Real ##

On two-way meters the meter needs to be installed correctly (note Discovergy allows to switch the two registers in their database, as wrongly connect two-ways meter are very common). for our datamodel the two registers will be destinguished by their `regsiter.meta.label`, one must be a production label and one must be a consumption label.

for system meters you can use any none production and none consumption label.

## Register::Virtual ##

The readings will be calculated with the `Meter::FormulaPart` from the meter.

# Melo, Malo

Both are outside concept from the energy business and legal regulations. The approach is to keep this (changing) outside concepts also outside of our data model and just use them (in the end they are just IDs associated to some of our objects) where there is real use-case for them.

## MeteringLocation

Each Meter::Base can be associated with a `Meter::MeteringLocation`. on a meter change the new meter needs to be assigned to the same `Meter::MeteringLocation`. at the time of writing only `Uebergabezaehler` do have and do need a metering\_location\_id (metering\_point\_id)

## MarketLocation

The Register::Meta can be associated to a `Register::MarketLocation`. At the time of writing this is not used anywhere and it is not clear whether and how it will be used in the future. That is the reason why actual implemented association might not be correct and fitting for the future use-case. Even implementing such model without use-case is usually waste of time as the first use-case will show exactly how the first implementation needs to look like and experience shows that speculative coding hardly ever meets its future unknown requirements.
