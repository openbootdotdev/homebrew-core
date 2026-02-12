class GolangciLint < Formula
  desc "Fast linters runner for Go"
  homepage "https://golangci-lint.run/"
  url "https://github.com/golangci/golangci-lint.git",
      tag:      "v2.8.0",
      revision: "e2e40021c9007020676c93680a36e3ab06c6cd33"
  license "GPL-3.0-only"
  revision 1
  head "https://github.com/golangci/golangci-lint.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "55e1da3625cbe8c833f1251026a00d6859169bf971e5b435a3457a7800072869"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c2b00bb657e95a9f64c9da1ca77c6a521cf2183330ba066f2cad8d1c700531e5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "1834d8f6ad0c4e3f1c0e2e91824b50bd46f16edd005617ebd8b5b3c24b22ad3c"
    sha256 cellar: :any_skip_relocation, sonoma:        "5f991c418194580c9a3de67f3a4cf396f58a4b65dd707da22a06219e96e86ac4"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "8ec59a2b655f267e4d35e8e0487f57daa4481a713289a0cfa85fe642574a34cf"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1620ecdae111482c2d20d57305eccb8682a9db392db4badbdd0dc12509569dd7"
  end

  depends_on "go"

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
      -X main.commit=#{Utils.git_short_head(length: 7)}
      -X main.date=#{time.iso8601}
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/golangci-lint"

    generate_completions_from_executable(bin/"golangci-lint", shell_parameter_format: :cobra)
  end

  test do
    str_version = shell_output("#{bin}/golangci-lint --version")
    assert_match(/golangci-lint has version #{version} built with go(.*) from/, str_version)

    str_help = shell_output("#{bin}/golangci-lint --help")
    str_default = shell_output(bin/"golangci-lint")
    assert_equal str_default, str_help
    assert_match "Usage:", str_help
    assert_match "Available Commands:", str_help

    (testpath/"try.go").write <<~GO
      package try

      func add(nums ...int) (res int) {
        for _, n := range nums {
          res += n
        }
        clear(nums)
        return
      }
    GO

    args = %w[
      --color=never
      --default=none
      --issues-exit-code=0
      --output.text.print-issued-lines=false
      --enable=unused
    ].join(" ")

    ok_test = shell_output("#{bin}/golangci-lint run #{args} #{testpath}/try.go")
    expected_message = "try.go:3:6: func add is unused (unused)"
    assert_match expected_message, ok_test
  end
end
