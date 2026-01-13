class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Patch the compiler
    # This changes 'g++' to the Homebrew compiler (clang++ or g++-12)
    inreplace "makefile", "g++", ENV.cxx

    # 2. Patch the libraries for Linux (SAFELY)
    if OS.linux?
      # This Regex finds the LDFLAGS line and appends -lstdc++ to it.
      # It won't crash if '-lpthread' is missing or named differently.
      inreplace "makefile", /LDFLAGS\s*=.*/, "\\0 -lstdc++"
    end

    # 3. Build the project
    system "make"

    # 4. Generate the Manual Page
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

    # 5. Install the binary, dictionary, and man page
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Verify the binary exists and can run
    output = shell_output("#{bin}/cmix", 1)
    assert_match "cmix", output
  end
end
