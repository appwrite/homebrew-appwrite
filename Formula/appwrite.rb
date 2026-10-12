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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.4.0/appwrite-cli-darwin-arm64"
      sha256 "82dd9ab27ab5d48d4c4a2d0f4b10c24a1ac9684d978bbd16ccca40fdc10204b2"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.4.0/appwrite-cli-darwin-x64"
      sha256 "dfc128699f6bdf37e725cc746e4b06834faeb8d4cbbcee3d8611d8121b559557"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.4.0/appwrite-cli-linux-arm64"
      sha256 "d559436b44e062098e3c194d56d7e52871c98b8f34ab663d1b9330e09bf5fca4"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.4.0/appwrite-cli-linux-x64"
      sha256 "992b3688a73c394136e59f30570b46f2013e4d0231c0a14c12bbe62e34d6d4dc"
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
