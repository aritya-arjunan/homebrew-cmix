class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Filter out the auxiliary tools that have conflicting 'main' functions
    sources = Dir.glob("src/**/*.cpp").reject do |f|
      f.include?("enwik9-preproc")
    end

    # 2. Libraries
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]

    # 3. Compile
    system ENV.cxx, "-std=c++14", "-O3", *sources, "-o", "cmix", *libs

    # 4. Man Page
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

    # 5. Install
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # We run the command and ignore the exit code (since it varies)
    # We just check if the output contains the version info
    output = shell_output("#{bin}/cmix", 255)
    assert_match "cmix version", output
  end
end
