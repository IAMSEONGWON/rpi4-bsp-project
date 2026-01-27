fdt addr ${fdt_addr}
fdt resize 16384

# 환경 변수 초기화 (없을 경우 대비)
test -n "${BOOT_ORDER}" || setenv BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || setenv BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || setenv BOOT_B_LEFT 3

echo "Checking Boot Order: ${BOOT_ORDER}"

# 슬롯 순회 시작
for slot in ${BOOT_ORDER}; do
    if test "${slot}" = "A"; then
        if test ${BOOT_A_LEFT} -gt 0; then
            echo "Attempting Slot A... (Remaining: ${BOOT_A_LEFT})"
            setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
            saveenv # 시도하기 직전에 미리 카운트를 깎고 저장
            
            setenv target_root "/dev/mmcblk0p2"
            setenv rauc_slot "A"
            
            # 파일 로드 시도
            if fatload mmc 0:1 ${kernel_addr_r} Image; then
                setenv bootargs "console=serial0,115200 root=${target_root} rootwait rauc.slot=${rauc_slot}"
                booti ${kernel_addr_r} - ${fdt_addr}
            fi
            echo "Slot A failed to load Image."
        fi
    fi

    if test "${slot}" = "B"; then
        if test ${BOOT_B_LEFT} -gt 0; then
            echo "Attempting Slot B... (Remaining: ${BOOT_B_LEFT})"
            setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
            saveenv # 시도하기 직전에 미리 카운트를 깎고 저장
            
            setenv target_root "/dev/mmcblk0p3"
            setenv rauc_slot "B"
            
            if fatload mmc 0:1 ${kernel_addr_r} Image; then
                setenv bootargs "console=serial0,115200 root=${target_root} rootwait rauc.slot=${rauc_slot}"
                booti ${kernel_addr_r} - ${fdt_addr}
            fi
            echo "Slot B failed to load Image."
        fi
    fi
done

# 모든 슬롯 실패 시 복구 모드 (또는 무한 루프 방지를 위한 중단)
echo "CRITICAL ERROR: No valid slots left or all images corrupted."
echo "Falling back to U-Boot prompt..."
# 여기서 reset을 빼야 무한 재부팅을 멈추고 디버깅을 할 수 있음