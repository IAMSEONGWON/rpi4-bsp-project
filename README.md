# Raspberry Pi 4 BSP Project

## 1. Setup

프로젝트를 빌드하기 위해 아래 명령어를 실행합니다.
```bash
# 레포지토리 클론 (서브모듈 포함)
git clone --recursive [https://github.com/IAMSEONGWON/rpi4-bsp-project.git](https://github.com/IAMSEONGWON/rpi4-bsp-project.git)

# 빌드 환경 초기화
source poky/oe-init-build-env build
```
---

## 2. Project Phases

### Phase 1: Custom Driver & Automation
* **Kernel Driver**: MMIO를 이용한 GPIO LED 제어 드라이버 구현 (`meta-my-driver`)
* **Device Tree**: 커스텀 LED 제어를 위한 Device Tree Overlay (`.dtbo`) 적용
* **Automation**: Yocto 레시피를 통한 드라이버 빌드 및 배포 자동화
* **Verification**: 시스템 부팅 시 커널 모듈 자동 로드 및 LED 점등 확인

### Phase 2: Boot Time Optimization
* **Target**: 부팅 후 3초 이내 LED 점등
* **Key Settings**:
    * **Silent Boot**: 커널 로그 레벨 조정(`loglevel=0`) 및 콘솔 출력 억제
    * **Bootloader**: `boot_delay=0`, `disable_splash=1` 설정을 통한 대기 시간 제거
    * **Performance**: `initial_turbo=60` 적용으로 초기 부팅 시 CPU 성능 극대화

---

## 3. Performance Results

`dmesg | grep LED` 명령어를 통해 측정된 드라이버 로드 시점 결과입니다.

| Stage | Boot Time (LED Probe) | Status | Improvement |
| :--- | :---: | :---: | :---: |
| **Baseline (Phase 1)** | 5.07s | Done | - |
| **Optimized (Phase 2)** | **2.10s** | **Success** | **▲ 58.5%** |

---

## 4. Build & Flash

### Local Configuration (`build/conf/local.conf`)
빌드 시 아래 설정을 `local.conf`에 추가해야 합니다.

```bitbake
# Driver & Packages
IMAGE_INSTALL:append = " kernel-modules simple-driver"

# Boot Configuration
IMAGE_BOOT_FILES:append = " my-led.dtbo;overlays/my-led.dtbo"
RPI_EXTRA_CONFIG:append = " \n \
    dtoverlay=my-led \n \
    disable_splash=1 \n \
    boot_delay=0 \n \
    initial_turbo=60 \n \
"
CMDLINE:append = " quiet loglevel=0 console=tty3"
```
---

## Build & Writing
### 이미지 빌드
```bash
bitbake core-image-base
```

---

## 5. OTA Update (RAUC)

이 섹션은 RAUC를 이용한 A/B 파티션 업데이트 시스템 구축 중 발생한 이슈와 이를 해결한 과정을 기록합니다.

### RAUC OTA Debugging Report

본 프로젝트에서는 RAUC를 이용한 A/B 파티션 업데이트 중 발생한 부팅 실패 및 상태 인식 오류를 아래와 같이 해결하였습니다.

#### [발생했던 주요 문제 (Critical Issues)]

* **Issue 1: "Double Root" 현상 (이중 루트)**
    * **증상:** 실제로는 B 슬롯으로 부팅되었으나, `rauc status`에서 `Booted from: A`로 표시됨.
    * **원인:** 펌웨어 `bootargs`(A)와 스크립트 `bootargs`(B)가 중복 전달되어 RAUC가 첫 번째 인자인 A를 보고 현재 슬롯을 오판함.

* **Issue 2: U-Boot Environment 충돌 (Boot Loop)**
    * **증상:** `uboot.env` 파일이 존재하거나 수정되면 재부팅 시 시스템 멈춤 (Red LED 점등).
    * **원인:** U-Boot 설정과 실제 생성된 환경 변수 파일 간의 체크섬 포맷 불일치.

* **Issue 3: FDT 메모리 부족 (Kernel Panic)**
    * **증상:** `fdt set` 명령 사용 시 부팅 불가.
    * **원인:** DTB 메모리 공간 부족으로 인한 오버플로우 발생.

#### [해결 방안 (Resolution)]

* **Solution 1: FDT 리사이징 (메모리 확보)**
    부팅 스크립트 최상단에 메모리 공간 확장 명령어 추가.
    ```bash
    fdt addr ${fdt_addr}
    fdt resize 16384
    ```

* **Solution 2: "Boot Force" 스크립트 적용**
    `uboot.env` 의존성을 제거하고 스크립트 레벨에서 직접 타겟 지정.
    1.  타겟 루트를 `/dev/mmcblk0p3` (B 슬롯)으로 강제 지정.
    2.  깨끗한 `bootargs`를 새로 조립하여 커널에 전달함으로써 이중 루트 문제 해결.

* **Solution 3: RAUC 상태 인식 우회 (Cosmetic Fix)**
    상태 표시 정상화를 위해 임시 환경 변수 파일 매핑 및 수동 주입.
    * `/tmp/dummy.env` 생성 후 `fw_setenv`를 통해 `BOOT_B_BOOTSTATUS=good` 주입.

#### [최종 부팅 스크립트 (boot.cmd)]

```bash
# 하드웨어 정보 로드 및 메모리 확보
fdt addr ${fdt_addr}
fdt resize 16384

# 타겟 슬롯 강제 지정 (B Slot)
setenv target_root "/dev/mmcblk0p3"

# 부팅 인자 재정의
setenv bootargs "console=serial0,115200 console=tty1 root=${target_root} rootwait fsck.repair=yes"

# 커널 부팅
echo "Forcing Boot to Slot B..."
fatload mmc 0:1 ${kernel_addr_r} Image
booti ${kernel_addr_r} - ${fdt_addr}