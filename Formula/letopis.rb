class Letopis < Formula
  desc "Source-linked project memory for AI coding agents"
  homepage "https://github.com/zdkadiev/letopis"
  license "MIT"

  uses_from_macos "git" => :test

  on_macos do
    on_arm do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.2.0/letopis-0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "16d3edaa3f721a37db8d11d84567712aeea4afeebb1bf8663f003f4f6074795d"
    end
    on_intel do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.2.0/letopis-0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "9a3f254ed3b13ef683730edf33b1f2ecd2522b6f0358f8bc6eb30e01f9984d07"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.2.0/letopis-0.2.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "bc21369ce337451452c491b4ca3a85b91e2c837e606f94544141eaebcc2f37cc"
    end
    on_intel do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.2.0/letopis-0.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "daf6782538ed402876a5793c76a4768d2bb5993f2c056813cd0e2bcef3766740"
    end
  end

  def install
    bin.install "letopis"
    pkgshare.install "LICENSE", "THIRD_PARTY_NOTICES.txt", "BUILD.json"
  end

  test do
    # Given: a temporary Git worktree with one marked concept.
    system "git", "init", "--quiet"
    (testpath/"knowledge.md").write <<~MARKDOWN
      <!-- letopis: {"created_at":1793491200} -->
      # Retry budget
      Keep retries bounded.
    MARKDOWN
    # When: the installed executable initializes, validates and searches knowledge.
    initialized = JSON.parse(pipe_output("#{bin}/letopis init", "{}\n", 0))
    checked = JSON.parse(pipe_output("#{bin}/letopis check", "{}\n", 0))
    searched = JSON.parse(pipe_output("#{bin}/letopis search", '{"query":"retry","limit":10}', 0))
    # Then: it reports success and finds the authored concept.
    assert_equal true, initialized["ok"]
    assert_equal true, checked["ok"]
    assert_empty checked.fetch("result").fetch("errors")
    assert_equal true, searched["ok"]
    assert_equal ["knowledge.md"], searched.fetch("result").map { |link| link.fetch("element_id") }
    assert_equal "letopis 0.2.0\n", shell_output("#{bin}/letopis --version")
  end
end
