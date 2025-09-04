## New board?
#### 1. Update the kernels to the latest:
```
sudo apt update

sudo apt install linux-headers-5.10.238-vaaman linux-image-5.10.238-vaaman linux-libc-dev
```
*5.10.238 is the latest currently; yours might be newer.*

#### 2. Enable SPI in your board:
```
sudo vicharak-config
```
Go to 'Overlays > Manage Overlayes' and check the SPI option to turn it on. It should look like this:
```
[*] Enable SPI 2 dev on 40-Pin GPIO Header 
```
Then **reboot** the board.

#### 3. Let us start Rah:
```
sudo apt install rah-service 
```
Check if it is active or not:
```
systemctl status rah.service
```
If it is not active, 
```
systemctl start rah.service
```
Check the version, and verify with the Gati team which version is stable and working currently
```
sudo apt show rah-service
```
Sometimes, you may encounter issues with the firmware of RAH's bridge. To check if it's not the case, run
```
dmesg | grep vop
```
It should show
```
vicharak@mantra:~$ dmesg | grep vop
[    7.776460] rockchip_clk_register_frac_branch: could not find dclk_vop0_frac as parent of dclk_vop0, rate changes may not work
[    7.783677] rockchip_clk_register_frac_branch: could not find dclk_vop1_frac as parent of dclk_vop1, rate changes may not work
[   11.727061] rockchip-vop ff8f0000.vop: Adding to iommu group 3
[   11.727400] rockchip-vop ff900000.vop: Adding to iommu group 4
[   12.260440] rockchip-drm display-subsystem: bound ff8f0000.vop (ops 0xffffffc0095b6f00)
[   12.260726] rockchip-drm display-subsystem: bound ff900000.vop (ops 0xffffffc0095b6f00)
[   12.289756] rockchip-vop ff8f0000.vop: [drm:vop_crtc_atomic_enable] Update mode to 1280x1024p60, type: 14
```
Check if the resolution in the last line is 1280x1024p60; if it is not, get the bridge's firmware reflashed. A newer version of Rah may have modified the resolution; check with the Gati team.

#### 4. IP conflicts
When starting up the board, your IP might clash with others, and your SSH will lag, or the board might disconnect. To make sure that doesn't happen, we use [macacetamol](https://github.com/bojle/macacetamol).
Follow the instructions from macacetamol repo.
After it's done, we will use avahi-daemon to set your name for SSH, so you don't have to use IP address every time you SSH to your board.
```
sudo apt install avahi-daemon
systemctl start avahi-daemon.service
systemctl status avahi-daemon.service 
```
Now, set your name in its config file,
```
vim /etc/avahi/avahi-daemon.conf
```
Change the `host-name=<your_name>`. Now you can SSH to your board using 
```
ssh vicharak@<your_name>.local
```
And your IP won't clash either. 

#### 5. Run Gati
Check with the Gati team about the stable version of  **Gati** (FPGA) and **gaticc** (CPU).  
Take bitstream from the **Gati Server**.
Clone the repo of [**gaticc**](https://github.com/vicharak-in/gaticc), build it, and run the examples from `~/gaticc/examples/` with the correct model, `*.npy`, and `*_labels.txt` file.  

If everything is working, you are good to go.
For using SPI, read this [issue](https://github.com/vicharak-in/Gati/issues/220).
