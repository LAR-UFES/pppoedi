# PPPoEDI

PPPoEDI is an App made by the Laboratório de Administração de Redes (LAR) to authenticate users from 
Departamento de Informática (DI) - UFES and serve internet connection by using PPPD.

## Building and Installation

You'll need the following dependencies:
* meson
* libgtk-3-dev
* libjson-glib-dev
* valac (>= 0.26)

Run `meson build` to configure the build environment and then access the build folder

    cd build/
    
Run `ninja` to build

    ninja
    
To install use `ninja install`

    sudo ninja install
    
    

