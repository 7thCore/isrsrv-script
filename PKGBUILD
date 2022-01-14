# Maintainer: 7thCore <https://discord.gg/zWbg88n3PU>

pkgname=isrsrv-script
pkgver=1.0
pkgrel=1
pkgdesc='Interstelalr Rift server script for running the server on linux with wine compatibility layer.'
arch=('x86_64')
depends=('bash'
         'coreutils'
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
         'curl'
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
         'lib32-gst-plugins-good')
backup=('isrsrv-commands.bash')
install=isrsrv-script.install
source=('isrsrv-script.bash'
        'isrsrv-commands.bash'
        'isrsrv-timer-1.timer'
        'isrsrv-timer-1.service'
        'isrsrv-timer-2.timer'
        'isrsrv-timer-2.service'
        'isrsrv-send-notification@.service'
        'isrsrv@.service'
        'isrsrv-sync-tmpfs.service'
        'isrsrv-tmpfs@.service'
        'isrsrv-commands@.service'
        'bash_profile')
noextract=('')
sha256sums=('a09947273b6366bd448cfcaa3a223acc6f28dc84f5cef16045e120ab1aec9032'
            'e5375a87b5504b6aa8a1879c21753747b808f57abeb87a18cab43b2103e9b9cc'
            '41a46234e8e05f95c0962e4e8ba7ae73eb06b09c6775c7363b5777ab1258130f'
            '37f964cb659ba46efb0f762d31f1868110e006c8b5c79d995b83ce9dd8f64812'
            'af6eef553ef225c8d72afc6bfb5052a692c3caacef3f46f9388f41a540767683'
            'ae84267a1bb4b6c003c24fded89174b29bc2f0d7c19d6f7a0cd055c3a89cefbd'
            'ea0d09bc4d88b8170c1668a916f2811f654596cd8b3023762f63e658df4bee95'
            '68b0417c5c461a981f0c40004fd05586ec69bb8671b6be1b1384c788c3e21979'
            'c6ca1e911c924abde59d1188c42153b8f79d47d0d6b6bb6ffc6e0c6b1595275c'
            '71add8fbbc565394098b23e4576459b493fda9f75736b57d2c11bb7ce080aec8'
            '59a90e7e0e74b21299c992f81733827362537a9c125164dbf14efe8423ab4d93'
            'f1e2f643b81b27d16fe79e0563e39c597ce42621ae7c2433fd5b70f1eeab5d63')

package() {
  install -d -m0755 "${pkgdir}/usr/bin"
  install -d -m0755 "${pkgdir}/srv/isrsrv"
  install -d -m0755 "${pkgdir}/srv/isrsrv/server"
  install -d -m0755 "${pkgdir}/srv/isrsrv/config"
  install -d -m0755 "${pkgdir}/srv/isrsrv/updates"
  install -d -m0755 "${pkgdir}/srv/isrsrv/backups"
  install -d -m0755 "${pkgdir}/srv/isrsrv/logs"
  install -d -m0755 "${pkgdir}/srv/isrsrv/.config"
  install -d -m0755 "${pkgdir}/srv/isrsrv/.config/systemd"
  install -d -m0755 "${pkgdir}/srv/isrsrv/.config/systemd/user"
  install -D -Dm755 "${srcdir}/isrsrv-script.bash" "${pkgdir}/usr/bin/isrsrv-script"
  install -D -Dm755 "${srcdir}/isrsrv-commands.bash" "${pkgdir}/usr/bin/isrsrv-commands"
  install -D -Dm755 "${srcdir}/isrsrv-timer-1.timer" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-timer-1.timer"
  install -D -Dm755 "${srcdir}/isrsrv-timer-1.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-timer-1.service"
  install -D -Dm755 "${srcdir}/isrsrv-timer-2.timer" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-timer-2.timer"
  install -D -Dm755 "${srcdir}/isrsrv-timer-2.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-timer-2.service"
  install -D -Dm755 "${srcdir}/isrsrv-send-notification@.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-send-notification@.service"
  install -D -Dm755 "${srcdir}/isrsrv@.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv@.service"
  install -D -Dm755 "${srcdir}/isrsrv-sync-tmpfs.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-sync-tmpfs.service"
  install -D -Dm755 "${srcdir}/isrsrv-tmpfs@.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-tmpfs@.service"
  install -D -Dm755 "${srcdir}/isrsrv-commands@.service" "${pkgdir}/srv/isrsrv/.config/systemd/user/isrsrv-commands@.service"
  install -D -Dm755 "${srcdir}/bash_profile" "${pkgdir}/srv/isrsrv/.bash_profile"
}
