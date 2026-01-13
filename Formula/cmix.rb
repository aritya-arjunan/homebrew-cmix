class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/heads/master.tar.gz"
  version "1.9"
  sha256 "0f443b81182276c968923a1a361e27a6d8197779979704e67f7e9f3b6038d728"

  def install
    # Compile the binary
    system "make"
    
    # Install binary
    bin.install "cmix"
    
    # Install dictionary (required for cmix to run)
    pkgshare.install "dictionary"
    
    # Install the manual page!
    man1.install "cmix.1"
    
    # Install README for documentation
    doc.install "README.md"
  end

  test do
    # Simple test to make sure it doesn't crash
    assert_match "cmix", shell_output("#{bin}/cmix --version", 1)
  end
end
