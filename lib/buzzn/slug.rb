class Buzzn::Slug < String

  def initialize(str)
    super(str.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, ''))
  end
end
