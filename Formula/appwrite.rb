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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.8.0/appwrite-cli-darwin-arm64"
      sha256 "322a84a9e3ccd089de788df0d609fed8904fe6f9de8b95633af51e8282a0d8b1"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.8.0/appwrite-cli-darwin-x64"
      sha256 "3dbb192b575ccfaaaa0b5c1ae3e6b33ed40d0dc4fc0c41d7276f7881bd200873"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.8.0/appwrite-cli-linux-arm64"
      sha256 "2471c5955b72582a816ce96989cef000f3053cc7adbde3a624950872a6ef15b5"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.8.0/appwrite-cli-linux-x64"
      sha256 "a2e048c515657865a3b9422cb79de2034506cd67b58812f82a1394e2ff8bd651"
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
