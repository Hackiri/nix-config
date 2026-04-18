# PipeWire audio with ALSA and PulseAudio compatibility
{username, ...}: {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.${username}.extraGroups = ["audio" "video"];
}
