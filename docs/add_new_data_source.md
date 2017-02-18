# new DataSource

let the name of the data-source be **smart**

## implement data-source interface

the interface is **lib/buzzn/data_source.rb** and the **smart** implementation goes into **lib/buzzn/smart/data_source.rb** with

```
module Buzzn::Smart

  class DataSource < Buzzn::DataSource

    NAME = :smart

    def collection(resource, mode)
      nil
    end

    def single_aggregated(resource, mode)
      nil
    end

    def aggregated(resource, mode, interval)
      nil
    end
end
```
this is already a fully functional data-source and can be plugged in.

## setup the default in data-source registry

just add in the initializer of **lib/buzzn/data_source_registry.rb**

```
@registry[Buzzn::Smart::DataSource::NAME] ||= Buzzn::Smart::DataSource.new
```
if the smart-datasource needs more initialize parameters they needs to pass into the contractor of the registry, i.e. the parameter list needs to be extended.

## make the register class if the data-source type

the register model has a method `data_source` which needs to return the data-source `NAME` for its registers. see `app/models/registers/base.rb`. the register does know how to recognize its data-source. i.e. discovergy has an associated DiscovergyBroker which carries extra data for the register which are specific to discovergy. dito MySmartGrid. this associated reference is used to identify the data-source. StandardProfile data-source is the default (as it has not extra info).
