class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Compile the binary
    # We use -lpthread for Mac and add -lstdc++ for Linux
    libs = OS.mac? ? "-lpthread" : "-lpthread -lstdc++"
    system ENV.cxx, "-O3", "cmix.cpp", "-o", "cmix", *libs.split

    # 2. Create the man page file on the fly
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

    # 3. Install everything
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Run version check; redirected to stdout because cmix uses stderr
    output = shell_output("#{bin}/cmix", 1)
    assert_match "cmix", output
  end
end
