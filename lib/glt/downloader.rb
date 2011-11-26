require 'pathname'
require 'open-uri'

class Glt::Downloader
  class DownloadError < StandardError; end

  def initialize(folder)
    @folder = Pathname.new(folder)
  end

  def download_to(url, filename, force = false)
    path = @folder + filename
    if path.exist? && !force
      raise DownloadError.new "File exists (force off)"
    end
    open(url) do |u|
      path.open("wb") do |f|
        buffer = ""
        until (size = u.read buffer, 1024).zero?
          f.write buffer, size
        end
      end
    end
  rescue OpenURI::HTTPError, SystemCallError => x
    raise DownloadError.new x.message
  end
end

