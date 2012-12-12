.extern XSmc_NorInit
.extern XSmc_SramInit

	.section ".got2","aw"
	.align	2

	.text
.Lsbss_start:
	.long	__sbss_start

.Lsbss_end:
	.long	__sbss_end

.Lbss_start:
	.long	__bss_start

.Lbss_end:
	.long	__bss_end

.Lstack:
	.long	__stack


	.globl	_start
_start:
	bl      __cpu_init			/* Initialize the CPU first (BSP provides this) */

	mov	r0, #0

	/* clear sbss */
	ldr 	r1,.Lsbss_start		/* calculate beginning of the SBSS */
	ldr	r2,.Lsbss_end			/* calculate end of the SBSS */

.Lloop_sbss:
	cmp	r1,r2
	bge	.Lenclsbss				/* If no SBSS, no clearing required */
	str	r0, [r1], #4
	b	.Lloop_sbss

.Lenclsbss:
	/* clear bss */
	ldr	r1,.Lbss_start		/* calculate beginning of the BSS */
	ldr	r2,.Lbss_end		/* calculate end of the BSS */

.Lloop_bss:
	cmp	r1,r2
	bge	.Lenclbss		/* If no BSS, no clearing required */
	str	r0, [r1], #4
	b	.Lloop_bss

.Lenclbss:

	/* set stack pointer */
	ldr	r13,.Lstack		/* stack address */

	/* Initialize STDOUT to 115200bps */
#	ldr	r0, =UART_BAUDRATE
#	bl	Init_Uart
#ifdef PROFILING			/* defined in Makefile */
	/* Setup profiling stuff */
	#bl	_profile_init
#endif /* PROFILING */


	/* Initialize the SMC interfaces for NOR and SRAM */
#ifndef USE_AMP
	#bl	XSmc_NorInit

	#bl	XSmc_SramInit
#endif

	/* make sure argc and argv are valid */
	mov	r0, #0
	mov	r1, #0

	/* Let her rip */
	bl	main

#ifdef PROFILING
	/* Cleanup profiling stuff */
	#bl	_profile_clean
#endif /* PROFILING */

        /* All done */
	#bl	exit

.Lexit:	/* should never get here */
	b .Lexit

.Lstart:
	.size	_start,.Lstart-_start