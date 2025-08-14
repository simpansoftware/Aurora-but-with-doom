# Aurora
A tool similar to Ventoy for ChromeOS RMA shims and recovery images based on Alpine Linux<br><br>
![i spend too much time working](https://hackatime-badge.hackclub.com/U085HGVQE9F/Aurora)
# What works? What doesn't?
Recovery :white_check_mark:<br>
Payloads menu :white_check_mark:<br>
Booting other shims :white_check_mark:<br>
Wifi :white_check_mark:<br>
Synaptic :x:<br>

# Building

## Dependencies
### Arch Linux:
```bash
sudo pacman -Sy wget curl gptfdisk rsync binwalk e2fsprogs && yay -S vboot-utils
```
### Debian:
```bash
sudo apt install wget curl bash e2fsprogs gdisk cgpt rsync
```
### Alpine:
```bash
apk add curl wget bash e2fsprogs gptfdisk sgdisk cgpt rsync
```

## Building
```bash
git clone --recursive https://github.com/EtherealWorkshop/Aurora.git
cd Aurora
```
Run the next command with a **raw** shim and the architecture of the chromebook you have.
```bash
sudo bash Aurora /path/to/shim.bin
```
Alternatively, you can automatically download a nanoshim and build with it with the following command (also don't keep the angled brackets in there, if you do even after this warning you're stupid):
```bash
sudo bash Aurora <board> --auto
```
Flash the resulting board-aurora.bin to your flash drive, then plug it into your chromebook to expand the partition.<br><br>
You can then either download recovery images or shims in the shim, or put them on the shim via mounting the 4th partition of the device on another linux machine and copying them into `/usr/share/aurora/images` on the mounted drive.
<br>
If you don't want to build a shim yourself (or aren't able to), prebuilts are available on the [latest release](https://github.com/EtherealWorkshop/Aurora/releases/latest).
# Booting Shims

- Here's a list of shims that are built in to not boot:
  1. Raw shims  -  You don't need to boot a raw shim. The raw shim option in SH1MMER has also been removed when booted in Aurora.
  2. Priism and IRS - Aurora is quite literally a merger of these two.
- Here's a list of shims that we've tested and they work:
  1. SH1MMER (contains cryptosmite, icarus, and br0ker)
  2. Shimboot (:3)
  3. KVS
  4. Aurora (great scott!)
- Here's a list of shims we're gonna make work and test:
  3. Any future shims that are made

# Credits
- [Sophia](https://github.com/soap-phia) - Lead developer of Aurora, Got Wifi
- [Mariah Carey](https://github.com/xXMariahScaryXx) - Bugfixing and bugtesting
- [xmb9](https://github.com/xmb9) - [PRIISM] Made Priism, Giving Aurora the ability to Boot Shims & Use Reco Images
- [Synaptic](https://github.com/Synaptic-1234) - Emotional Support
- [Simon](https://github.com/simpansoftware) - [IRS] Brainstormed how to do wifi, helped with determining wireless interface
- [kraeb](https://github.com/DyingHynixMLC) - [IRS] QoL improvements and initial idea
- [Evie](https://github.com/AC3GT) - Literally nothing
- [kxtz](https://github.com/kxtzownsu) - KVG
