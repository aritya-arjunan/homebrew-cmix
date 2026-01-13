require "find"

class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. LOCATE THE SOURCE FILE
    # We stop guessing folder names. We scan the extracted files for 'cmix.cpp'.
    cpp_file = nil
    Find.find(buildpath) do |path|
      if File.basename(path) == "cmix.cpp"
        cpp_file = path
        break
      end
    end

    # 2. DEBUGGING OUTPUT
    # If the file is somehow missing, this 'ls -R' will print the exact folder structure
    # to the error log so we can see what is happening.
    if cpp_file.nil?
      puts "--- DIRECTORY DUMP ---"
      system "ls", "-R"
      puts "----------------------"
      odie "CRITICAL: cmix.cpp not found. Check directory dump above."
    end

    # 3. COMPILE
    # We point the compiler at the absolute path we just found.
    # We include -lstdc++ for Linux compatibility.
    libs = OS.mac? ? "-lpthread" : "-lpthread -lstdc++"
    system ENV.cxx, "-O3", cpp_file, "-o", "cmix", *libs.split

    # 4. MAN PAGE & INSTALL
    # We write the man page directly to the install location to avoid path errors.
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
    output = shell_output("#{bin}/cmix", 1)
    assert_match "cmix", output
  end
end
