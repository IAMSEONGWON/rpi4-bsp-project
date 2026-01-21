#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/platform_device.h> 
#include <linux/gpio/consumer.h>   
#include <linux/of.h>              

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Yun");
MODULE_DESCRIPTION("Platform LED Driver with Device Tree");

// LED 제어권을 가질 구조체 포인터
static struct gpio_desc *led_gpio;

// 장치가 발견되면 실행될 함수
static int my_led_probe(struct platform_device *pdev) {
    printk(KERN_INFO "LED Platform: Device Found! Probing...\n");

    // Device Tree에서 "gpios"라고 적힌 속성을 가져옴
    // GPIOD_OUT_LOW: 가져오자마자 일단 off (Low)
    led_gpio = devm_gpiod_get(&pdev->dev, NULL, GPIOD_OUT_LOW);
    
    if (IS_ERR(led_gpio)) {
        printk(KERN_ERR "LED Platform: Failed to get GPIO\n");
        return PTR_ERR(led_gpio);
    }

    // LED 켜기 (1)
    gpiod_set_value(led_gpio, 1);
    printk(KERN_INFO "LED Platform: LED is ON!\n");
    
    return 0;
}

// 장치가 제거되면 실행될 함수
static int my_led_remove(struct platform_device *pdev) {
    // LED 끄기 (0)
    gpiod_set_value(led_gpio, 0);
    printk(KERN_INFO "LED Platform: LED is OFF and Removed.\n");
    
    // devm_ (Device Managed) 함수를 썼기 때문에 gpio_free는 커널이 알아서 해줌
    return 0;
}

// Device Tree의 "compatible" 속성과 매칭할 테이블
static const struct of_device_id my_led_dt_ids[] = {
    { .compatible = "bright,my-led" }, // dts 파일에 이름
    { /* sentinel */ }
};
MODULE_DEVICE_TABLE(of, my_led_dt_ids);

// 드라이버 구조체 정의
static struct platform_driver my_led_driver = {
    .probe = my_led_probe,
    .remove = my_led_remove,
    .driver = {
        .name = "my_led_driver",
        .of_match_table = my_led_dt_ids, // 매칭 테이블 등록
    },
};

// 드라이버 등록 
module_platform_driver(my_led_driver);