CFLAGS += -I $(BASE)arch/arm/include/

BT_CONFIG_ARCH_ARM_CORTEX-M0=y

ifeq ($(BT_CONFIG_DRIVERS_SDCARD), y)
BT_CONFIG_DRIVERS_SDCARD_HOST_SDHCI=y
endif

BT_CONFIG_FREERTOS_PORT_ARCH=BT_CONFIG_FREERTOS_M0
