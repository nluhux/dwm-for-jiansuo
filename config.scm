(use-modules
 (gnu)
 (gnu packages)
 (guix build-system gnu)
 (guix gexp)
 (guix download)
 (guix packages)
 )
(use-service-modules 
 auditd desktop linux monitoring 
 sound ssh pm xorg
 )
(use-package-modules 
 certs fcitx fonts fontutils image-viewers
 suckless wm xorg
 )

(define my-dwm
  (package
   (inherit dwm)
   (source
    (local-file "src/dwm-6.3"
		#:recursive? #t))))
(define my-surf
  (package
   (inherit surf)
   (source
    (local-file "src/surf-2.1"
		#:recursive? #t))))

(operating-system
 (host-name "public-check-machine")
 (timezone "Asia/Shanghai")
 (locale "zh_CN.utf8")
 (keyboard-layout
  (keyboard-layout "us"))
 (bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (targets '("/dev/sda"))
   (keyboard-layout keyboard-layout)))
 (file-systems
  (append
   (list (file-system
	  (device "/dev/sda1")
	  (mount-point "/")
	  (type "ext4")))
   %base-file-systems))
 (users
  (append
   (list (user-account
	  (name "guest")
	  (comment "Guest User")
	  (group "guests")
	  (supplementary-groups
	   '("audio" "video")))
	 (user-account
	  (name "admin")
	  (comment "Administrator")
	  (group "users")
	  (supplementary-groups
	   '("wheel" "audio" "video"))))
   %base-user-accounts))
 (groups
  (append
   (list
    (user-group
     (name "guests")))
   %base-groups))
 (packages
  (append
   (list
    ;; https certs
    nss-certs
    ;; X11 tools
    xset xrdb xsetroot
    ;; wm
    my-dwm
    ;; web browser
    my-surf
    ;; wallpaper
    feh
    ;; input method
    fcitx fcitx-configtool
    ;; font
    font-gnu-unifont fontconfig
    )
   %base-packages))
 (services
  (append
   (list
    (service
     earlyoom-service-type
     (earlyoom-configuration
      (memory-report-interval 30)))
    (service
     zabbix-agent-service-type
     (zabbix-agent-configuration
      (log-type "system")))
    (service
     openssh-service-type
     (openssh-configuration
      (extra-content
       "AllowGroups wheel")))
    (service
     tlp-service-type
     (tlp-configuration
      (cpu-scaling-governor-on-ac (list "ondemand"))
      (cpu-scaling-governor-on-bat (list "powersave"))
      (sched-powersave-on-bat? #t)
      (sched-powersave-on-ac? #t)))
    (service
     auditd-service-type)
    (set-xorg-configuration
     (xorg-configuration
      (keyboard-layout
       keyboard-layout)))
    (extra-special-file
     "/srv/scripts/autostart.sh"
     (local-file "./scripts/autostart.sh"))
    (extra-special-file
     "/etc/system.scm"
     (local-file "./config.scm"))
    (extra-special-file
     "/srv/scripts/surf-loop"
     (local-file "./scripts/surf-loop")))
   (modify-services
    %desktop-services
    (guix-service-type
     config =>
     (guix-configuration
      (inherit config)
      (substitute-urls
       (append
	(list
	 "https://mirrors.sjtug.sjtu.edu.cn/guix/")
	%default-substitute-urls))))
    (gdm-service-type
     config =>
     (gdm-configuration
      (inherit config)
      (auto-login? #t)
      (default-user "guest")))))))
