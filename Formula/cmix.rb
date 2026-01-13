class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Fix the Makefile so it uses Homebrew's compiler instead of hardcoded g++
    # This makes it work on Mac (Clang) and Linux (G++) automatically
    inreplace "Makefile", "g++", ENV.cxx

    # 2. On Linux, we need to add the standard C++ library to the Makefile
    inreplace "Makefile", "-lpthread", "-lpthread -lstdc++" unless OS.mac?

    # 3. Run the official Make command
    system "make"

    # 4. Create the man page file
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

    # 5. Install the files
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Run version check. We expect exit code 1.
    # We use 'shell_output' to capture the text for the test.
    output = shell_output("#{bin}/cmix", 1)
    assert_match "cmix", output
  end
end
