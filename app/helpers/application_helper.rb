module ApplicationHelper
  # Return the watt size in a readable style.
  def human_readable_watt(watt)
    number_to_human( watt,  :precision   => 1,
                            :separator   => ',',
                            :significant => false,
                            :units => {
                              :unit     => "W",
                              :thousand => "kW",
                              :million  => "MW",
                              :billion  => "GW",
                              :trillion => "TW"
                            })
  end

  def link_to_external(link, html_options = {})
    html_options[:target] = "_blank"
    link_to(truncate(link, length: 24, separator: ' '), link, html_options)
  end

  # brutto
  def pre_taxes(value)
    value * 1.19
  end

  # netto
  def after_taxes(value)
    value / 1.19
  end

end
