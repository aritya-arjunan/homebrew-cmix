class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Gather all source files
    sources = Dir.glob("src/**/*.cpp")

    # 2. RUTHLESS EXCLUSION
    # We remove the enwik9 tool (conflicting main)
    # AND on ARM (Mac M-series / Linux ARM), we remove the Intel-only files
    sources.reject! do |f|
      f.include?("enwik9-preproc") || 
      (Hardware::CPU.arm? && (f.include?("sse.cpp") || f.include?("fxcmv1.cpp")))
    end

    # 3. Libraries
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]

    # 4. Compile
    # We add -D flags to tell the code to stay in 'portable' mode on ARM
    build_flags = ["-std=c++14", "-O3"]
    build_flags << "-DNO_SSE" if Hardware::CPU.arm?

    system ENV.cxx, *build_flags, *sources, "-o", "cmix", *libs

    # 5. Create the Man Page
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

    # 6. Install
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    # Run version check; ignore exit code 255
    output = shell_output("#{bin}/cmix", 255)
    assert_match "cmix version", output
  end
end
