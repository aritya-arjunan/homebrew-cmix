class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Gather all source files from the 'src' directory
    # We use Dir.glob to find every .cpp file in all subfolders
    sources = Dir.glob("src/**/*.cpp")

    # 2. Determine libraries
    # Linux needs stdc++ for the neural network math
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]

    # 3. Manual Compile
    # -std=c++14 is required for cmix's code
    # -O3 is for maximum compression speed
    system ENV.cxx, "-std=c++14", "-O3", *sources, "-o", "cmix", *libs

    # 4. Create the Manual Page
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

    # 5. Install everything
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Run version check; it returns 1, so we tell the test to expect 1
    output = shell_output("#{bin}/cmix", 1)
    assert_match "cmix", output
  end
end
