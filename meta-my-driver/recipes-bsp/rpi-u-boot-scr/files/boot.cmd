# B 슬롯 영구 고정 스크립트
# uboot.env 의존성 제거 버전

# 하드웨어 정보 로드
fdt addr ${fdt_addr}

# 메모리 공간 확보 (안전 장치)
fdt resize 16384

# 강제로 B(p3)로 지정
setenv target_root "/dev/mmcblk0p3"

# 부팅 인자 설정 (기존 정보 무시하고 덮어쓰기)
setenv bootargs "console=serial0,115200 console=tty1 root=${target_root} rootwait fsck.repair=yes"

# 커널 로드 및 부팅
echo "Forcing Boot to Slot B (Permanent)..."
fatload mmc 0:1 ${kernel_addr_r} Image
booti ${kernel_addr_r} - ${fdt_addr}