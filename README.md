# niri-vertical-center-alignment

![demo](https://raw.githubusercontent.com/Kazi-Aidah/niri-vertical-center-alignment/main/demo-niri-vertical-center-alignment.mp4)

In niri, by default, when decreasing the height of a Window, the Window stays top-aligned. This patch + installer tells niri to center windows only in columns that contain a single window.

This *does not* turn Windows into floating ones, it affects only single windows in columns. 

Upstream niri (as of 26.04) has no such option.
- [Option to auto-center fixed height windows (#175)](https://github.com/niri-wm/niri/discussions/175)
  — the maintainer agreed it makes sense!
- [Ability to vertically center non-full sized windows (#2874)](https://github.com/niri-wm/niri/discussions/2874)


## Usage

Run:
```sh
git clone https://github.com/Kazi-Aidah/niri-vertical-center-alignment
cd niri-vertical-center-alignment
./install.sh --enable-config
```

Skip the 15-minute build: grab the prebuilt binary from the [v26.04-centered release](https://github.com/Kazi-Aidah/niri-vertical-center-alignment/releases/tag/v26.04-centered) instead.

Then **log out and back in** (no reboot needed).

New config option:
```kdl
layout {
    center-single-window-vertically
}
```


## After system updates

An Arch `niri` package update overwrites `/usr/sbin/niri`. Just re-run
`./install.sh` (it re-applies the patch, rebuilds, reinstalls; the stock backup at `/usr/sbin/niri.stock` is kept.)


## Revert

```sh
sudo cp /usr/sbin/niri.stock /usr/sbin/niri
```
then remove the `center-single-window-vertically` line from your config.