duplicates = %w(Ralf.schroeder@gmail.com
Vertragsmanagement@rng.de
a.bock@ich-hab-bock.de
a.heinrich@weissflogheinrich.de
a.miethe@stwwn.de
al@leonhardarchitekten.de
ansprechpartner-datenaustausch@sw-netz.de
bad_sulz@kabelmail.de
bauwesen@hallbergmoos.de
buero@wagnis.org
datenaustausch.vertrieb@swm.de
edm.bnnetze@energiexchange.de
eduard.tiede@stadtwerke-schorndorf.de
erdlekh@erdlekh.de
info@BEG-FS.de
info@christoph-eiser.de
j.fellner@stadtwerke-landshut.de
jan.bohne@lsw.de
joachim.bobert@new-netz-gmbh.de
lieferant@stw-freising.de
lieferantenwechsel@enercity-netz.de
m.schabl@isarwatt.de
mail@hgschreck.de
mar_s1@gmx.de
marktpartner@stromnetz-hamburg.de
mattauch@beg-remstal.de
netzbilanzierung@netz-leipzig.de
netzkunden@stromnetz-berlin.de
netznutzung-hb@wesernetz.de
netznutzung@e-dis.de
netznutzung@lew-verteilnetz.de
netznutzung@peissenberg.de
netznutzungsmanagement@syna.de
netzvertraege@bayernwerk.de
olaf.nimz@stadtwerke-kaltenkirchen.de
re@discovergy.com
sdammann@stadtwerke-einbeck.de
ssge@telta.de
stefan.maeder@stadtwerke-witzenhausen.de
t.brumbauer@wogeno.de
team@thies-hahn.de
tim.warnke@gmx.de
ulrich.haushofer@gmx.de
unknown@unknown.de
versorgerwechsel@lichtblick.de
vertragsmanagement@avacon.de
vertragsmanagement@mitnetz-strom.de
w.heller@stadtwerke-wedel.de)

# ---------------

require 'smarter_csv'

module Converters
  class PreferredLanguage
    def self.convert(value)
      { 'DE' => :german, 'EN' => :english }[value]
    end
  end
  class State
    def self.convert(value)
      "DE_#{value}"
    end
  end
end

def get_csv(model_name, options = {})
  file_name = "db/setup_data/csv/#{model_name}.csv"
  SmarterCSV.process(file_name,
    col_sep: ",",
    convert_values_to_numeric: false,
    value_converters: options[:converters]
  )
end

orgs = get_csv(:organizations, converters: { state: Converters::State })
seed_orgs = orgs.map { |hash| hash[:email] }.uniq

(duplicates - seed_orgs).sort.each { |email| puts "  - [ ] #{email}" }
