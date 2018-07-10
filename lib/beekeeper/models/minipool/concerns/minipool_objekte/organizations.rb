require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module Organizations

    extend ActiveSupport::Concern

    private

    ORG_NAME_TO_SLUG_MAP = {
      'Bayernwerk'               => 'bayernwerk-netz',
      'Bayernwerke'              => 'bayernwerk-netz',
      'Bayernwerk AG'            => 'bayernwerk-netz',
      'E.dis AG'                 => 'e-dis',
      'Gemeindewerke Peißenberg' => 'gemeindewerke-peissenberg',
      'LEW'                      => 'lew',
      'NEW Netz'                 => 'new-netz',
      'SWM'                      => 'swm-infrastruktur',
      'Stadtwerke München'       => 'swm-infrastruktur',
      'M-Strom business Garant'  => 'swm-versorgung',
      'M-Ökostrom'               => 'swm-versorgung',
      'Stadtwerke Landshut'      => 'sw-landshut',
      'Stadtwerke Schorndorf'    => 'sw-schorndorf',
      'Stadtwerke Waiblingen'    => 'sw-waiblingen',
      'Syna'                     => 'syna',
      'Syna GmbH'                => 'syna',
      'bnNetze'                  => 'bn-netze',
      'buzzn'                    => 'buzzn',
      'Lichtblick'               => 'lichtblick',
      'SW Netz GmbH'             => 'sw-wiesbaden',
      'Netz Leipzig'             => 'netz-leipzig',
      'BEG Freising'             => 'sw-freising',
      'Hamburg Netz'             => 'stromnetz-hamburg',
      'Vattenfall'               => 'stromnetz-berlin',
      'Stromnetz Berlin'         => 'stromnetz-berlin',
    }

    def distribution_system_operator
      slug = ORG_NAME_TO_SLUG_MAP.fetch(netzbetreiber.strip, 'MISSING')
      org_for_slug(slug, netzbetreiber, :distribution_system_operator)
    end

    def transmission_system_operator
      slug = case uenb
             when /a(m)?prion/i then 'amprion'
             when /tennet/i     then 'tennet'
             when /50 hertz/i   then '50hertz'
             when /Transnet( )?BW/ then 'transnetbw'
             else
          # nothing to do, org_for_slug will print a warning if org not found.
      end
      org_for_slug(slug, uenb, :transmission_system_operator)
    end

    def electricity_supplier
      slug = ORG_NAME_TO_SLUG_MAP.fetch(reststromlieferant.strip, 'MISSING')
      org_for_slug(slug, reststromlieferant, :electricity_supplier)
    end

    def org_for_slug(slug, beekeeper_value, lookup_purpose)
      org = Organization::Base.find_by(slug: slug)
      if !org && !starts_in_future?
        add_warning("#{lookup_purpose} name", "unable to map beekeeper value '#{beekeeper_value}'")
      end
      org
    end

    def starts_in_future?
      start_date > Date.today
    end

  end
end
