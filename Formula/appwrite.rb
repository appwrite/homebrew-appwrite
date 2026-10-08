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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.2.0/appwrite-cli-darwin-arm64"
      sha256 "d3197f9c7c7ca727a07bbf4cd73913433227cb41964af7107e708bc448465597"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.2.0/appwrite-cli-darwin-x64"
      sha256 "ed7f9f7baa5ea1a6adfa8b209eb599976cd99a268509c279465b0aff4a48294b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.2.0/appwrite-cli-linux-arm64"
      sha256 "988480b3c1852bf1daa69b7811e92b984cc4797d9f21e56fb20a8ede1e2f176a"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.2.0/appwrite-cli-linux-x64"
      sha256 "ce2a8ff51fdfd1fd9a213a873bb011a41634d7297338156d08e660db47e7d38e"
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
