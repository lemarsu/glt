module Glt::Version
  def self.to_s
    @to_s ||= File.read(File.expand_path('../../../VERSION', __FILE__)).freeze
  end

  def self.to_a
    @to_s ||= to_s.split('.').freeze
  end

  def self.major
    to_a.first
  end

  def self.minor
    to_a[1]
  end

  def self.patch
    to_a[2]
  end
end
