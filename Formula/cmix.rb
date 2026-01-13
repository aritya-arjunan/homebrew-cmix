class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Prepare the compilation arguments
    # We add -lstdc++ for Linux and -lpthread for everyone
    args = ["-O3", "#{buildpath}/cmix.cpp", "-o", "cmix", "-lpthread"]
    args << "-lstdc++" unless OS.mac?

    # 2. Compile directly (This bypasses the need for a Makefile)
    system ENV.cxx, *args

    # 3. Create the man page on the fly
    (buildpath/"cmix.1").write <<~EOS
      .TH CMIX 1 "January 2026" "1.9" "Cmix Manual"
      .SH NAME
      cmix \\- World-record-holding compression algorithm
      .SH SYNOPSIS
      .B cmix
      [\\fI-options\\fR] \\fIinput\\fR \\fIoutput\\fR
      .SH DESCRIPTION
      .B cmix
      is an ultra-high-pressure compression tool using context mixing.
      .SH AUTHOR
      Byron Knoll. Formula by Aritya Arjunan.
    EOS

    # 4. Install binary, dictionary, and man page
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Run version check. Expect exit code 1.
    output = shell_output("#{bin}/cmix", 1)
    assert_match "cmix", output
  end
end
