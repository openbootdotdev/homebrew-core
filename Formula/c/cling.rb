class Cling < Formula
  desc "C++ interpreter"
  homepage "https://root.cern/cling/"
  url "https://github.com/root-project/cling/archive/refs/tags/v1.3.tar.gz"
  sha256 "ca81f3bc952338beffba178633d77f5b3e1f1f180cbe2bb9f2713c06f410fd18"
  license all_of: [
    { any_of: ["LGPL-2.1-only", "NCSA"] },
    { "Apache-2.0" => { with: "LLVM-exception" } }, # llvm
  ]

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 arm64_tahoe:   "b09e0249110083ea166e4abddcd0fd0b1baae544cbb27c2b980d7df0473a15fe"
    sha256 arm64_sequoia: "4c56a4179592ca8b3aa5ef8c172edfc46356382454fc56872c7cdac015614ad2"
    sha256 arm64_sonoma:  "aaa711f705fd0e99b0c8a9ef9e831243b8fffdf8ec847952713ed806dd70d45d"
    sha256 sonoma:        "b45e65c4c0a399f23eb9cdae58f502aa3f66ec6be01d4bfd72347551ecc1b9ef"
    sha256 arm64_linux:   "1280cc977c508d088cca5ebf924a9777cffa894834295ee18beba4b58485e21c"
    sha256 x86_64_linux:  "8664aa806ec0740a3fa1b79d8c7773941b301485e61d0b4d5483470fedf7961c"
  end

  depends_on "cmake" => :build
  depends_on "zstd"

  uses_from_macos "python" => :build
  uses_from_macos "libedit"
  uses_from_macos "libxml2"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  # https://github.com/root-project/cling?tab=readme-ov-file#building-from-source
  # `git ls-remote --heads https://github.com/root-project/llvm-project.git cling-latest`
  # grab the latest tag https://github.com/root-project/llvm-project/commit/<commit>
  resource "llvm" do
    url "https://github.com/root-project/llvm-project/archive/refs/tags/cling-llvm20-20260119-01.tar.gz"
    sha256 "6d023a311393eee6025bf3b1e6bb9caa9b31ec2f288f9bee1a2fbe71072b2849"
  end

  def install
    # Skip modification of CLING_OSX_SYSROOT to the unversioned SDK path
    # Related: https://github.com/Homebrew/homebrew-core/issues/135714
    # Related: https://github.com/root-project/cling/issues/457
    inreplace "lib/Interpreter/CMakeLists.txt", '"MacOSX[.0-9]+\.sdk"', '"SKIP"'

    (buildpath/"llvm").install resource("llvm")

    system "cmake", "-S", "llvm/llvm", "-B", "build",
                    "-DCLING_CXX_PATH=clang++",
                    "-DLLVM_BUILD_TOOLS=OFF",
                    "-DLLVM_ENABLE_PROJECTS=clang",
                    "-DLLVM_EXTERNAL_CLING_SOURCE_DIR=#{buildpath}",
                    "-DLLVM_EXTERNAL_PROJECTS=cling",
                    "-DLLVM_TARGETS_TO_BUILD=host;NVPTX",
                    *std_cmake_args(install_prefix: libexec)
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # We use an exec script as a symlink causes issues finding headers
    bin.write_exec_script libexec/"bin/cling"
  end

  test do
    test = <<~EOS
      '#include <stdio.h>' 'printf("Hello!")'
    EOS
    assert_equal "Hello!(int) 6", shell_output("#{bin}/cling #{test}").chomp
  end
end
