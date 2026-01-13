class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Gather all source files
    sources = Dir.glob("src/**/*.cpp").reject do |f|
      f.include?("enwik9-preproc") || f.include?("sse.cpp") || f.include?("fxcmv1.cpp")
    end

    # 2. Libraries (Linux needs stdc++)
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]

    # 3. Compile - We rely on the standard compiler provided by the runner
    system ENV.cxx, "-std=c++14", "-O3", *sources, "-o", "cmix", *libs

    # 4. Man Page
    (buildpath/"cmix.1").write <<~EOS
      .TH CMIX 1 "January 2026" "1.9" "Cmix Manual"
      .SH NAME
      cmix \\- World-record-holding compression algorithm
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
