Buzzn::Logger.root.info 'seeds: loading application setup data'
if Bank.count == 0 && !Import.global?('config.skip_bank_setup')
  file = Dir['db/banks/*'].sort.last
  Buzzn::Logger.root.info "seeds: loading bank data from #{file}"
  Bank.update_from_file(file)
end
