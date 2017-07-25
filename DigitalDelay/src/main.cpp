#include "em_adc.h"
#include "em_dac.h"
#include "em_chip.h"
#include "em_cmu.h"
#include "em_device.h"
#include "em_dma.h"
#include "em_emu.h"
#include "em_core.h"
#include "em_lcd.h"
#include "em_prs.h"
#include "em_rtc.h"
#include "em_timer.h"
#include "dmactrl.h"
#include "segmentlcd.h"
#include "em_gpio.h"

#define TOP_VALUE 0x13Du
#define ADC_CLOCK 11e6

// Evil global variable for the sample we're gathering
volatile uint16_t sampleValue;

// Evil counter variable
volatile int counter = 0;

// Evil buffer
volatile uint16_t delaySamples[10000];

/**
 * Even IRQ handler for GPIO pins
 */
void GPIO_EVEN_IRQHandler(void) {
	GPIO->IFC = GPIO->IF;
}

/**
 * Odd IRQ handler for GPIO pins
 */
void GPIO_ODD_IRQHandler(void) {
	GPIO->IFC = GPIO->IF;
}

/**
 * TIMER0 IRQ handler, where the processing actually occurs. All processing needs to happen before
 * 1/44100 of a second, which should be relatively easy at 14 MHz with this chip.
 */
void TIMER0_IRQHandler(void) {
	TIMER0->IFC |= TIMER0->IF;

	// Scan the ADC channels in here
	ADC_Start(ADC0, adcStartSingle);

	/* Wait while conversion is active */
	while (ADC0->STATUS & ADC_STATUS_SINGLEACT){}

	/* Get ADC result */
	sampleValue = ADC_DataSingleGet(ADC0);


	if(counter == 3999) {
		counter = 0;
	} else {
		counter++;
	}

	// TODO: Processing of input signal, checking of potentiometers, checking of modulation switch
	// When pinging the ADC channel for the potentiometers, need to change
	// which channel the ADC scan originates from
	int output = 0;
	if(counter == 0) {
		output = sampleValue + 0.3*delaySamples[9999];
	} else {
		output = sampleValue + 0.3*delaySamples[counter];
	}

	DAC0->CH0DATA = output << 1;

	//DAC0->CH0DATA = sampleValue;

	delaySamples[counter] = output << 1;
}

/**
 * Setup the GPIO pins as inputs and enable interrupts on the falling edge
 */
void gpioSetup(void) {
	/* Enable GPIO clock in CMU */
	CMU_ClockEnable(cmuClock_GPIO, true);

	/* Configure push buttons PB0 and PB1 */
	GPIO_PinModeSet(gpioPortB, 9, gpioModeInput, 1);
	GPIO_IntConfig(gpioPortB, 9, false, true, true);

	GPIO_PinModeSet(gpioPortB, 10, gpioModeInput, 1);
	GPIO_IntConfig(gpioPortB, 10, false, true, true);

	GPIO_PinModeSet(gpioPortD, 0, gpioModeInput, 0);
	GPIO_PinModeSet(gpioPortB, 11, gpioModePushPull, 0);

	/* Enable interrupt in core for even and odd GPIO interrupts */
	NVIC_ClearPendingIRQ(GPIO_EVEN_IRQn);
	NVIC_EnableIRQ(GPIO_EVEN_IRQn);

	NVIC_ClearPendingIRQ(GPIO_ODD_IRQn);
	NVIC_EnableIRQ(GPIO_ODD_IRQn);
}

/**
 * Setup the ADC as a single scan mode and keep it warm for each sample
 */
void adcSetup(void) {
	// Enable the clock to the ADC
	CMU_ClockEnable(cmuClock_ADC0, true);

	// Some default settings for the ADC
	ADC_Init_TypeDef       init       = ADC_INIT_DEFAULT;
	ADC_InitSingle_TypeDef singleInit = ADC_INITSINGLE_DEFAULT;

	// Set the timebase to the HF peripheral clock, and scale it to 11 MHz ADC clock
	// 11 MHz should be way more than fast enough to work for audio applications
	init.timebase = ADC_TimebaseCalc(0);
	init.prescale = ADC_PrescaleCalc(ADC_CLOCK, 0);
	init.warmUpMode = adcWarmupKeepADCWarm;
	singleInit.reference = adcRefVDD;
	ADC_Init(ADC0, &init);

	// Input VDD/3 for testing. Actual input is CHANNEL0
	//singleInit.input      = adcSingleInpVDDDiv3;
	singleInit.input      = adcSingleInputCh0;

	/* The datasheet specifies a minimum aquisition time when sampling VDD/3 */
	/* 32 cycles should be safe for all ADC clock frequencies */
	singleInit.acqTime = adcAcqTime32;
	ADC_InitSingle(ADC0, &singleInit);
}

/**
 * Setup the DAC to output our effected guitar signal
 */
void dacSetup(void) {
	// TODO: setup the DAC!
	CMU_ClockEnable(cmuClock_DAC0, true);

	DAC_Init_TypeDef init = DAC_INIT_DEFAULT;
	DAC_InitChannel_TypeDef channelInit = DAC_INITCHANNEL_DEFAULT;

	// DAC setup
	init.outMode = dacOutputPin;
	init.reference = dacRefVDD;
	init.convMode = dacConvModeContinuous;
	channelInit.enable = true;

	DAC_Init(DAC0, &init);
	DAC_InitChannel(DAC0, &channelInit, 0);
}

/**
 * Setup the timer to overflow at 44.1 kHz and trigger an interrupt on every overflow
 */
void timerSetup(void) {
	// Turn the clock to the timer on
	CMU_ClockEnable(cmuClock_TIMER0, true);

	// Start with the default timer settings and modify them
	TIMER_Init_TypeDef timerInit = TIMER_INIT_DEFAULT;
	// Enable the overflow interrupt
	TIMER0->IFC |= 0x1;
	NVIC_ClearPendingIRQ(TIMER0_IRQn);
	NVIC_EnableIRQ(TIMER0_IRQn);
	TIMER0->IEN |= 0x1;
	// Timer pops every 1/44100 secs, so count is 1/44100 s * (14e6 / 64) (1/s)
	TIMER0->TOP = TOP_VALUE;
	TIMER_Init(TIMER0, &timerInit);
}

/**
 * Brief main function
 */
int main(void)
{
	/* Chip errata */
	CHIP_Init();

	// Setup the gpio pins
	gpioSetup();

	// Setup the ADC
	adcSetup();

	// Setup the DAC
	dacSetup();

	// Setup the timer
	timerSetup();

	/* Infinite loop */
	while (1) { }
}
