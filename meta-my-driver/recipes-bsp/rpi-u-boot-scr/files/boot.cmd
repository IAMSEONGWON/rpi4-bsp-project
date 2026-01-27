fdt addr ${fdt_addr}
fdt resize 16384

# 기본값 설정 (RAUC 변수가 없을 때를 대비)
test -n "${BOOT_ORDER}" || setenv BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || setenv BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || setenv BOOT_B_LEFT 3

# 부팅 슬롯 결정
# BOOT_ORDER를 읽어서 앞에서부터 시도
for slot in ${BOOT_ORDER}; do
    if test "${slot}" = "A"; then
        if test ${BOOT_A_LEFT} -gt 0; then
            setenv bootargs "console=serial0,115200 root=/dev/mmcblk0p2 rootwait fsck.repair=yes rauc.slot=A"
            # 횟수 차감 (부팅 실패 시 롤백을 위해)
            setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
            echo "Found valid slot A, booting..."
            saveenv  # 변경된 횟수 저장
            fatload mmc 0:1 ${kernel_addr_r} Image
            booti ${kernel_addr_r} - ${fdt_addr}
        fi
    fi
    if test "${slot}" = "B"; then
        if test ${BOOT_B_LEFT} -gt 0; then
            setenv bootargs "console=serial0,115200 root=/dev/mmcblk0p3 rootwait fsck.repair=yes rauc.slot=B"
            setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
            echo "Found valid slot B, booting..."
            saveenv
            fatload mmc 0:1 ${kernel_addr_r} Image
            booti ${kernel_addr_r} - ${fdt_addr}
        fi
    fi
done

# 둘 다 실패하면 복구 모드로 빠지거나 리셋
echo "No valid slot found! Resetting..."
reset