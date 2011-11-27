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
        while u.read 1024, buffer
          f.write buffer
        end
      end
    end
  rescue Timeout::Error, OpenURI::HTTPError, SystemCallError => x
    raise DownloadError.new x.message
  end
end

