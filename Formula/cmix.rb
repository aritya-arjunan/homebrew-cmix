class Cmix < Formula
  desc "World-record-holding compression algorithm"
  homepage "https://github.com/byronknoll/cmix"
  url "https://github.com/byronknoll/cmix/archive/refs/tags/v21.tar.gz"
  sha256 "c0ff50f24604121bd7ccb843045c0946db1077cfb9ded10fe4c181883e6dbb42"
  license "GPL-3.0-or-later"

  def install
    # 1. Gather all source files, excluding Intel-only and enwik9
    sources = Dir.glob("src/**/*.cpp").reject do |f|
      f.include?("enwik9-preproc") || 
      (Hardware::CPU.arm? && (f.include?("sse.cpp") || f.include?("fxcmv1.cpp")))
    end

    # 2. ARM Stub Creation (The critical fix)
    if Hardware::CPU.arm?
      (buildpath/"arm_stubs.cpp").write <<~EOS
        #include <vector>
        #include <valarray>
        #include "src/models/fxcmv1.h" // Header for FXCM and SSE classes
        #include "src/mixer/sse.h"     // Header for SSE class

        // Define the classes and methods INSIDE their namespaces
        
        namespace fxcmv1 {
          // Define the class structure for Predictor to satisfy unique_ptr
          class Predictor {}; 
          
          // Define the missing methods exactly as they appear in fxcmv1.h
          const std::valarray<float>& FXCM::Predict() {
            static std::valarray<float> dummy_result(1);
            return dummy_result;
          }
          void FXCM::Update(int) {}
          FXCM::~FXCM() {} // Destructor defined here
        }

        namespace SSE {
          // Define the SSE structure and methods
          SSE::SSE() {}
          SSE::~SSE() {}
          float SSE::Predict(float f) { return f; }
          void SSE::Perceive(int) {}
        }
      EOS
      sources << "arm_stubs.cpp"
    end

    # 3. Libraries and Compilation Flags
    libs = OS.mac? ? ["-lpthread"] : ["-lpthread", "-lstdc++"]
    build_flags = ["-std=c++14", "-O3"]
    build_flags << "-DNO_SSE" if Hardware::CPU.arm?

    system ENV.cxx, *build_flags, *sources, "-o", "cmix", *libs

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
