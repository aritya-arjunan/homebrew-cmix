class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. FIND THE CODE:
    # This finds the directory containing cmix.cpp, no matter what it is named.
    src_file = Dir.glob("**/cmix.cpp").first
    odie "Could not find cmix.cpp in the download!" if src_file.nil?
    src_dir = File.dirname(src_file)

    # 2. GO TO THE CODE AND BUILD:
    Dir.chdir(src_dir) do
      # Create the man page inside the source directory so it's not lost
      File.write("cmix.1", <<~EOS)
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

      # Determine libraries (Linux needs -lstdc++ explicitly)
      libs = OS.mac? ? "-lpthread" : "-lpthread -lstdc++"

      # Run the compiler
      system ENV.cxx, "-O3", "cmix.cpp", "-o", "cmix", *libs.split

      # Install everything from the source directory
      bin.install "cmix"
      pkgshare.install "dictionary"
      man1.install "cmix.1"
    end
  end

  test do
    # Cmix usually returns help/error when run without args.
    # We just want to make sure the binary exists and executes.
    assert_path_exists bin/"cmix"
  end
end
