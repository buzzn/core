class Buzzn::Slug < String

  def initialize(str)
    if str
      super(str.downcase.strip.gsub(' ', '-')
             .gsub(/[^a-zA-ZäöüßÄÖÜ-]/, '')
             .gsub(/-+/, '-') # collapse -- to -
             .gsub(/-[a-zA-Z]{0,2}\Z/, '') # no trailing single letter
             .gsub(/-\Z/, '') # no trailing -
           )
    end
  end
end
