#
# spec file for package indicator-kdeconnect
#
# Copyright © 2014–2017 Markus S. <kamikazow@web.de>
# Copyright © 2016–2017 Bajoja <steevenlopes@outlook.com>
# Copyright © 2017 Raúl García <raul@bgta.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

Name:           indicator-kdeconnect
Version:        0.7.1
Release:        0%{?dist}
Summary:        App Indicator for KDE Connect
Group:          Applications/System
License:        LGPL-2.1+
URL:            https://github.com/Bajoja/indicator-kdeconnect

# For this spec file to work, the sources must be located in a directory
# named indicator-kdeconnect-1.2.2 (with "1.2.2" being the version
# number defined above).
# If the sources are compressed in another format than .tar.xz, change the
# file extension accordingly.
Source0:        %{name}-%{version}.tar.xz
%if 0%{?suse_version}
Source1:        kdeconnect.png
%endif

# Package names only verified with Fedora.
# Should the packages in your distro be named differently,
# see http://en.opensuse.org/openSUSE:Build_Service_cross_distribution_howto
BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  gtk3-devel
BuildRequires:  vala
BuildRequires:  vala-devel
BuildRequires:  pkgconfig(gtk+-3.0)
Requires:          \python3-requests-oauthlib 

%if 0%{?fedora} || 0%{?rhel_version} || 0%{?centos_version}
BuildRequires:  libappindicator-gtk3-devel
Requires:       kde-connect-libs
%endif

%if 0%{?suse_version}
BuildRequires:  update-desktop-files
BuildRequires:  libappindicator3-devel
Requires:       kdeconnect-kde
%endif

%description
Indicator to make KDE Connect usable in desktops without KDE Plasma.
A small program, kdeconnect-send, to help sending files from PC to Android is included.

%prep
%setup -q

%build
%__mkdir build
cd build
cmake .. \
        -DCMAKE_INSTALL_PREFIX="%_prefix" \
        -DCMAKE_INSTALL_LIBEXEC="%_libexecdir" \
        -DCMAKE_C_FLAGS="%optflags" \
        -DCMAKE_CXX_FLAGS="%optflags"

make %{?_smp_mflags}

%install
cd build
%make_install

%if 0%{?suse_version}
%suse_update_desktop_file -r -i %name Network Telephony
%endif

%files
%defattr(-,root,root,-)

%if 0%{?sle_version} <= 120200 && 0%{?suse_version} <= 1320
%doc README.md COPYING
%else
%doc README.md
%license COPYING
%endif

%dir %{_datadir}/caja-python
%dir %{_datadir}/contractor
%dir %{_datadir}/indicator-kdeconnect
%dir %{_datadir}/nautilus-python
%dir %{_datadir}/nemo-python
%dir %{_datadir}/Thunar
%{_bindir}/%{name}
%{_bindir}/kdeconnect-send
%{_bindir}/indicator-kdeconnect/Sms.py
%{_datadir}/locale/*/LC_MESSAGES/indicator-kdeconnect.mo
%{_datadir}/applications/%{name}.desktop
%{_datadir}/contractor/kdeconnect.contract
%{_datadir}/%{name}
%{_datadir}/nautilus-python/extensions/
%{_datadir}/nemo-python/extensions/
%{_datadir}/caja-python/extensions/
%{_datadir}/Thunar/sendto/
%if 0%{?suse_version}
%{_datadir}/pixmaps/kdeconnect.png
%endif
%if 0%{?fedora} || 0%{?rhel_version} || 0%{?centos_version}
%{_datadir}/icons/Adwaita/*/*/*
%endif


%changelog
* Sat Apr 08 2017 21:30 Bajoja <steevenlopes@outlook.com> 0.7.1
- Fix bug #51 - Nemo and Caja extensions not working
- Add Language: Lituan

* Thu Mar 23 2017 2300 Bajoja <steevenlopes@outlook.com> 0.7
- Fix bug #46 - Nautilus freeze on copy/paste - URGENT
- Fix Desktop Computers don't appear on kdeconnect-send context menu
- New UI for kdeconnect-send (move controls to header bar)
  and a button to reload devices
- Add kdeconnect-send to Thunar 'send to' context menu
- File manager extensions now is translated
- Add Languages: French, Spanish, Catalan, Italian
- Kdeconnect-send script for file manager not supported
  by extension can send multiple files
- Provide OpenSuse repo - Thanks to Raúl García

* Tue Mar 7 2017 0300 Markus S. <kamikazow@web.de> 0.6-1
- Ported openSUSE compatibility changes by Raúl García <raul@bgta.net>
- Cleaned up specfile a bit.

* Thu Jan 26 2017 0200 Bajoja <steevenlopes@outlook.com> 0.6
- Monochrome icons for Gnome.
- KDEConnect-send and Elementary OS can send multiple files.
- Add German, Dutch, Czech, Croatian and Hungarian languages.
- Now you can Send SMS as a Beta Feature.

* Tue Jan 03 2017 1800 Bajoja <steevenlopes@outlook.com> 0.5
- Bugs Fixes.
- Add Brazilian Portuguese Language.
- Add icons for Elementary OS.
- Trusted devices now appear on context menu extension to send files directly.

* Thu Nov 24 2016 1700 Bajoja <steevenlopes@outlook.com> 0.4
- New native extension for Nautilus, Caja and Nemo.
- Now Indicator-kdeconnect provide translations.
- Add Portuguese Portugal and Russian Language.
- Provide CMake uninstall process.

* Tue Nov 15 2016 1644 Bajoja <steevenlopes@outlook.com> 0.3
- Bug Fixes.
- New default icons.
- New Icons for Ubuntu based desktops.
- New Images for First time wizard.

* Sun Nov 06 2016 2100 Bajoja <steevenlopes@outlook.com> 0.2
- Bug Fixes.
- Features:
  - Multiple files send from the indicator.
  - Menu to ring and find your phone.
  - Icons can low and higth color case device is paired or unpaired.
  - From the device name menu you can get encryption information.
  - From the device status menu item you can open kdeconnect settings.

* Mon Aug 20 2012 0323 Bajoja <steevenlopes@outlook.com> 0.1
- Initial Release.

