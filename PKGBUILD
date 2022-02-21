#    Copyright (C) 2022 7thCore
#    This file is part of IsRSrv-Script.
#
#    IsRSrv-Script is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    IsRSrv-Script is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

pkgname=isrsrv-script
pkgver=1.7
pkgrel=2
pkgdesc='Interstelalr Rift server script for running the server on linux with wine compatibility layer.'
arch=('x86_64')
license=('GPL3')
depends=('bash'
         'coreutils'
         'sudo'
         'grep'
         'sed'
         'awk'
         'curl'
         'rsync'
         'wget'
         'findutils'
         'tmux'
         'zip'
         'unzip'
         'p7zip'
         'postfix'
         's-nail'
         'cabextract'
         'xorg-server-xvfb'
         'wine'
         'wine-mono'
         'wine_gecko'
         'winetricks'
         'lcms2'
         'mpg123'
         'giflib'
         'gnutls'
         'gst-plugins-base'
         'gst-plugins-good'
         'libpng'
         'libpulse'
         'libxml2'
         'lib32-libpulse'
         'lib32-libxml2'
         'lib32-mpg123'
         'lib32-lcms2'
         'lib32-giflib'
         'lib32-libpng'
         'lib32-gnutls'
         'lib32-gst-plugins-base'
         'lib32-gst-plugins-good'
         'steamcmd')
install=isrsrv-script.install
source=('bash_profile'
        'isrsrv-script.bash'
        'isrsrv-send-notification@.service'
        'isrsrv@.service'
        'isrsrv-sync-tmpfs.service'
        'isrsrv-timer-1.service'
        'isrsrv-timer-1.timer'
        'isrsrv-timer-2.service'
        'isrsrv-timer-2.timer'
        'isrsrv-tmpfs@.service')
sha256sums=('f1e2f643b81b27d16fe79e0563e39c597ce42621ae7c2433fd5b70f1eeab5d63'
            'f33edb1886c24e74908e0cc6243b3baf96a4ed4fd3e8fad36f5cd65e565f3ad0'
            '3b5230d335033c9d55da30a4dda52b03907317bb5960fdb5c510ff38cc13a970'
            '9aa6c520c0a975cac4bc00f7988c1268d68653ac607117042f57f2a9089e5f97'
            '1e254761e4d1378a748f1f41e8af14c42a5e2ca9177b36f8f7acff23fccba5dd'
            '7b93ba35f0fad321709c8f71b600b0e5737f369787da4fa283cc8ab0ba48ae04'
            '11358634dff614caadaf211ce7397cf0d7a068621d10aa726fee4b4205cd0e6d'
            '0d474b1c6ea0a33d22fe45448d19ebc26753ff4180b95c6aec4d1d89e1ef7abb'
            '9f58383366cf11c7f859681c47821b1d95986171a7c68a605f70ef6cc0444d83'
            '4b148e2504ee0f2db3039aabfe0664fdeee6be2c871b6d00f77647710249352d')

package() {
  install -d -m0755 "${pkgdir}/usr/bin"
  install -d -m0755 "${pkgdir}/srv/isrsrv"
  install -d -m0755 "${pkgdir}/srv/isrsrv/server"
  install -d -m0755 "${pkgdir}/srv/isrsrv/config"
  install -d -m0755 "${pkgdir}/srv/isrsrv/updates"
  install -d -m0755 "${pkgdir}/srv/isrsrv/backups"
  install -d -m0755 "${pkgdir}/srv/isrsrv/logs"
  install -d -m0755 "${pkgdir}/srv/isrsrv/tmpfs"
  install -d -m0755 "${pkgdir}/srv/isrsrv/.config"
  install -d -m0755 "${pkgdir}/srv/isrsrv/.config/systemd"
  install -d -m0755 "${pkgdir}/srv/isrsrv/.config/systemd/user"
  install -D -Dm755 "${srcdir}/isrsrv-script.bash" "${pkgdir}/usr/bin/isrsrv-script"
  install -D -Dm755 "${srcdir}/isrsrv-timer-1.timer" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-timer-1.timer"
  install -D -Dm755 "${srcdir}/isrsrv-timer-1.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-timer-1.service"
  install -D -Dm755 "${srcdir}/isrsrv-timer-2.timer" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-timer-2.timer"
  install -D -Dm755 "${srcdir}/isrsrv-timer-2.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-timer-2.service"
  install -D -Dm755 "${srcdir}/isrsrv-send-notification@.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-send-notification@.service"
  install -D -Dm755 "${srcdir}/isrsrv@.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv@.service"
  install -D -Dm755 "${srcdir}/isrsrv-sync-tmpfs.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-sync-tmpfs.service"
  install -D -Dm755 "${srcdir}/isrsrv-tmpfs@.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-tmpfs@.service"
  install -D -Dm755 "${srcdir}/bash_profile" "${pkgdir}/srv/isrsrv/.bash_profile"
}
