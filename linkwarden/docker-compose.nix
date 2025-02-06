# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."linkwarden-linkwarden" = {
    image = "ghcr.io/linkwarden/linkwarden:latest";
    environmentFiles = [
      "/home/tom/github/docker-compose-config/linkwarden/.env"
    ];
    volumes = [
      "/home/tom/github/docker-compose-config/linkwarden/data:/data/data:rw"
    ];
    ports = [
      "3000:3000/tcp"
    ];
    dependsOn = [
      "linkwarden-postgres"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=linkwarden"
      "--network=linkwarden_default"
    ];
  };
  systemd.services."docker-linkwarden-linkwarden" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-linkwarden_default.service"
    ];
    requires = [
      "docker-network-linkwarden_default.service"
    ];
    partOf = [
      "docker-compose-linkwarden-root.target"
    ];
    wantedBy = [
      "docker-compose-linkwarden-root.target"
    ];
  };
  virtualisation.oci-containers.containers."linkwarden-postgres" = {
    image = "postgres:16-alpine";
    environmentFiles = [
      "/home/tom/github/docker-compose-config/linkwarden/.env"
    ];
    volumes = [
      "/home/tom/github/docker-compose-config/linkwarden/pgdata:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=postgres"
      "--network=linkwarden_default"
    ];
  };
  systemd.services."docker-linkwarden-postgres" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-linkwarden_default.service"
    ];
    requires = [
      "docker-network-linkwarden_default.service"
    ];
    partOf = [
      "docker-compose-linkwarden-root.target"
    ];
    wantedBy = [
      "docker-compose-linkwarden-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-linkwarden_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f linkwarden_default";
    };
    script = ''
      docker network inspect linkwarden_default || docker network create linkwarden_default
    '';
    partOf = [ "docker-compose-linkwarden-root.target" ];
    wantedBy = [ "docker-compose-linkwarden-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-linkwarden-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
