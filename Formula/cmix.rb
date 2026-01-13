class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Gather source files
    sources = Dir.glob("src/**/*.cpp").reject { |f| f.include?("enwik9-preproc") }

    # 2. Libraries
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]

    # 3. Compilation - The final touch
    # Add -DNO_SSE for ARM/Linux, or when in doubt
    build_flags = ["-std=c++14", "-O3", "-I."]
    if Hardware::CPU.intel?
      # Build for Intel, with all optimizations enabled
    else
      # For ARM, we add -DNO_SSE to remove the Intel-specific functions
      build_flags << "-DNO_SSE"
    end

    system ENV.cxx, *build_flags, *sources, "-o", "cmix", *libs

    # 4. Man Page
    (buildpath/"cmix.1").write <<~EOS
      .TH CMIX 1 "January 2026" "1.9" "Cmix Manual"
      .SH NAME
      cmix \\- World-record-holding compression algorithm
      .SH DESCRIPTION
      World-record-holding compression algorithm.
      .SH AUTHOR
      Byron Knoll. Formula by Aritya Arjunan.
    EOS

    # 5. Install
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    output = shell_output("#{bin}/cmix", 255)
    assert_match "cmix version", output
  end
end
