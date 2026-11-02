class Letopis < Formula
  desc "Source-linked project memory for AI coding agents"
  homepage "https://github.com/zdkadiev/letopis"
  license "MIT"

  uses_from_macos "git" => :test

  on_macos do
    on_arm do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.1/letopis-0.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "622bfa94e9c92ffb0ce2df06585908d09e0f9c54d50c62b6ba38b6904285b494"
    end
    on_intel do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.1/letopis-0.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "02add7198ef5bd4aa405aafaf634e71d09c6815aceb4b1a08b38c15a8e37bb34"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.1/letopis-0.1.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "46ac8243c4a3652b3c43439de2a281982d2718026a4450dd5cf31c3cad66add8"
    end
    on_intel do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.1/letopis-0.1.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "66dcf8d16b58cdce51183aba2529804eaf3075593d35309c7d214710f01b6bbb"
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
    assert_equal "letopis 0.1.1\n", shell_output("#{bin}/letopis --version")
  end
end
