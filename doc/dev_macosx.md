# bndtools.p2.repo

## local testing of oomph setups

pre-requisites is an installed [oomph eclipse installer](https://download.eclipse.org/oomph/products/)

### test on mac osx

pre-requisites: Eclipse Installer inside `/Applications/Eclipse Installer.app`

```sh
# exec this line in your shell if you want to have virgin installation
# https://wiki.eclipse.org/Eclipse_Oomph_Authoring#Testing_a_Setup_in_a_Clean_Environment
vmargs="-vmargs -Duser.home=$(pwd)/.oomph/user.home -Doomph.setup.user.home.redirect=true"

# bnd release on master
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    file:///$(pwd)/setup/config_ecl-latest_bnd-release_on_master.setup ${vmargs} &

# bnd next on master
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    file:///$(pwd)/setup/config_ecl-latest_bnd-next_on_master.setup ${vmargs} &

# bnd next on next
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    file:///$(pwd)/setup/config_ecl-latest_bnd-next_on_next.setup ${vmargs} &

# bnd release on next
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    file:///$(pwd)/setup/config_ecl-latest_bnd-release_on_next.setup ${vmargs} &

# bndtools.p2.repo
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    file:///$(pwd)/setup/config_bndtools.p2.repo.setup ${vmargs} &

```

https://www.eclipse.org/setups/installer/?url=https://raw.githubusercontent.com/eclipse-oomph/oomph/master/setups/configurations/OomphConfiguration.setup&show=true

https://shields.io/badges/static-badge


## testing of deploye oomph setups on github



```sh
# bnd next on master
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/config_ecl-latest_bnd-next_on_master.setup

# bnd next on next
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/config_ecl-latest_bnd-next_on_next.setup

# bnd release on master
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/config_ecl-latest_bnd-release_on_master.setup

# bnd release on next
"/Applications/Eclipse Installer.app/Contents/MacOS/eclipse-inst" \
    https://raw.githubusercontent.com/bndtools/bndtools.p2.repo/master/setup/config_ecl-latest_bnd-release_on_next.setup

```
