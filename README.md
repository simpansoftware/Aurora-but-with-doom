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
```bash
git clone https://github.com/EtherealWorkshop/Aurora.git
cd Aurora
```
Run the next command with a **raw** shim and the architecture of the chromebook you have.
```bash
sudo bash Aurora /path/to/shim.bin [cpu_architecture(x86_64 or aarch64)]
```
Flash the resulting board-aurora.bin to your flash drive, then plug it into your chromebook to expand the partition.<br><br>
You can then either download recovery images or shims in the shim, or put them on the shim via mounting the 4th partition of the device on another linux machine and copying them into `/usr/share/aurora/images` on the mounted drive.

# Booting Shims

- Here's a list of shims that are built in to not boot:
  1. Raw shims  -  You don't need to boot a raw shim. The raw shim option in SH1MMER has also been removed when booted in Aurora.
  2. Priism and IRS - Aurora is quite literally a merger of these two.
- Here's a list of shims that we've tested and they work:
  1. SH1MMER (contains cryptosmite and icarus)
  2. Shimboot (:3)
  3. KVS
  4. Aurora (great scott!)
- Here's a list of shims we're gonna make work and test:
  3. Any future shims that are made

# WSL (Windows Subsystem for Linux)
Aurora was made entirely on WSL. Building will not be an issue.<br>
Here's how to access the Aurora USB inside of WSL, though.
In powershell, run
```bash
winget install --interactive --exact dorssel.usbipd-win
```
Close Powershell, and reopen it as administrator (reopen it no matter what)
```bash
usbipd list
```
You should see your USB (Likely Mass Storage Device or something similar). Note the busid.
```bash
usbipd bind --busid <busid>
```
```bash
usbipd attach --wsl --busid <busid>
```
And check WSL.<br>
It is always preferred to use an actual linux machine, though.

# FAQ (Frequently Asked Questions)
<br><b>I wanna use Shimboot. How can I?</b>

Coming soon to viewers like you!<br><br>
<b>Does Aurora work on Chomp?</b>

  Priism 2.0 (A lot of what Aurora was based off of) was developed entirely on Chomp!
> [!WARNING]
> Aurora, Priism, and IRS are all made for recovering and booting shims. They serve no purpose on a non-ChromeOS Machine ~~yet~~

# Credits
- [Sophia](https://github.com/soap-phia) - Lead developer of Aurora, Got Wifi
- [Mariah Carey](https://github.com/xXMariahScaryXx) - Bugfixing and bugtesting
- [xmb9](https://github.com/xmb9) - [PRIISM] Made Priism, Giving Aurora the ability to Boot Shims & Use Reco Images
- [Synaptic](https://github.com/Synaptic-1234) - Emotional Support
- [Simon](https://github.com/simpansoftware) - [IRS] Brainstormed how to do wifi, helped with determining wireless interface
- [kraeb](https://github.com/DyingHynixMLC) - [IRS] QoL improvements and initial idea
- [Evie](https://github.com/AC3GT) - Literally nothing
- [Rainestorme](https://github.com/rainestorme) - Murkmod's version finder
- [kxtz](https://github.com/kxtzownsu) - KVG
