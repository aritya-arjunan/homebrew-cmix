class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Gather all source files
    sources = Dir.glob("src/**/*.cpp")

    # 2. Handle the Intel vs ARM split
    if Hardware::CPU.arm?
      # Exclude the Intel-only files that use <immintrin.h>
      sources.reject! { |f| f.include?("sse.cpp") || f.include?("fxcmv1.cpp") }

      # Create "Stub" definitions that satisfy the unique_ptr and linker
      (buildpath/"arm_stubs.cpp").write <<~EOS
        #include <vector>
        #include <memory>

        // Define dummy classes in the correct namespaces to satisfy unique_ptr
        namespace fxcmv1 { class Predictor {}; }
        namespace SSE_sh { struct SSEi_updstr {}; }

        #include "src/mixer/sse.h"
        #include "src/models/fxcmv1.h"

        // Stub out the SSE methods
        SSE::SSE() {}
        SSE::~SSE() {}
        float SSE::Predict(float f) { return f; }
        void SSE::Perceive(int) {}

        // Stub out the FXCM methods
        // We define the destructor to satisfy the unique_ptr<Predictor>
        FXCM::FXCM() {}
        FXCM::~FXCM() {}
        void FXCM::Predict(int) {}
        void FXCM::Update(int) {}
      EOS
      sources << "arm_stubs.cpp"
    end

    # 3. Always exclude the conflicting enwik9 tool
    sources.reject! { |f| f.include?("enwik9-preproc") }

    # 4. Libraries
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]

    # 5. Compile
    # Added -I. and -DNO_SSE to ensure headers and logic align
    system ENV.cxx, "-std=c++14", "-O3", "-I.", "-DNO_SSE", *sources, "-o", "cmix", *libs

    # 6. Man Page
    (buildpath/"cmix.1").write <<~EOS
      .TH CMIX 1 "January 2026" "1.9" "Cmix Manual"
      .SH NAME
      cmix \\- World-record-holding compression algorithm
      .SH DESCRIPTION
      World-record-holding compression algorithm.#{" "}
      Note: Intel-specific optimizations (SSE/FXCM) are disabled on ARM.
      .SH AUTHOR
      Byron Knoll. Formula by Aritya Arjunan.
    EOS

    # 7. Install
    bin.install "cmix"
    pkgshare.install "dictionary"
    man1.install "cmix.1"
  end

  test do
    output = shell_output("#{bin}/cmix", 255)
    assert_match "cmix version", output
  end
end
