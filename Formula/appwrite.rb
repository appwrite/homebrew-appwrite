class Appwrite < Formula
  desc "Command-line tool for interacting with the Appwrite API"
  homepage "https://appwrite.io"
  license "BSD-3-Clause"

  def self.binary_arch
    Hardware::CPU.arm? ? "arm64" : "x64"
  end

  def self.binary_os
    return "darwin" if OS.mac?
    return "linux" if OS.linux?

    raise "Homebrew formula is only supported on macOS and Linux"
  end

  def self.binary_name
    "appwrite-cli-#{binary_os}-#{binary_arch}"
  end

  def self.build_target
    return "mac-#{binary_arch}" if OS.mac?
    return "linux-#{binary_arch}" if OS.linux?

    raise "Homebrew formula is only supported on macOS and Linux"
  end

  head "https://github.com/appwrite/sdk-for-cli.git", branch: "master" do
    depends_on "bun" => :build
  end

  # Release automation injects per-target SHA256 values when publishing binaries.
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.2/appwrite-cli-darwin-arm64"
      sha256 "5b5269fac9dc52ae70fae239eda611ea621e3f8b6d0434bcef4e1254164735ac"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.2/appwrite-cli-darwin-x64"
      sha256 "a8430170022baf5b5f81d97a5c84ef621a8c7d6917b82eb80f458d2e2a368b25"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.2/appwrite-cli-linux-arm64"
      sha256 "a517d6a893cc11edf846e77641e2307161b217c37bf449c86292ec3123c3efc3"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.2/appwrite-cli-linux-x64"
      sha256 "e85d466f557dfd45217ae939a648cf6b4e8e705cd83fb131d48ac3eecd0aafb9"
    end
  end

  def install
    if build.head?
      system "bun", "install", "--frozen-lockfile"
      system "bun", "run", self.class.build_target
      bin.install "build/#{self.class.binary_name}" => "appwrite"
    else
      bin.install self.class.binary_name => "appwrite"
    end

    (bin/"appwrite").chmod 0755

    generate_completions_from_executable(bin/"appwrite", "completion")
  end

  test do
    assert_match "USAGE", shell_output("#{bin}/appwrite --help")
    assert_match "compdef", shell_output("#{bin}/appwrite completion zsh")
  end
end
