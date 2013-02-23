class SplitterWindow < Wx::SplitterWindow
  def initialize(parent, id)
    super(parent, id, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::SP_LIVE_UPDATE | Wx::NO_BORDER)

    self
  end
end