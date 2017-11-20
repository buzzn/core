class Buzzn::Slug < String

  def initialize(str)
    if str
    super(str.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, ''))
end
  end
end
