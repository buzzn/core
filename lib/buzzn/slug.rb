class Buzzn::Slug < String

  def initialize(str, count = nil)
    if str
      slug = str.downcase.strip.gsub(' ', '-')
                .gsub(/[^a-zA-ZäöüßÄÖÜ-]/, '')
                .gsub(/-+/, '-') # collapse -- to -
                .gsub(/-[a-zA-Z]{0,2}\Z/, '') # no trailing single letter
                .gsub(/-\Z/, '') # no trailing -
                .gsub('ä', 'ae')
                .gsub('ö', 'oe')
                .gsub('ü', 'ue')
                .gsub('ß', 'ss')
                .gsub('Ä', 'AE')
                .gsub('Ö', 'OE')
                .gsub('Ü', 'UE')
      if count
        slug += "_#{count}"
      end
      super(slug)
    end
  end

end
