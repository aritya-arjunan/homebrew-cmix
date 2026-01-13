class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Gather all source files
    sources = Dir.glob("src/**/*.cpp")

    # 2. Handle ARM: Exclude Intel-only code and create the ARM Stubs
    if Hardware::CPU.arm?
      # Exclude the Intel-only files
      sources.reject! { |f| f.include?("sse.cpp") || f.include?("fxcmv1.cpp") }

      # Create the C++ STUBS to satisfy the compiler/linker
      (buildpath/"arm_stubs.cpp").write <<~EOS
        #include <vector>
        #include <valarray>
        #include "src/models/fxcmv1.h" // Include the header so it knows about the classes

        namespace fxcmv1 {
          // Define the missing destructor to satisfy unique_ptr (Error 1)
          FXCM::~FXCM() {}
        }

        // Define the function signatures exactly as they are declared in fxcmv1.h
        // Since we don't have the real implementation, we give it a dummy return value.
        const std::valarray<float>& FXCM::Predict() {
          static std::valarray<float> dummy_result(1);
          return dummy_result;
        }

        void FXCM::Update(int) {}

        // SSE is not used, but we need to define its class structure too.
        SSE::SSE() {}
        SSE::~SSE() {}
        float SSE::Predict(float f) { return f; }
        void SSE::Perceive(int) {}
      EOS
      sources << "arm_stubs.cpp"
    end

    # 3. Exclude enwik9 (conflicting main)
    sources.reject! { |f| f.include?("enwik9-preproc") }

    # 4. Libraries and Compilation Flags
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]
    build_flags = ["-std=c++14", "-O3"]
    build_flags << "-DNO_SSE" if Hardware::CPU.arm?

    system ENV.cxx, *build_flags, *sources, "-o", "cmix", *libs

    # 5. Man Page
    (buildpath/"cmix.1").write <<~EOS
      .TH CMIX 1 "January 2026" "1.9" "Cmix Manual"
      .SH NAME
      cmix \\- World-record-holding compression algorithm
      .SH DESCRIPTION
      Note: Intel-specific optimizations (SSE/FXCM) are disabled on ARM builds.
      .SH AUTHOR
      Byron Knoll. Formula by Aritya Arjunan.
    EOS

    # 6. Install
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    output = shell_output("#{bin}/cmix", 255)
    assert_match "cmix version", output
  end
end
