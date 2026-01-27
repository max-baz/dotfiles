{
  programs.ssh = {
    ciphers = [
      "chacha20-poly1305@openssh.com"
      "aes256-gcm@openssh.com"
      "aes128-gcm@openssh.com"
      "aes256-ctr"
      "aes192-ctr"
      "aes128-ctr"
    ];
    kexAlgorithms = [
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group-exchange-sha256"
    ];
    macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
      "hmac-sha2-512"
      "hmac-sha2-256"
      "umac-128@openssh.com"
    ];
    hostKeyAlgorithms = [
      "ssh-ed25519-cert-v01@openssh.com"
      "ssh-rsa-cert-v01@openssh.com"
      "ssh-ed25519"
      "rsa-sha2-512"
      "ssh-rsa"
    ];
    pubkeyAcceptedKeyTypes = [
      "sk-ssh-ed25519@openssh.com"
      "ssh-ed25519-cert-v01@openssh.com"
      "ssh-rsa-cert-v01@openssh.com"
      "ssh-ed25519"
      "rsa-sha2-512"
      "ssh-rsa"
    ];
    extraConfig = ''
      Host *
        ChallengeResponseAuthentication no
        ServerAliveInterval 60
        Compression yes
        ControlMaster auto
        ControlPath ~/.ssh/ssh-%r@%n:%p
        ControlPersist 60m
        StrictHostKeyChecking accept-new
        ExitOnForwardFailure yes
        IdentitiesOnly yes
        User root
    '';
  };
}
