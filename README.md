# PPPoEDI

PPPoEDI is an App made by the Laboratório de Administração de Redes (LAR) to authenticate users from Departamento de Informática (DI) - UFES and serve internet connection by using PPPD.

## Building and Installation

You'll need the following dependencies to build:

- meson (>= 0.40.1)
- libgtk-3-dev
- valac (>= 0.30)
- dh-systemd

You'll need the following dependencies to run:

- ppp (>= 2.4.7)
- rp-pppoe (>= 3.11)
- iproute2 (>= 4.3.0)

Run `meson build` to configure the build environment and then change to the build directory and run `ninja` to build

```
meson build --prefix=/usr
cd build
ninja
```

To install, use `ninja install`, then execute with `br.inf.ufes.lar.pppoedi`

```
sudo ninja install
br.inf.ufes.lar.pppoedi
```