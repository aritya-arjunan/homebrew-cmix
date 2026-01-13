class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # We ignore the Makefile and compile directly using Homebrew's C++ compiler
    # This works on both Intel and Apple Silicon
    system ENV.cxx, "-O3", "cmix.cpp", "-o", "cmix", "-lpthread"
    
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Run cmix without args; it returns 1, so we tell the test to expect 1
    shell_output("#{bin}/cmix", 1)
  end
end
