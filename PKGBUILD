# Maintainer: 7thCore

pkgname=isrsrv-script
pkgver=1.5
pkgrel=6
pkgdesc='Interstelalr Rift server script for running the server on linux with wine compatibility layer.'
arch=('x86_64')
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
backup=('')
install=isrsrv-script.install
source=('isrsrv-script.bash'
        'isrsrv-timer-1.timer'
        'isrsrv-timer-1.service'
        'isrsrv-timer-2.timer'
        'isrsrv-timer-2.service'
        'isrsrv-send-notification@.service'
        'isrsrv@.service'
        'isrsrv-sync-tmpfs.service'
        'isrsrv-tmpfs@.service'
        'bash_profile')
noextract=('')
sha256sums=('000c644b8df46e72182f53f276df14b34187e14b01551f7a8ba848e7cb1c17af'
            '6323f441cd77c4ee2d8566e21cf77195047f9830a96613bf7587af3eeef23545'
            '370c7ab205ef5a8d8b446a0c40224b898cb691671980e2c501d556f645e41c48'
            'f9f1206b4cc49b2c38ae4104f259044b89e1df682819f3ef5360a2259f643b79'
            '985ee788a2307ead699880be28c06aefd6ef5341ef258db2e9db5de83762c38a'
            '4baae350d37ec4b32945e14562a478df73caef0bbfe11c3cf4ace2b9464a31a9'
            'a60e2e75824110f899c4be86be847aad6a49a9c57ac65d298f4cff2238289e5c'
            '8a465b479005861d0e098e3269530f8aea89851d267241cb4ccf5b29ba33cb13'
            '620184c0bdc0182a66e02132ae9754e6031275706590fc1f2634e15eb888b1a4'
            'f1e2f643b81b27d16fe79e0563e39c597ce42621ae7c2433fd5b70f1eeab5d63')

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
