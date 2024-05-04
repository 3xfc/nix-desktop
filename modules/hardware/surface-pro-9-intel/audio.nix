{ config, lib, pkgs, ... }: {

  services.pipewire.wireplumber.configPackages = [
    ((pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/99-surface-pro-9-dsp.conf" ''
      node.software-dsp.rules = [
        {
          matches = [
            { "node.name" = "alsa_output.pci-0000_00_1f.3.analog-stereo" }
          ]

          actions = {
            create-filter = {
              filter-graph = {
                node.description = "Surface Pro 9 Speaker"
                filter.graph = {
                  nodes = [
                    {
                      type = "lv2"
                      plugin = "https://chadmed.au/bankstown"
                      name = "bankstown"
                      control = {
                          bypass = 0
                          amt = 1.45
                          sat_second = 1.75
                          sat_third = 2.35
                          blend = 1
                          ceil = 280.0
                          floor = 20.0
                      }
                    }
                    {
                        type = "lv2"
                        plugin = "http://lsp-plug.in/plugins/lv2/loud_comp_mono"
                        name = "ell"
                        control = {
                            enabled = 1
                            input = 1.0
                            fft = 4
                        }
                    }
                    {
                        type = "lv2"
                        plugin = "http://lsp-plug.in/plugins/lv2/loud_comp_mono"
                        name = "elr"
                        control = {
                            enabled = 1
                            input = 1.0
                            fft = 4
                        }
                    }
                    {
                      type = "builtin"
                      name = "convolver_r"
                      label = "convolver"
                      config = {
                        filename = "/etc/surface-audio/sp9/impulse.wav"
                      }
                    }
                    {
                      type = "builtin"
                      name = "convolver_l"
                      label = "convolver"
                      config = {
                        filename = "/etc/surface-audio/sp9/impulse.wav"
                      }
                    }
                    {
                        type = "lv2"
                        plugin = "http://lsp-plug.in/plugins/lv2/compressor_stereo"
                        name = "lim"
                        control = {
                            sla = 5.0
                            al = 1.0
                            at = 1.0
                            rt = 100.0
                            cr = 15.0
                            kn = 0.5
                        }
                    }
                  ]
                  links = [
                    {
                      output = "bankstown:out_l"
                      input = "ell:in"
                    }
                    {
                      output = "bankstown:out_r"
                      input = "elr:in"
                    }
                    {
                      output = "ell:out"
                      input = "convolver_l:In"
                    }
                    {
                      output = "elr:out"
                      input = "convolver_r:In"
                    }
                    {
                      output = "convolver_l:Out"
                      input = "lim:in_l"
                    }
                    {
                      output = "convolver_r:Out"
                      input = "lim:in_r"
                    }
                  ]
                  inputs = [ "bankstown:in_l" "bankstown:in_r" ]
                  outputs = [ "lim:out_l" "lim:out_r" ]
                  capture.volumes = [
                      {
                          control = "ell:volume"
                          min = -40.0
                          max = 0.0
                          scale = "cubic"
                      }
                      {
                          control = "elr:volume"
                          min = -40.0
                          max = 0.0
                          scale = "cubic"
                      }
                  ]
                }
                capture.props = {
                  node.name = "audio_effect.sp9-convolver"
                  media.class = "Audio/Sink"
                  node.virtual = false
                  priority.session = 10000
                  device.api = "dsp"
                  audio.channels = 2
                  audio.position = ["FL", "FR"]
                  state.default-channel-volume = 0.343
                }
                playback.props = {
                  node.name = "effect_output.sp9-convolver"
                  target.object = "alsa_output.pci-0000_00_1f.3.analog-stereo"
                  node.passive = true
                  audio.channels = 2
                  audio.position = ["FL", "FR"]
                }
              }
              hide-parent = "true"
            }
          }
        }
      ]

      wireplumber.profiles = {
        main = {
          node.software-dsp = required
        }
      }
    '').overrideAttrs {
      passthru.requiredLv2Packages = [ pkgs.bankstown-lv2 pkgs.lsp-plugins ];
    })
  ];

  environment.etc."surface-audio/sp9/impulse.wav".source = pkgs.fetchurl {
    url = "https://github.com/peter-marshall5/surface-audio/raw/main/devices/sp9/IR_22ms_17dB_5t_18s_100c.wav";
    hash = "sha256-xj7/G/gTjGYm4bHcvdfVYHkOSHUPHymBZNBjHOKmhkQ=";
  };

}
