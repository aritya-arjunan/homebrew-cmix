class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # Maximize CPU features for M-series and Intel
    # -O3 is for maximum speed optimization
    libs = OS.mac? ? "-lpthread" : "-lpthread -lstdc++"
    
    # system ENV.cxx automatically handles M1, M2, M3, M4, M5, and Intel
    system ENV.cxx, "-O3", "cmix.cpp", "-o", "cmix", *libs.split
    
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Verify binary exists and runs
    output = shell_output("#{bin}/cmix", 1)
    assert_match "cmix", output
  end
end
