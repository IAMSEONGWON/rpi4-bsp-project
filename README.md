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