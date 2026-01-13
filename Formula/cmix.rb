class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    sources = Dir.glob("src/**/*.cpp").reject do |f|
      f.include?("enwik9-preproc")
    end
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]
    system ENV.cxx, "-std=c++14", "-O3", *sources, "-o", "cmix", *libs
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
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    output = shell_output("#{bin}/cmix", 255)
    assert_match "cmix version", output
  end
end
