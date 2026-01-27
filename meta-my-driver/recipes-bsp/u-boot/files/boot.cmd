# U-Boot Boot Script for RAUC A/B System

# 기본 설정 (기본값은 A슬롯=파티션2)
setenv rauc_slot A
setenv root_part 2

# 저장된 환경변수(uboot.env) 로드
# RAUC가 업데이트 후 'rauc_slot=B'라고 적어놨으면 그걸 읽어옴
if test -e mmc 0:1 uboot.env; then
    load mmc 0:1 ${loadaddr} uboot.env
    env import -t ${loadaddr} ${filesize}
fi

# 슬롯 판단 로직
if test "${rauc_slot}" = "B"; then
    echo "## Booting from Slot B (Partition 3) ##"
    setenv root_part 3
else
    echo "## Booting from Slot A (Partition 2) ##"
    setenv root_part 2
fi

# 부트 인자(Bootargs) 설정
# root를 우리가 선택한 파티션으로 지정
setenv bootargs "console=ttyS0,115200 console=tty1 root=/dev/mmcblk0p${root_part} rootwait panic=10 rw"

# 커널 로드 (Image 파일)
# RPi4는 커널을 ${kernel_addr_r} 주소에 로드함
load mmc 0:${root_part} ${kernel_addr_r} boot/Image

# 부팅 시작 (커널주소 - 디바이스트리주소)
# RPi 펌웨어가 FDT를 이미 메모리에 올려둠 (${fdt_addr})
booti ${kernel_addr_r} - ${fdt_addr}