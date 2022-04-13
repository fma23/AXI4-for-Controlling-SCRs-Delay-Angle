AXI4-for-Controlling-SCRs-Delay-Angle

This Vivado project demonstrate how to use AXI4 peripheral on a Xilinix Zynq 7020 FPGA to transfer data from the PS to the PL and vice versa. In this post, I just want to share with you how I used AXI4 in one of the industrial high power three phase AC-DC rectifiers I developed the firmware for.

The AC-DC rectifier I worked on uses Semiconductor Controlled Rectifiers, or what is commonly known as SCRs. More information about how SCRs work and theory of converting AC to DC using these Thyristors can be found on my previous tutorial: https://embeddeddesign.org/three-phase-full-wave-controller-bridge-rectifier/

Also for more information about how to implement AXI4 peripheral within your system, you can visit my previous tutorials: https://embeddeddesign.org/creating-a-custom-ip-block-in-vivado/ https://embeddeddesign.org/gpios-control-via-axi4-peripheral/
