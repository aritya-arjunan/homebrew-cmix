class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. THE NO-INREPLACE STRATEGY
    # We pass the variables directly to the 'make' command. 
    # This overrides whatever is written in the makefile.
    
    # We define the libraries: Mac just needs pthread, Linux needs stdc++
    libs = OS.mac? ? "-lpthread" : "-lpthread -lstdc++"

    # We run make and tell it exactly which compiler and libraries to use
    system "make", "CXX=#{ENV.cxx}", "LDFLAGS=#{libs}"

    # 2. CREATE MAN PAGE
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

    # 3. INSTALL
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Simply check if the binary can be found and run
    output = shell_output("#{bin}/cmix", 1)
    assert_match "cmix", output
  end
end
