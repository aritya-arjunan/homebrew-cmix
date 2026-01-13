class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    system "make"
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # NOTE: cmix returns exit code 1 for version check, so we use '1' here
    assert_match "cmix", shell_output("#{bin}/cmix --version", 1)
  end
end
