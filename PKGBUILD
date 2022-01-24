# Maintainer: 7thCore

pkgname=isrsrv-script
pkgver=1.5
pkgrel=7
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
         'findutils'
         'cabextract'
         'unzip'
         'p7zip'
         'wget'
         'tmux'
         'postfix'
         'zip'
         'jq'
         'samba'
         'xorg-server-xvfb'
         'wine'
         'wine-mono'
         'wine_gecko'
         'winetricks'
         'libpulse'
         'libxml2'
         'mpg123'
         'lcms2'
         'giflib'
         'libpng'
         'gnutls'
         'gst-plugins-base'
         'gst-plugins-good'
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
            'c68a6bb44aaf3caf9dffd902b4813e762a0ce52ff3661b0abf53d067bad319ad'
            '3b5230d335033c9d55da30a4dda52b03907317bb5960fdb5c510ff38cc13a970'
            '5dbcea8559f265e873364a34f7cc89ca5bb713c4e0fa439e9fadfdbe64b3f608'
            'ff853ac3c2e89617f632536b0323ffc1fef9cf9578c3b56d571747ed36dfbda7'
            '7b93ba35f0fad321709c8f71b600b0e5737f369787da4fa283cc8ab0ba48ae04'
            '11358634dff614caadaf211ce7397cf0d7a068621d10aa726fee4b4205cd0e6d'
            '0d474b1c6ea0a33d22fe45448d19ebc26753ff4180b95c6aec4d1d89e1ef7abb'
            '9f58383366cf11c7f859681c47821b1d95986171a7c68a605f70ef6cc0444d83'
            '010ec6935ec3a619e3139720ff888853292cbee5b8e8a0ce6d2cc7bd85d067d2')

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
