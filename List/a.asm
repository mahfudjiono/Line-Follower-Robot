
;CodeVisionAVR C Compiler V2.05.0 Professional
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega32
;Program type             : Application
;Clock frequency          : 16,000000 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : int, width
;(s)scanf features        : int, width
;External RAM size        : 0
;Data Stack size          : 512 byte(s)
;Heap size                : 0 byte(s)
;Promote 'char' to 'int'  : Yes
;'char' is unsigned       : Yes
;8 bit enums              : Yes
;global 'const' stored in FLASH: No
;Enhanced core instructions    : On
;Smart register allocation     : On
;Automatic register allocation : On

	#pragma AVRPART ADMIN PART_NAME ATmega32
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2143
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU GICR=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0060
	.EQU __SRAM_END=0x085F
	.EQU __DSTACK_SIZE=0x0200
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _rpwm=R4
	.DEF _lpwm=R6
	.DEF _max1=R8
	.DEF _m=R10
	.DEF _lc=R12

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer0_ovf_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;REGISTER BIT VARIABLES INITIALIZATION
__REG_BIT_VARS:
	.DW  0x0000

_0x3:
	.DB  0x64
_0x0:
	.DB  0x44,0x4F,0x4E,0x45,0x20,0x53,0x41,0x56
	.DB  0x45,0x21,0x0,0x20,0x20,0x20,0x20,0x20
	.DB  0x52,0x45,0x41,0x44,0x59,0x20,0x54,0x4F
	.DB  0x20,0x20,0x20,0x20,0x20,0x0,0x20,0x20
	.DB  0x20,0x43,0x41,0x4C,0x49,0x42,0x52,0x41
	.DB  0x54,0x49,0x4F,0x4E,0x20,0x20,0x0,0x53
	.DB  0x63,0x61,0x6E,0x69,0x6E,0x67,0x20,0x73
	.DB  0x65,0x6E,0x73,0x6F,0x72,0x0,0x5B,0x20
	.DB  0x25,0x64,0x20,0x5D,0x5B,0x25,0x69,0x5D
	.DB  0x0,0x53,0x41,0x56,0x45,0x20,0x44,0x41
	.DB  0x54,0x41,0x2E,0x2E,0x2E,0x0,0x44,0x4F
	.DB  0x4E,0x45,0x21,0x0,0x50,0x72,0x6F,0x70
	.DB  0x6F,0x72,0x73,0x69,0x6F,0x6E,0x61,0x6C
	.DB  0x20,0x20,0x20,0x20,0x20,0x0,0x4B,0x70
	.DB  0x3D,0x25,0x30,0x33,0x64,0x20,0x0,0x49
	.DB  0x6E,0x74,0x65,0x67,0x72,0x61,0x74,0x69
	.DB  0x66,0x20,0x0,0x4B,0x69,0x3D,0x25,0x30
	.DB  0x33,0x64,0x20,0x0,0x44,0x65,0x72,0x65
	.DB  0x76,0x61,0x74,0x69,0x66,0x20,0x20,0x20
	.DB  0x20,0x0,0x4B,0x64,0x3D,0x25,0x30,0x33
	.DB  0x64,0x20,0x0,0x20,0x20,0x20,0x20,0x5B
	.DB  0x53,0x45,0x54,0x54,0x49,0x4E,0x47,0x5D
	.DB  0x0,0x54,0x69,0x6D,0x65,0x72,0x20,0x25
	.DB  0x30,0x32,0x64,0x20,0x3D,0x25,0x30,0x33
	.DB  0x64,0x20,0x20,0x20,0x20,0x0,0x43,0x6F
	.DB  0x75,0x6E,0x74,0x31,0x20,0x25,0x30,0x32
	.DB  0x64,0x20,0x0,0x4C,0x6F,0x73,0x74,0x20
	.DB  0x20,0x20,0x0,0x4B,0x61,0x6E,0x61,0x6E
	.DB  0x20,0x20,0x0,0x4B,0x69,0x72,0x69,0x20
	.DB  0x20,0x20,0x0,0x4C,0x6F,0x73,0x74,0x31
	.DB  0x20,0x20,0x0,0x53,0x74,0x6F,0x70,0x20
	.DB  0x20,0x20,0x0,0x43,0x6F,0x75,0x6E,0x74
	.DB  0x32,0x20,0x25,0x30,0x32,0x64,0x20,0x0
	.DB  0x52,0x6F,0x74,0x61,0x74,0x65,0x25,0x30
	.DB  0x32,0x64,0x20,0x3D,0x25,0x30,0x33,0x64
	.DB  0x20,0x20,0x20,0x20,0x0,0x53,0x70,0x65
	.DB  0x65,0x64,0x31,0x20,0x25,0x30,0x32,0x64
	.DB  0x20,0x3D,0x25,0x30,0x33,0x64,0x20,0x20
	.DB  0x20,0x20,0x0,0x53,0x70,0x65,0x65,0x64
	.DB  0x32,0x20,0x25,0x30,0x32,0x64,0x20,0x3D
	.DB  0x25,0x30,0x33,0x64,0x20,0x20,0x20,0x20
	.DB  0x0,0x43,0x70,0x25,0x30,0x32,0x64,0x20
	.DB  0x54,0x69,0x6D,0x65,0x3D,0x25,0x30,0x33
	.DB  0x64,0x20,0x20,0x20,0x20,0x0,0x43,0x70
	.DB  0x25,0x30,0x32,0x64,0x20,0x52,0x65,0x61
	.DB  0x64,0x3D,0x25,0x30,0x33,0x64,0x20,0x20
	.DB  0x20,0x20,0x0,0x53,0x65,0x6E,0x73,0x6F
	.DB  0x72,0x25,0x64,0x20,0x2D,0x3E,0x25,0x64
	.DB  0x20,0x20,0x20,0x20,0x20,0x0,0x43,0x65
	.DB  0x6B,0x20,0x50,0x6F,0x69,0x6E,0x74,0x5B
	.DB  0x25,0x30,0x32,0x64,0x5D,0x20,0x20,0x20
	.DB  0x20,0x20,0x20,0x0,0x31,0x2E,0x43,0x61
	.DB  0x6C,0x69,0x62,0x72,0x61,0x74,0x69,0x6F
	.DB  0x6E,0x20,0x25,0x64,0x20,0x0,0x32,0x2E
	.DB  0x53,0x70,0x65,0x65,0x64,0x3D,0x25,0x64
	.DB  0x20,0x20,0x20,0x0,0x33,0x2E,0x4B,0x65
	.DB  0x63,0x2E,0x42,0x65,0x6C,0x6F,0x6B,0x3D
	.DB  0x25,0x64,0x20,0x20,0x20,0x0,0x34,0x2E
	.DB  0x0,0x35,0x2E,0x50,0x49,0x44,0x20,0x0
	.DB  0x36,0x2E,0x53,0x74,0x72,0x61,0x74,0x65
	.DB  0x67,0x69,0x0,0x5B,0x36,0x2E,0x53,0x74
	.DB  0x72,0x61,0x74,0x65,0x67,0x69,0x5D,0x0
	.DB  0x31,0x2E,0x53,0x70,0x65,0x65,0x64,0x20
	.DB  0x53,0x74,0x72,0x61,0x3D,0x25,0x64,0x20
	.DB  0x20,0x20,0x0,0x32,0x2E,0x53,0x74,0x61
	.DB  0x72,0x74,0x20,0x41,0x0,0x33,0x2E,0x53
	.DB  0x74,0x61,0x72,0x74,0x20,0x42,0x0,0x34
	.DB  0x2E,0x53,0x74,0x61,0x72,0x74,0x20,0x43
	.DB  0x0,0x35,0x2E,0x53,0x74,0x61,0x72,0x74
	.DB  0x20,0x44,0x0,0x37,0x2E,0x0,0x38,0x2E
	.DB  0x54,0x69,0x6D,0x65,0x72,0x20,0x20,0x20
	.DB  0x20,0x20,0x20,0x0,0x39,0x2E,0x53,0x70
	.DB  0x65,0x65,0x64,0x31,0x20,0x43,0x6F,0x75
	.DB  0x6E,0x74,0x20,0x20,0x20,0x20,0x20,0x0
	.DB  0x31,0x30,0x2E,0x53,0x70,0x65,0x65,0x64
	.DB  0x32,0x20,0x43,0x6F,0x75,0x6E,0x74,0x20
	.DB  0x20,0x20,0x20,0x20,0x0,0x31,0x31,0x2E
	.DB  0x44,0x65,0x6C,0x61,0x79,0x20,0x20,0x20
	.DB  0x20,0x20,0x20,0x20,0x0,0x31,0x31,0x2E
	.DB  0x50,0x6C,0x61,0x6E,0x20,0x54,0x69,0x6D
	.DB  0x65,0x72,0x20,0x20,0x20,0x20,0x0,0x31
	.DB  0x32,0x2E,0x41,0x74,0x75,0x72,0x20,0x43
	.DB  0x50,0x0,0x31,0x33,0x2E,0x5B,0x43,0x6F
	.DB  0x75,0x6E,0x74,0x65,0x72,0x5D,0x20,0x4E
	.DB  0x6F,0x72,0x6D,0x61,0x6C,0x20,0x0,0x31
	.DB  0x33,0x2E,0x4A,0x61,0x6C,0x61,0x6E,0x20
	.DB  0x41,0x6A,0x61,0x0,0x31,0x34,0x2E,0x43
	.DB  0x6F,0x75,0x6E,0x74,0x65,0x72,0x20,0x32
	.DB  0x20,0x0,0x31,0x34,0x2E,0x43,0x6F,0x75
	.DB  0x6E,0x74,0x65,0x72,0x20,0x31,0x20,0x0
	.DB  0x31,0x35,0x2E,0x53,0x6D,0x6F,0x6F,0x74
	.DB  0x68,0x69,0x6E,0x67,0x3D,0x25,0x64,0x20
	.DB  0x20,0x20,0x0,0x31,0x36,0x2E,0x43,0x65
	.DB  0x6B,0x20,0x53,0x65,0x6E,0x73,0x6F,0x72
	.DB  0x0,0x31,0x37,0x2E,0x52,0x65,0x6D,0x20
	.DB  0x3D,0x25,0x64,0x20,0x20,0x20,0x0,0x31
	.DB  0x38,0x2E,0x57,0x68,0x69,0x74,0x65,0x20
	.DB  0x4C,0x69,0x6E,0x65,0x20,0x0,0x31,0x38
	.DB  0x2E,0x42,0x6C,0x61,0x63,0x6B,0x20,0x4C
	.DB  0x69,0x6E,0x65,0x20,0x0,0x31,0x38,0x2E
	.DB  0x41,0x75,0x74,0x6F,0x20,0x4C,0x69,0x6E
	.DB  0x65,0x20,0x20,0x0,0x54,0x49,0x4D,0x45
	.DB  0x52,0x3A,0x25,0x64,0x20,0x43,0x4F,0x55
	.DB  0x4E,0x54,0x3A,0x25,0x64,0x0,0x25,0x30
	.DB  0x33,0x64,0x3C,0x25,0x30,0x32,0x64,0x3E
	.DB  0x25,0x30,0x33,0x64,0x20,0x25,0x30,0x33
	.DB  0x64,0x20,0x20,0x20,0x0,0x25,0x30,0x33
	.DB  0x64,0x20,0x3C,0x25,0x30,0x32,0x64,0x3E
	.DB  0x20,0x25,0x30,0x33,0x64,0x20,0x25,0x30
	.DB  0x33,0x64,0x20,0x20,0x20,0x0,0x2E,0x53
	.DB  0x74,0x61,0x72,0x74,0x3D,0x41,0x0,0x20
	.DB  0x43,0x50,0x3D,0x31,0x0,0x2E,0x53,0x74
	.DB  0x61,0x72,0x74,0x3D,0x42,0x0,0x2E,0x53
	.DB  0x74,0x61,0x72,0x74,0x3D,0x43,0x0,0x2E
	.DB  0x53,0x74,0x61,0x72,0x74,0x3D,0x44,0x0
	.DB  0x20,0x20,0x57,0x65,0x6C,0x63,0x6F,0x6D
	.DB  0x65,0x20,0x54,0x6F,0x0,0x20,0x54,0x45
	.DB  0x55,0x4D,0x20,0x43,0x4F,0x52,0x50,0x2E
	.DB  0x0,0x46,0x6F,0x72,0x6D,0x61,0x74,0x20
	.DB  0x44,0x61,0x74,0x61,0x5B,0x4E,0x5D,0x0
	.DB  0x62,0x61,0x74,0x61,0x6C,0x20,0x66,0x6F
	.DB  0x72,0x6D,0x61,0x74,0x0,0x46,0x6F,0x72
	.DB  0x6D,0x61,0x74,0x20,0x44,0x61,0x74,0x61
	.DB  0x5B,0x59,0x5D,0x0,0x50,0x72,0x6F,0x73
	.DB  0x65,0x73,0x20,0x46,0x6F,0x72,0x6D,0x61
	.DB  0x74,0x0,0x2E,0x2E,0x2E,0x2E,0x2E,0x2E
	.DB  0x2E,0x2E,0x2E,0x2E,0x2E,0x2E,0x2E,0x2E
	.DB  0x2E,0x2E,0x0,0x46,0x6F,0x72,0x6D,0x61
	.DB  0x74,0x20,0x53,0x65,0x6C,0x65,0x73,0x61
	.DB  0x69,0x21,0x0,0x20,0x53,0x74,0x61,0x72
	.DB  0x74,0x3D,0x41,0x0,0x2E,0x43,0x50,0x3D
	.DB  0x31,0x0
_0x2020003:
	.DB  0x80,0xC0

__GLOBAL_INI_TBL:
	.DW  0x01
	.DW  0x02
	.DW  __REG_BIT_VARS*2

	.DW  0x01
	.DW  _batas
	.DW  _0x3*2

	.DW  0x0D
	.DW  _0x2EB
	.DW  _0x0*2+920

	.DW  0x0C
	.DW  _0x2EB+13
	.DW  _0x0*2+933

	.DW  0x02
	.DW  __base_y_G101
	.DW  _0x2020003*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  GICR,R31
	OUT  GICR,R30
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,__SRAM_START
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x260

	.CSEG
;/*****************************************************
;Project : Line Follower Source Code Development
;Version : Pzr 2.10
;Date    : 04/01/2016
;Author  : Tim Robot UM
;Company : RDF Corporations
;Comments: Source code development for LF-UM team, Gunakan secara bijak!
;Dengan Ketentuan Sbb:
;1. Jangan sebarkan source code ini kepada selain anggota team LF-UM.
;2. Anggota yang sudah mendapatkan source code ini harus benar-benar bersedia
;   untuk loyal terhadap team dan mampu memberikan kontribusi terhadap pengembangan
;   LF-UM.
;3. Melanggar ketentuan dosa lho rek.
;
;Chip type               : ATmega32
;Program type            : Application
;AVR Core Clock frequency: 16.000000 MHz
;Memory model            : Small
;External RAM size       : 0
;Data Stack size         : 512
;*****************************************************/
;
;#include <mega32.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
;#include <delay.h>
;#include <stdio.h>
;#include <alcd.h>
;#define ADC_VREF_TYPE 0x20
;#define s1              PINC.0 //kanan1
;#define s2              PINC.2 //kiri2
;#define s3              PINC.3 //kiri1
;#define s4              PINC.4 //bawah
;#define s5              PINC.1 //kanan2
;#define s6              PINC.5 //atas
;#define led             PORTD.7
;#define R               PORTC.6
;#define L               PORTC.7
;#define lmp             PORTB.3
;#define kiju            OCR1B
;#define kidur           PORTD.3
;#define kadur           PORTD.6
;#define kaju            OCR1A
;#define input           PIND.0
;#define output          PORTD.1
;
;eeprom unsigned char esensitive[14];
;eeprom unsigned char espeed[101];
;eeprom unsigned char espeed1[101];
;eeprom unsigned char etimer[101];
;eeprom unsigned char eplan[21];
;eeprom unsigned char eread[21];
;eeprom unsigned char ecut[101];
;eeprom unsigned char ecut1[101];
;eeprom unsigned char edel[101];
;eeprom unsigned char eencomp=0;
;eeprom unsigned char emode=0;
;eeprom unsigned char emodekanan=0;
;eeprom unsigned char epulsa=5;
;eeprom unsigned char ekp=10;
;eeprom unsigned char ekd=100;
;eeprom unsigned char eki=0;
;eeprom unsigned char elc=120;
;eeprom unsigned char elc1=0;
;eeprom unsigned char evc=120;
;eeprom unsigned char emax1=100;
;
;bit aktif=0,lock;
;int rpwm,lpwm,max1,m,lc,vc,I,PV,error,lasterror,encomp,lc1,xcc;
;unsigned char kp,kd,ki,pulsa,batas=100;

	.DSEG
;unsigned char timer[101],speed[101],speed1[101],count2,start,time[101],cacah,cc,plan[21],read[21];
;unsigned char SP=0,mode,cut[101],cut1[101],counting,protec,del[101],tunda,modekanan;
;unsigned char sensitive[14],in,adc,sam,samping,sam1,samping1,hight[14],low[14],scan,inv,invers;
;unsigned int dep,depan,sen,sm;
;int pass;
;char buff[33],bufff[33];
;int pilih_start=0;
;int pilih_cp=0;
;
;void loading(){
; 0000 004E void loading(){

	.CSEG
_loading:
; 0000 004F int load;
; 0000 0050 for(load=0;load<=15;load++){
	CALL SUBOPT_0x0
;	load -> R16,R17
_0x5:
	__CPWRN 16,17,16
	BRGE _0x6
; 0000 0051 lcd_gotoxy(load,1);
	ST   -Y,R16
	CALL SUBOPT_0x1
; 0000 0052 lcd_putchar(0x5f);delay_ms(80);
	CALL SUBOPT_0x2
	CALL SUBOPT_0x3
; 0000 0053 lcd_putchar(0xff);delay_ms(80);
	CALL SUBOPT_0x4
	CALL SUBOPT_0x3
; 0000 0054 }
	__ADDWRN 16,17,1
	RJMP _0x5
_0x6:
; 0000 0055 lcd_clear();
	CALL _lcd_clear
; 0000 0056 }
	RJMP _0x2080006
;
;void saved(){
; 0000 0058 void saved(){
_saved:
; 0000 0059  lcd_clear();
	CALL SUBOPT_0x5
; 0000 005A  lcd_gotoxy(0,0);
; 0000 005B  lcd_putsf("DONE SAVE!");delay_ms(300);
	__POINTW1FN _0x0,0
	CALL SUBOPT_0x6
	CALL SUBOPT_0x7
; 0000 005C  lmp=1;
	SBI  0x18,3
; 0000 005D  lcd_clear();
	CALL _lcd_clear
; 0000 005E }
	RET
;
;//-------------timer0 interrupt overflow--------//
;interrupt [TIM0_OVF] void timer0_ovf_isr(void)
; 0000 0062 {
_timer0_ovf_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0063 if(aktif==0&&cacah<timer[start]&&mode==1){
	LDI  R26,0
	SBRC R2,0
	LDI  R26,1
	CPI  R26,LOW(0x0)
	BRNE _0xA
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_timer)
	SBCI R31,HIGH(-_timer)
	LD   R30,Z
	LDS  R26,_cacah
	CP   R26,R30
	BRSH _0xA
	LDS  R26,_mode
	CPI  R26,LOW(0x1)
	BREQ _0xB
_0xA:
	RJMP _0x9
_0xB:
; 0000 0064 if(++cc>=pulsa){
	LDS  R26,_cc
	SUBI R26,-LOW(1)
	STS  _cc,R26
	LDS  R30,_pulsa
	CP   R26,R30
	BRLO _0xC
; 0000 0065 cacah++;cc=0;}
	LDS  R30,_cacah
	SUBI R30,-LOW(1)
	STS  _cacah,R30
	LDI  R30,LOW(0)
	STS  _cc,R30
; 0000 0066 }
_0xC:
; 0000 0067 }
_0x9:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
;
;void rumus_pid()
; 0000 006A {
_rumus_pid:
; 0000 006B if (error!=0){I=I+error;}
	CALL SUBOPT_0x9
	SBIW R30,0
	BREQ _0xD
	CALL SUBOPT_0x9
	CALL SUBOPT_0xA
	ADD  R30,R26
	ADC  R31,R27
	STS  _I,R30
	STS  _I+1,R31
; 0000 006C else{I=0;}
	RJMP _0xE
_0xD:
	LDI  R30,LOW(0)
	STS  _I,R30
	STS  _I+1,R30
_0xE:
; 0000 006D rpwm=(int)((max1+(error*kp))+((error-lasterror)*kd)+((ki*I)/35)); //dibalik
	CALL SUBOPT_0xB
	CALL SUBOPT_0xC
	CALL SUBOPT_0xD
	__ADDWRR 22,23,30,31
	CALL SUBOPT_0xE
	ADD  R30,R22
	ADC  R31,R23
	MOVW R4,R30
; 0000 006E lpwm=(int)((max1+(-error*kp))-((error-lasterror)*kd)-((ki*I)/35)); //dibalik
	CALL SUBOPT_0x9
	CALL __ANEGW1
	MOVW R26,R30
	CALL SUBOPT_0xB
	CALL SUBOPT_0xD
	__SUBWRR 22,23,30,31
	CALL SUBOPT_0xE
	MOVW R26,R22
	SUB  R26,R30
	SBC  R27,R31
	MOVW R6,R26
; 0000 006F //sudah saya balik
; 0000 0070 lasterror=error;
	CALL SUBOPT_0x9
	STS  _lasterror,R30
	STS  _lasterror+1,R31
; 0000 0071 }
	RET
;//-------------global fungsi--------//
;void scansensor();
;//-------------fungsi pembacaan adc--------//
;unsigned char read_adc(unsigned char adc_input)
; 0000 0076 {
_read_adc:
; 0000 0077 ADMUX=ADC_VREF_TYPE & 0xff;
;	adc_input -> Y+0
	LDI  R30,LOW(32)
	OUT  0x7,R30
; 0000 0078 ADMUX=adc_input | (ADC_VREF_TYPE & 0xff);
	LD   R30,Y
	ORI  R30,0x20
	OUT  0x7,R30
; 0000 0079 delay_us(10);
	__DELAY_USB 53
; 0000 007A ADCSRA|=0x40;
	SBI  0x6,6
; 0000 007B while ((ADCSRA & 0x10)==0);
_0xF:
	SBIS 0x6,4
	RJMP _0xF
; 0000 007C ADCSRA|=0x10;
	SBI  0x6,4
; 0000 007D return ADCH;
	IN   R30,0x5
	ADIW R28,1
	RET
; 0000 007E }
;
;//-------------fungsi motor controller--------//
;void motor(int pwmkiri,int pwmkanan){
; 0000 0081 void motor(int pwmkiri,int pwmkanan){
_motor:
; 0000 0082 if (pwmkiri>255)pwmkiri=255;
;	pwmkiri -> Y+2
;	pwmkanan -> Y+0
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CPI  R26,LOW(0x100)
	LDI  R30,HIGH(0x100)
	CPC  R27,R30
	BRLT _0x12
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0083  if (pwmkiri<-255)pwmkiri=(-255);
_0x12:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CPI  R26,LOW(0xFF01)
	LDI  R30,HIGH(0xFF01)
	CPC  R27,R30
	BRGE _0x13
	LDI  R30,LOW(65281)
	LDI  R31,HIGH(65281)
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0084  if (pwmkanan>255)pwmkanan=255;
_0x13:
	LD   R26,Y
	LDD  R27,Y+1
	CPI  R26,LOW(0x100)
	LDI  R30,HIGH(0x100)
	CPC  R27,R30
	BRLT _0x14
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	ST   Y,R30
	STD  Y+1,R31
; 0000 0085  if (pwmkanan<-255)pwmkanan=(-255);
_0x14:
	LD   R26,Y
	LDD  R27,Y+1
	CPI  R26,LOW(0xFF01)
	LDI  R30,HIGH(0xFF01)
	CPC  R27,R30
	BRGE _0x15
	LDI  R30,LOW(65281)
	LDI  R31,HIGH(65281)
	ST   Y,R30
	STD  Y+1,R31
; 0000 0086 
; 0000 0087  if (lpwm>255)lpwm=255;
_0x15:
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	CP   R30,R6
	CPC  R31,R7
	BRGE _0x16
	MOVW R6,R30
; 0000 0088  if (lpwm<-255)lpwm=(-255);
_0x16:
	LDI  R30,LOW(65281)
	LDI  R31,HIGH(65281)
	CP   R6,R30
	CPC  R7,R31
	BRGE _0x17
	MOVW R6,R30
; 0000 0089  if (rpwm>255)rpwm=255;
_0x17:
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	CP   R30,R4
	CPC  R31,R5
	BRGE _0x18
	MOVW R4,R30
; 0000 008A  if (rpwm<-255)rpwm=(-255);
_0x18:
	LDI  R30,LOW(65281)
	LDI  R31,HIGH(65281)
	CP   R4,R30
	CPC  R5,R31
	BRGE _0x19
	MOVW R4,R30
; 0000 008B  if (pwmkanan<0){
_0x19:
	LDD  R26,Y+1
	TST  R26
	BRPL _0x1A
; 0000 008C  kadur=1;
	SBI  0x12,6
; 0000 008D  kaju=255+pwmkanan;
	LD   R30,Y
	LDD  R31,Y+1
	SUBI R30,LOW(-255)
	SBCI R31,HIGH(-255)
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 008E  }
; 0000 008F  if (pwmkiri<0){
_0x1A:
	LDD  R26,Y+3
	TST  R26
	BRPL _0x1D
; 0000 0090  kidur=1;
	SBI  0x12,3
; 0000 0091  kiju=255+pwmkiri;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	SUBI R30,LOW(-255)
	SBCI R31,HIGH(-255)
	OUT  0x28+1,R31
	OUT  0x28,R30
; 0000 0092  }
; 0000 0093  if (pwmkanan>=0){
_0x1D:
	LDD  R26,Y+1
	TST  R26
	BRMI _0x20
; 0000 0094  kadur=0;
	CBI  0x12,6
; 0000 0095  kaju=pwmkanan;
	LD   R30,Y
	LDD  R31,Y+1
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 0096  }
; 0000 0097  if (pwmkiri>=0){
_0x20:
	LDD  R26,Y+3
	TST  R26
	BRMI _0x23
; 0000 0098  kidur=0;
	CBI  0x12,3
; 0000 0099  kiju=pwmkiri;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	OUT  0x28+1,R31
	OUT  0x28,R30
; 0000 009A  }
; 0000 009B }
_0x23:
	RJMP _0x2080009
;
;//-------------fungsi enable pwm internal--------//
;void pwm_on()
; 0000 009F {
_pwm_on:
; 0000 00A0 TCCR1A=0xA1;
	LDI  R30,LOW(161)
	OUT  0x2F,R30
; 0000 00A1 TCCR1B=0x0B;
	LDI  R30,LOW(11)
	RJMP _0x208000B
; 0000 00A2 }
;
;//-------------fungsi disable pwm internal--------//
;void pwm_off()
; 0000 00A6 {
_pwm_off:
; 0000 00A7 TCCR1A=0x00;
	LDI  R30,LOW(0)
	OUT  0x2F,R30
; 0000 00A8 TCCR1B=0x00;
_0x208000B:
	OUT  0x2E,R30
; 0000 00A9 }
	RET
;
;//-------------fungsi stop motor--------//
;void stop(){
; 0000 00AC void stop(){
_stop:
; 0000 00AD   motor(0,0);}
	CALL SUBOPT_0xF
	RJMP _0x208000A
;
;//-------------fungsi mundur motor--------//
;void mundur(){
; 0000 00B0 void mundur(){
_mundur:
; 0000 00B1 motor(-255,-255);}
	LDI  R30,LOW(65281)
	LDI  R31,HIGH(65281)
	ST   -Y,R31
	ST   -Y,R30
_0x208000A:
	ST   -Y,R31
	ST   -Y,R30
	RCALL _motor
	RET
;
;//-------------fungsi belok kanan lancip--------//
;void kananlancip()
; 0000 00B5 {int cp1,cp2;
_kananlancip:
; 0000 00B6         cp1=(255-lc)+(-255);  cp2=0+lc;
	CALL SUBOPT_0x10
;	cp1 -> R16,R17
;	cp2 -> R18,R19
; 0000 00B7         motor(cp2,cp1);
	ST   -Y,R19
	ST   -Y,R18
	ST   -Y,R17
	ST   -Y,R16
	RCALL _motor
; 0000 00B8 }
	RJMP _0x2080008
;
;//-------------fungsi belok kiri lancip--------//
;void kirilancip()
; 0000 00BC {       int cp1,cp2;
_kirilancip:
; 0000 00BD         cp1=(255-lc)+(-255);  cp2=0+lc;
	CALL SUBOPT_0x10
;	cp1 -> R16,R17
;	cp2 -> R18,R19
; 0000 00BE         motor(cp1,cp2);
	ST   -Y,R17
	ST   -Y,R16
	ST   -Y,R19
	ST   -Y,R18
	RCALL _motor
; 0000 00BF }
	RJMP _0x2080008
;
;//-------------fungsi belok kanan counter--------//
;void kanan()
; 0000 00C3 {
_kanan:
; 0000 00C4         int cp1,cp2;
; 0000 00C5         lmp=1;
	CALL __SAVELOCR4
;	cp1 -> R16,R17
;	cp2 -> R18,R19
	SBI  0x18,3
; 0000 00C6         tunda=del[start];
	CALL SUBOPT_0x8
	CALL SUBOPT_0x11
; 0000 00C7         cp1=(255-vc)+(-255);  cp2=0+lc;
; 0000 00C8         motor(cp2,cp1);
	ST   -Y,R19
	ST   -Y,R18
	ST   -Y,R17
	ST   -Y,R16
	RJMP _0x2080007
; 0000 00C9         delay_ms(tunda);
; 0000 00CA }
;
;//-------------fungsi belok kiri counter--------//
;void kiri()
; 0000 00CE {
_kiri:
; 0000 00CF         int cp1,cp2;
; 0000 00D0         lmp=1;
	CALL __SAVELOCR4
;	cp1 -> R16,R17
;	cp2 -> R18,R19
	SBI  0x18,3
; 0000 00D1         tunda=del[start];
	CALL SUBOPT_0x8
	CALL SUBOPT_0x11
; 0000 00D2         cp1=(255-vc)+(-255);  cp2=0+lc;
; 0000 00D3         motor(cp1,cp2);
	ST   -Y,R17
	ST   -Y,R16
	ST   -Y,R19
	ST   -Y,R18
_0x2080007:
	RCALL _motor
; 0000 00D4         delay_ms(tunda);
	CALL SUBOPT_0x12
; 0000 00D5 }
_0x2080008:
	CALL __LOADLOCR4
_0x2080009:
	ADIW R28,4
	RET
;
;//-------------fungsi kalibrasi sensor--------//
;void autoscan()
; 0000 00D9 {
_autoscan:
; 0000 00DA int a,b;
; 0000 00DB unsigned char mata;
; 0000 00DC if(m==1){pwm_on();}
	CALL __SAVELOCR6
;	a -> R16,R17
;	b -> R18,R19
;	mata -> R21
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CP   R30,R10
	CPC  R31,R11
	BRNE _0x2A
	RCALL _pwm_on
; 0000 00DD lcd_clear();
_0x2A:
	CALL SUBOPT_0x5
; 0000 00DE lcd_gotoxy(0,0);
; 0000 00DF lcd_putsf("     READY TO     ");
	__POINTW1FN _0x0,11
	CALL SUBOPT_0x6
; 0000 00E0 lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 00E1 lcd_putsf("   CALIBRATION  ");
	__POINTW1FN _0x0,30
	CALL SUBOPT_0x6
; 0000 00E2 delay_ms(500);
	CALL SUBOPT_0x14
; 0000 00E3 lcd_clear();
	CALL _lcd_clear
; 0000 00E4 for(a=0;a<=6;a++){
	__GETWRN 16,17,0
_0x2C:
	__CPWRN 16,17,7
	BRGE _0x2D
; 0000 00E5         sensitive[a]=0;
	LDI  R26,LOW(_sensitive)
	LDI  R27,HIGH(_sensitive)
	ADD  R26,R16
	ADC  R27,R17
	LDI  R30,LOW(0)
	ST   X,R30
; 0000 00E6         low[a]=255;
	LDI  R26,LOW(_low)
	LDI  R27,HIGH(_low)
	ADD  R26,R16
	ADC  R27,R17
	LDI  R30,LOW(255)
	ST   X,R30
; 0000 00E7         hight[a]=0;
	LDI  R26,LOW(_hight)
	LDI  R27,HIGH(_hight)
	ADD  R26,R16
	ADC  R27,R17
	LDI  R30,LOW(0)
	ST   X,R30
; 0000 00E8         }
	__ADDWRN 16,17,1
	RJMP _0x2C
_0x2D:
; 0000 00E9 for(a=0;a<1000;a++){
	__GETWRN 16,17,0
_0x2F:
	__CPWRN 16,17,1000
	BRLT PC+3
	JMP _0x30
; 0000 00EA if(m==1){
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CP   R30,R10
	CPC  R31,R11
	BRNE _0x31
; 0000 00EB motor(-128,128);
	LDI  R30,LOW(65408)
	LDI  R31,HIGH(65408)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _motor
; 0000 00EC }
; 0000 00ED if(m==0){stop();
_0x31:
	MOV  R0,R10
	OR   R0,R11
	BRNE _0x32
	RCALL _stop
; 0000 00EE }
; 0000 00EF lcd_gotoxy(0,0);
_0x32:
	CALL SUBOPT_0x15
; 0000 00F0 lcd_putsf("Scaning sensor");
	__POINTW1FN _0x0,47
	CALL SUBOPT_0x6
; 0000 00F1 lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 00F2 sprintf(buff, "[ %d ][%i]",mata,a);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,62
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R21
	CALL SUBOPT_0x17
	CALL SUBOPT_0x18
	CALL SUBOPT_0x19
; 0000 00F3 lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 00F4 L=1;
	SBI  0x15,7
; 0000 00F5 R=0;
	CBI  0x15,6
; 0000 00F6 for(b=0;b<=6;b++){
	__GETWRN 18,19,0
_0x38:
	__CPWRN 18,19,7
	BRGE _0x39
; 0000 00F7 mata=read_adc(b+1);
	MOV  R30,R18
	SUBI R30,-LOW(1)
	CALL SUBOPT_0x1A
; 0000 00F8 if(mata<low[b]){
	BRSH _0x3A
; 0000 00F9 low[b]=mata;
	MOVW R30,R18
	SUBI R30,LOW(-_low)
	SBCI R31,HIGH(-_low)
	ST   Z,R21
; 0000 00FA }
; 0000 00FB if(mata>hight[b]){
_0x3A:
	CALL SUBOPT_0x1B
	BRSH _0x3B
; 0000 00FC hight[b]=mata;
	MOVW R30,R18
	SUBI R30,LOW(-_hight)
	SBCI R31,HIGH(-_hight)
	ST   Z,R21
; 0000 00FD }
; 0000 00FE delay_us(200);
_0x3B:
	__DELAY_USW 800
; 0000 00FF }
	__ADDWRN 18,19,1
	RJMP _0x38
_0x39:
; 0000 0100 L=0;
	CBI  0x15,7
; 0000 0101 R=1;
	SBI  0x15,6
; 0000 0102 for(b=7;b<=13;b++){
	__GETWRN 18,19,7
_0x41:
	__CPWRN 18,19,14
	BRGE _0x42
; 0000 0103 mata=read_adc(b-6);
	MOVW R30,R18
	SBIW R30,6
	CALL SUBOPT_0x1A
; 0000 0104 if(mata<low[b]){
	BRSH _0x43
; 0000 0105 low[b]=mata;
	MOVW R30,R18
	SUBI R30,LOW(-_low)
	SBCI R31,HIGH(-_low)
	ST   Z,R21
; 0000 0106 }
; 0000 0107 if(mata>hight[b]){
_0x43:
	CALL SUBOPT_0x1B
	BRSH _0x44
; 0000 0108 hight[b]=mata;
	MOVW R30,R18
	SUBI R30,LOW(-_hight)
	SBCI R31,HIGH(-_hight)
	ST   Z,R21
; 0000 0109 }
; 0000 010A delay_us(200);
_0x44:
	__DELAY_USW 800
; 0000 010B }
	__ADDWRN 18,19,1
	RJMP _0x41
_0x42:
; 0000 010C L=0; R=0;
	CBI  0x15,7
	CBI  0x15,6
; 0000 010D }
	__ADDWRN 16,17,1
	RJMP _0x2F
_0x30:
; 0000 010E for(b=0;b<13;b++){
	__GETWRN 18,19,0
_0x4A:
	__CPWRN 18,19,13
	BRGE _0x4B
; 0000 010F sensitive[b]=((hight[b]-low[b])/2)+low[b];
	MOVW R30,R18
	SUBI R30,LOW(-_sensitive)
	SBCI R31,HIGH(-_sensitive)
	MOVW R22,R30
	LDI  R26,LOW(_hight)
	LDI  R27,HIGH(_hight)
	ADD  R26,R18
	ADC  R27,R19
	LD   R0,X
	CLR  R1
	LDI  R26,LOW(_low)
	LDI  R27,HIGH(_low)
	ADD  R26,R18
	ADC  R27,R19
	CALL SUBOPT_0x1C
	MOVW R26,R0
	SUB  R26,R30
	SBC  R27,R31
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL __DIVW21
	MOV  R0,R30
	LDI  R26,LOW(_low)
	LDI  R27,HIGH(_low)
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	ADD  R30,R0
	MOVW R26,R22
	ST   X,R30
; 0000 0110 };
	__ADDWRN 18,19,1
	RJMP _0x4A
_0x4B:
; 0000 0111 lcd_clear();
	CALL SUBOPT_0x5
; 0000 0112 lcd_gotoxy(0,0);
; 0000 0113 pwm_off();
	CALL SUBOPT_0x1D
; 0000 0114 stop();
; 0000 0115 lmp=1;
	SBI  0x18,3
; 0000 0116 lcd_putsf("SAVE DATA...");
	__POINTW1FN _0x0,73
	CALL SUBOPT_0x6
; 0000 0117 delay_ms(300);
	CALL SUBOPT_0x7
; 0000 0118 for(b=0;b<13;b++){
	__GETWRN 18,19,0
_0x4F:
	__CPWRN 18,19,13
	BRGE _0x50
; 0000 0119 esensitive[b]=sensitive[b];
	MOVW R30,R18
	SUBI R30,LOW(-_esensitive)
	SBCI R31,HIGH(-_esensitive)
	MOVW R0,R30
	LDI  R26,LOW(_sensitive)
	LDI  R27,HIGH(_sensitive)
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	MOVW R26,R0
	CALL __EEPROMWRB
; 0000 011A }
	__ADDWRN 18,19,1
	RJMP _0x4F
_0x50:
; 0000 011B loading();
	RCALL _loading
; 0000 011C lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 011D lcd_putsf("DONE!");
	__POINTW1FN _0x0,86
	CALL SUBOPT_0x6
; 0000 011E delay_ms(300);lmp=1;
	CALL SUBOPT_0x7
	SBI  0x18,3
; 0000 011F lcd_clear();
	CALL _lcd_clear
; 0000 0120 }
	CALL __LOADLOCR6
	ADIW R28,6
	RET
;
;//-------------fungsi seting PID--------//
;void pid()
; 0000 0124 {
_pid:
; 0000 0125 int i;
; 0000 0126 i=0;
	CALL SUBOPT_0x0
;	i -> R16,R17
; 0000 0127 while(1){
_0x53:
; 0000 0128 if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0x57
	SBIS 0x13,2
	RJMP _0x57
	SBIS 0x13,3
	RJMP _0x57
	SBIS 0x13,4
	RJMP _0x57
	SBIC 0x13,1
	RJMP _0x56
_0x57:
	CBI  0x12,7
; 0000 0129 else{led=1;}
	RJMP _0x5B
_0x56:
	SBI  0x12,7
_0x5B:
; 0000 012A lmp=1;
	SBI  0x18,3
; 0000 012B if (!s5){i=i-1;}
	SBIC 0x13,1
	RJMP _0x60
	__SUBWRN 16,17,1
; 0000 012C if (i==(-1)){i=2;}
_0x60:
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x61
	__GETWRN 16,17,2
; 0000 012D if (!s1){i=i+1;}
_0x61:
	SBIC 0x13,0
	RJMP _0x62
	__ADDWRN 16,17,1
; 0000 012E if (i==3){i=0;}
_0x62:
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x63
	__GETWRN 16,17,0
; 0000 012F                 if(i==0){
_0x63:
	MOV  R0,R16
	OR   R0,R17
	BRNE _0x64
; 0000 0130                         lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0131                         lcd_putsf("Proporsional     ");
	__POINTW1FN _0x0,92
	CALL SUBOPT_0x6
; 0000 0132                         sprintf(buff,"Kp=%03d ", kp);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,110
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_kp
	CALL SUBOPT_0x17
	CALL SUBOPT_0x1E
; 0000 0133                         lcd_gotoxy(0,1);
; 0000 0134                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0135                         if(!s2){kp=kp+1;if (kp>255){kp=0;}}
	SBIC 0x13,2
	RJMP _0x65
	LDS  R30,_kp
	SUBI R30,-LOW(1)
	STS  _kp,R30
	LDS  R26,_kp
	LDI  R30,LOW(255)
	CP   R30,R26
	BRSH _0x66
	LDI  R30,LOW(0)
	STS  _kp,R30
_0x66:
; 0000 0136                         if(!s3){kp=kp-1;if (kp<0){kp=255;}}
_0x65:
	SBIC 0x13,3
	RJMP _0x67
	CALL SUBOPT_0xB
	SBIW R30,1
	STS  _kp,R30
	LDS  R26,_kp
; 0000 0137                         }
_0x67:
; 0000 0138                 if(i==1){
_0x64:
	CALL SUBOPT_0x1F
	BRNE _0x69
; 0000 0139                         lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 013A                         lcd_putsf("Integratif ");
	__POINTW1FN _0x0,119
	CALL SUBOPT_0x6
; 0000 013B                         sprintf(buff,"Ki=%03d ", ki);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,131
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_ki
	CALL SUBOPT_0x17
	CALL SUBOPT_0x1E
; 0000 013C                         lcd_gotoxy(0,1);
; 0000 013D                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 013E                         if(!s2){ki=ki+1;if(ki>255){ki=0;}}
	SBIC 0x13,2
	RJMP _0x6A
	LDS  R30,_ki
	SUBI R30,-LOW(1)
	STS  _ki,R30
	LDS  R26,_ki
	LDI  R30,LOW(255)
	CP   R30,R26
	BRSH _0x6B
	LDI  R30,LOW(0)
	STS  _ki,R30
_0x6B:
; 0000 013F                         if(!s3){ ki=ki-1;if (ki<0){ki=255;}}
_0x6A:
	SBIC 0x13,3
	RJMP _0x6C
	LDS  R30,_ki
	CALL SUBOPT_0x20
	STS  _ki,R30
	LDS  R26,_ki
; 0000 0140                         }
_0x6C:
; 0000 0141                 if(i==2){
_0x69:
	CALL SUBOPT_0x21
	BRNE _0x6E
; 0000 0142                         lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0143                         lcd_putsf("Derevatif    ");
	__POINTW1FN _0x0,140
	CALL SUBOPT_0x6
; 0000 0144                         sprintf(buff,"Kd=%03d ", kd);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,154
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_kd
	CALL SUBOPT_0x17
	CALL SUBOPT_0x1E
; 0000 0145                         lcd_gotoxy(0,1);
; 0000 0146                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0147                         if(!s2){
	SBIC 0x13,2
	RJMP _0x6F
; 0000 0148                         kd=kd+1;if (kd>255){kd=0;}}
	LDS  R30,_kd
	SUBI R30,-LOW(1)
	STS  _kd,R30
	LDS  R26,_kd
	LDI  R30,LOW(255)
	CP   R30,R26
	BRSH _0x70
	LDI  R30,LOW(0)
	STS  _kd,R30
_0x70:
; 0000 0149                         if(!s3){kd=kd-1;if (kd<0){kd=255;}}
_0x6F:
	SBIC 0x13,3
	RJMP _0x71
	LDS  R30,_kd
	CALL SUBOPT_0x20
	STS  _kd,R30
	LDS  R26,_kd
; 0000 014A                         }
_0x71:
; 0000 014B                 if(!s4){
_0x6E:
	SBIC 0x13,4
	RJMP _0x73
; 0000 014C                 if(kp!=ekp){ekp=kp;}
	LDI  R26,LOW(_ekp)
	LDI  R27,HIGH(_ekp)
	CALL __EEPROMRDB
	LDS  R26,_kp
	CP   R30,R26
	BREQ _0x74
	LDS  R30,_kp
	LDI  R26,LOW(_ekp)
	LDI  R27,HIGH(_ekp)
	CALL __EEPROMWRB
; 0000 014D                 if(ki!=eki){eki=ki;}
_0x74:
	LDI  R26,LOW(_eki)
	LDI  R27,HIGH(_eki)
	CALL __EEPROMRDB
	LDS  R26,_ki
	CP   R30,R26
	BREQ _0x75
	LDS  R30,_ki
	LDI  R26,LOW(_eki)
	LDI  R27,HIGH(_eki)
	CALL __EEPROMWRB
; 0000 014E                 if(kd!=ekd){ekd=kd;}
_0x75:
	LDI  R26,LOW(_ekd)
	LDI  R27,HIGH(_ekd)
	CALL __EEPROMRDB
	LDS  R26,_kd
	CP   R30,R26
	BREQ _0x76
	LDS  R30,_kd
	LDI  R26,LOW(_ekd)
	LDI  R27,HIGH(_ekd)
	CALL __EEPROMWRB
; 0000 014F                 saved();
_0x76:
	RCALL _saved
; 0000 0150                 break;
	RJMP _0x55
; 0000 0151                 }
; 0000 0152 delay_ms(100);
_0x73:
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL SUBOPT_0x22
; 0000 0153 }
	RJMP _0x53
_0x55:
; 0000 0154 }
	RJMP _0x2080006
;
;//-------------fungsi setting timer--------//
;void waktu()
; 0000 0158 {int x;
_waktu:
; 0000 0159 x=0;
	CALL SUBOPT_0x0
;	x -> R16,R17
; 0000 015A while(1){
_0x77:
; 0000 015B if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0x7B
	SBIS 0x13,2
	RJMP _0x7B
	SBIS 0x13,3
	RJMP _0x7B
	SBIS 0x13,4
	RJMP _0x7B
	SBIC 0x13,1
	RJMP _0x7A
_0x7B:
	CBI  0x12,7
; 0000 015C else{led=1;}
	RJMP _0x7F
_0x7A:
	SBI  0x12,7
_0x7F:
; 0000 015D lmp=1;
	CALL SUBOPT_0x23
; 0000 015E lcd_putsf("    [SETTING]");
; 0000 015F lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0160 sprintf(buff,"Timer %02d =%03d    ",x,timer[x]);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,177
	CALL SUBOPT_0x24
	LDI  R26,LOW(_timer)
	LDI  R27,HIGH(_timer)
	CALL SUBOPT_0x25
	CALL SUBOPT_0x19
; 0000 0161 lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0162 lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0163 if(!s1){if(++x>batas){x=0;}lcd_clear();}
	SBIC 0x13,0
	RJMP _0x84
	CALL SUBOPT_0x26
	BRGE _0x85
	__GETWRN 16,17,0
_0x85:
	CALL _lcd_clear
; 0000 0164 if(!s5){if(--x==-1){x=batas;}lcd_clear();}
_0x84:
	SBIC 0x13,1
	RJMP _0x86
	CALL SUBOPT_0x27
	BRNE _0x87
	LDS  R16,_batas
	CLR  R17
_0x87:
	CALL _lcd_clear
; 0000 0165 if(!s2){timer[x]=timer[x]+1;}
_0x86:
	SBIC 0x13,2
	RJMP _0x88
	CALL SUBOPT_0x28
	CALL SUBOPT_0x29
; 0000 0166 if(!s3){timer[x]=timer[x]-1;}
_0x88:
	SBIC 0x13,3
	RJMP _0x89
	CALL SUBOPT_0x28
	CALL SUBOPT_0x1C
	SBIW R30,1
	MOVW R26,R0
	ST   X,R30
; 0000 0167 if(!s4){lcd_clear();
_0x89:
	SBIC 0x13,4
	RJMP _0x8A
	CALL SUBOPT_0x2A
; 0000 0168 for(count2=0;count2<=batas;count2++){etimer[count2]=timer[count2];}
_0x8C:
	CALL SUBOPT_0x2B
	BRLO _0x8D
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_etimer)
	SBCI R27,HIGH(-_etimer)
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_timer)
	SBCI R31,HIGH(-_timer)
	LD   R30,Z
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x8C
_0x8D:
; 0000 0169                 saved();
	RCALL _saved
; 0000 016A                 break;}
	RJMP _0x79
; 0000 016B delay_ms(150);
_0x8A:
	CALL SUBOPT_0x2F
; 0000 016C }
	RJMP _0x77
_0x79:
; 0000 016D }
	RJMP _0x2080006
;
;//-------------fungsi setting counter 1--------//
;void pintas()
; 0000 0171 {int x;
; 0000 0172 x=1;
;	x -> R16,R17
; 0000 0173 while(1){
; 0000 0174 if(!s1||!s2||!s3||!s4||!s5){led=0;}
; 0000 0175 else{led=1;}
; 0000 0176 lmp=1;
; 0000 0177 lcd_putsf("    [SETTING]");
; 0000 0178 lcd_gotoxy(0,0);
; 0000 0179 sprintf(buff,"Count1 %02d ",x);
; 0000 017A lcd_gotoxy(0,1);
; 0000 017B lcd_puts(buff);
; 0000 017C if(cut[x]==1){
; 0000 017D lcd_gotoxy(11,1);
; 0000 017E lcd_putsf("Lost   ");
; 0000 017F }
; 0000 0180 if(cut[x]==2){
; 0000 0181 lcd_gotoxy(11,1);
; 0000 0182 lcd_putsf("Kanan  ");
; 0000 0183 }
; 0000 0184 if(cut[x]==3){
; 0000 0185 lcd_gotoxy(11,1);
; 0000 0186 lcd_putsf("Kiri   ");
; 0000 0187 }
; 0000 0188 if(cut[x]==4){
; 0000 0189 lcd_gotoxy(11,1);
; 0000 018A lcd_putsf("Lost1  ");
; 0000 018B }
; 0000 018C if(cut[x]==5){
; 0000 018D lcd_gotoxy(11,1);
; 0000 018E lcd_putsf("Stop   ");
; 0000 018F }
; 0000 0190 if(!s1){if(++x>batas){x=1;}lcd_clear();}
; 0000 0191 if(!s5){if(--x==0){x=batas;}lcd_clear();}
; 0000 0192 if(!s2){if(++cut[x]==6){cut[x]=1;}}
; 0000 0193 if(!s3){if(--cut[x]<=0){cut[x]=5;}}
; 0000 0194 if(!s4){lcd_clear();
; 0000 0195 for(count2=0;count2<=batas;count2++){ecut[count2]=cut[count2];}
; 0000 0196                 saved();
; 0000 0197                 break;}
; 0000 0198 delay_ms(150);
; 0000 0199 }
; 0000 019A }
;
;//-------------fungsi setting counter 2--------//
;void pintas1()
; 0000 019E {int x;
; 0000 019F x=1;
;	x -> R16,R17
; 0000 01A0 while(1){
; 0000 01A1 if(!s1||!s2||!s3||!s4||!s5){led=0;}
; 0000 01A2 else{led=1;}
; 0000 01A3 lmp=1;
; 0000 01A4 lcd_putsf("    [SETTING]");
; 0000 01A5 lcd_gotoxy(0,0);
; 0000 01A6 sprintf(buff,"Count2 %02d ",x);
; 0000 01A7 lcd_gotoxy(0,1);
; 0000 01A8 lcd_puts(buff);
; 0000 01A9 if(cut1[x]==1){
; 0000 01AA lcd_gotoxy(11,1);
; 0000 01AB lcd_putsf("Lost   ");
; 0000 01AC }
; 0000 01AD if(cut1[x]==2){
; 0000 01AE lcd_gotoxy(11,1);
; 0000 01AF lcd_putsf("Kanan  ");
; 0000 01B0 
; 0000 01B1 }
; 0000 01B2 if(cut1[x]==3){
; 0000 01B3 lcd_gotoxy(11,1);
; 0000 01B4 lcd_putsf("Kiri   ");
; 0000 01B5 }
; 0000 01B6 if(cut1[x]==4){
; 0000 01B7 lcd_gotoxy(11,1);
; 0000 01B8 lcd_putsf("Lost1  ");
; 0000 01B9 }
; 0000 01BA if(cut1[x]==5){
; 0000 01BB lcd_gotoxy(11,1);
; 0000 01BC lcd_putsf("Stop   ");
; 0000 01BD }
; 0000 01BE if(!s1){if(++x>batas){x=1;}lcd_clear();}
; 0000 01BF if(!s5){if(--x==0){x=batas;}lcd_clear();}
; 0000 01C0 if(!s2){if(++cut1[x]==6){cut1[x]=1;}}
; 0000 01C1 if(!s3){if(--cut1[x]<=0){cut1[x]=5;}}
; 0000 01C2 if(!s4){lcd_clear();
; 0000 01C3 for(count2=0;count2<=batas;count2++){ecut1[count2]=cut1[count2];}
; 0000 01C4                 saved();
; 0000 01C5                 break;}
; 0000 01C6 delay_ms(150);
; 0000 01C7 }
; 0000 01C8 }
;
;//-------------fungsi setting delay rotate--------//
;void delay()
; 0000 01CC {int x;
_delay:
; 0000 01CD x=1;
	CALL SUBOPT_0x30
;	x -> R16,R17
; 0000 01CE while(1){
_0xCA:
; 0000 01CF if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0xCE
	SBIS 0x13,2
	RJMP _0xCE
	SBIS 0x13,3
	RJMP _0xCE
	SBIS 0x13,4
	RJMP _0xCE
	SBIC 0x13,1
	RJMP _0xCD
_0xCE:
	CBI  0x12,7
; 0000 01D0 else{led=1;}
	RJMP _0xD2
_0xCD:
	SBI  0x12,7
_0xD2:
; 0000 01D1 lmp=1;
	CALL SUBOPT_0x23
; 0000 01D2 lcd_putsf("    [SETTING]");
; 0000 01D3 lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 01D4 sprintf(buff,"Rotate%02d =%03d    ",x,del[x]);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,264
	CALL SUBOPT_0x24
	LDI  R26,LOW(_del)
	LDI  R27,HIGH(_del)
	CALL SUBOPT_0x25
	CALL SUBOPT_0x19
; 0000 01D5 lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 01D6 lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 01D7 if(!s1){if(++x>batas){x=1;}lcd_clear();}
	SBIC 0x13,0
	RJMP _0xD7
	CALL SUBOPT_0x26
	BRGE _0xD8
	__GETWRN 16,17,1
_0xD8:
	CALL _lcd_clear
; 0000 01D8 if(!s5){if(--x==0){x=batas;}lcd_clear();}
_0xD7:
	SBIC 0x13,1
	RJMP _0xD9
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	BRNE _0xDA
	LDS  R16,_batas
	CLR  R17
_0xDA:
	CALL _lcd_clear
; 0000 01D9 if(!s2){del[x]=del[x]+5;}
_0xD9:
	SBIC 0x13,2
	RJMP _0xDB
	CALL SUBOPT_0x31
	CALL SUBOPT_0x32
; 0000 01DA if(!s3){del[x]=del[x]-5;}
_0xDB:
	SBIC 0x13,3
	RJMP _0xDC
	CALL SUBOPT_0x31
	CALL SUBOPT_0x1C
	SBIW R30,5
	MOVW R26,R0
	ST   X,R30
; 0000 01DB if(!s4){lcd_clear();
_0xDC:
	SBIC 0x13,4
	RJMP _0xDD
	CALL SUBOPT_0x2A
; 0000 01DC for(count2=0;count2<=batas;count2++){edel[count2]=del[count2];}
_0xDF:
	CALL SUBOPT_0x2B
	BRLO _0xE0
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_edel)
	SBCI R27,HIGH(-_edel)
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_del)
	SBCI R31,HIGH(-_del)
	LD   R30,Z
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0xDF
_0xE0:
; 0000 01DD                 saved();
	RCALL _saved
; 0000 01DE                 break;}
	RJMP _0xCC
; 0000 01DF delay_ms(150);
_0xDD:
	CALL SUBOPT_0x2F
; 0000 01E0 }
	RJMP _0xCA
_0xCC:
; 0000 01E1 }
	RJMP _0x2080006
;
;//-------------fungsi setting kecepatan 1 counter--------//
;void kecepatan()
; 0000 01E5 {int xx;
_kecepatan:
; 0000 01E6 xx=0;
	CALL SUBOPT_0x0
;	xx -> R16,R17
; 0000 01E7 while(1){
_0xE1:
; 0000 01E8 if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0xE5
	SBIS 0x13,2
	RJMP _0xE5
	SBIS 0x13,3
	RJMP _0xE5
	SBIS 0x13,4
	RJMP _0xE5
	SBIC 0x13,1
	RJMP _0xE4
_0xE5:
	CBI  0x12,7
; 0000 01E9 else{led=1;}
	RJMP _0xE9
_0xE4:
	SBI  0x12,7
_0xE9:
; 0000 01EA lmp=1;
	CALL SUBOPT_0x23
; 0000 01EB lcd_putsf("    [SETTING]");
; 0000 01EC lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 01ED sprintf(buff,"Speed1 %02d =%03d    ",xx,speed[xx]);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,285
	CALL SUBOPT_0x24
	LDI  R26,LOW(_speed)
	LDI  R27,HIGH(_speed)
	CALL SUBOPT_0x25
	CALL SUBOPT_0x19
; 0000 01EE lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 01EF lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 01F0 if(!s1){if(++xx>batas){xx=0;}lcd_clear();}
	SBIC 0x13,0
	RJMP _0xEE
	CALL SUBOPT_0x26
	BRGE _0xEF
	__GETWRN 16,17,0
_0xEF:
	CALL _lcd_clear
; 0000 01F1 if(!s5){if(--xx==-1){xx=batas;}lcd_clear();}
_0xEE:
	SBIC 0x13,1
	RJMP _0xF0
	CALL SUBOPT_0x27
	BRNE _0xF1
	LDS  R16,_batas
	CLR  R17
_0xF1:
	CALL _lcd_clear
; 0000 01F2 if(!s2){speed[xx]=speed[xx]+5;}
_0xF0:
	SBIC 0x13,2
	RJMP _0xF2
	CALL SUBOPT_0x33
	CALL SUBOPT_0x32
; 0000 01F3 if(!s3){speed[xx]=speed[xx]-5;}
_0xF2:
	SBIC 0x13,3
	RJMP _0xF3
	CALL SUBOPT_0x33
	CALL SUBOPT_0x1C
	SBIW R30,5
	MOVW R26,R0
	ST   X,R30
; 0000 01F4 if(!s4){lcd_clear();
_0xF3:
	SBIC 0x13,4
	RJMP _0xF4
	CALL SUBOPT_0x2A
; 0000 01F5 for(count2=0;count2<=batas;count2++){espeed[count2]=speed[count2];}
_0xF6:
	CALL SUBOPT_0x2B
	BRLO _0xF7
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_espeed)
	SBCI R27,HIGH(-_espeed)
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_speed)
	SBCI R31,HIGH(-_speed)
	LD   R30,Z
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0xF6
_0xF7:
; 0000 01F6                 saved();
	RCALL _saved
; 0000 01F7                 break;}
	RJMP _0xE3
; 0000 01F8 delay_ms(150);
_0xF4:
	CALL SUBOPT_0x2F
; 0000 01F9 }
	RJMP _0xE1
_0xE3:
; 0000 01FA }
_0x2080006:
	LD   R16,Y+
	LD   R17,Y+
	RET
;
;//-------------fungsi setting kecepatan 2 counter--------//
;void kecepatan1()
; 0000 01FE {int xx;
_kecepatan1:
; 0000 01FF xx=0;
	CALL SUBOPT_0x0
;	xx -> R16,R17
; 0000 0200 while(1){
_0xF8:
; 0000 0201 if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0xFC
	SBIS 0x13,2
	RJMP _0xFC
	SBIS 0x13,3
	RJMP _0xFC
	SBIS 0x13,4
	RJMP _0xFC
	SBIC 0x13,1
	RJMP _0xFB
_0xFC:
	CBI  0x12,7
; 0000 0202 else{led=1;}
	RJMP _0x100
_0xFB:
	SBI  0x12,7
_0x100:
; 0000 0203 lmp=1;
	CALL SUBOPT_0x23
; 0000 0204 lcd_putsf("    [SETTING]");
; 0000 0205 lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0206 sprintf(buff,"Speed2 %02d =%03d    ",xx,speed1[xx]);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,307
	CALL SUBOPT_0x24
	LDI  R26,LOW(_speed1)
	LDI  R27,HIGH(_speed1)
	CALL SUBOPT_0x25
	CALL SUBOPT_0x19
; 0000 0207 lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0208 lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0209 if(!s1){if(++xx>batas){xx=0;}lcd_clear();}
	SBIC 0x13,0
	RJMP _0x105
	CALL SUBOPT_0x26
	BRGE _0x106
	__GETWRN 16,17,0
_0x106:
	CALL _lcd_clear
; 0000 020A if(!s5){if(--xx==-1){xx=batas;}lcd_clear();}
_0x105:
	SBIC 0x13,1
	RJMP _0x107
	CALL SUBOPT_0x27
	BRNE _0x108
	LDS  R16,_batas
	CLR  R17
_0x108:
	CALL _lcd_clear
; 0000 020B if(!s2){speed1[xx]=speed1[xx]+5;}
_0x107:
	SBIC 0x13,2
	RJMP _0x109
	CALL SUBOPT_0x34
	CALL SUBOPT_0x32
; 0000 020C if(!s3){speed1[xx]=speed1[xx]-5;}
_0x109:
	SBIC 0x13,3
	RJMP _0x10A
	CALL SUBOPT_0x34
	CALL SUBOPT_0x1C
	SBIW R30,5
	MOVW R26,R0
	ST   X,R30
; 0000 020D if(!s4){lcd_clear();
_0x10A:
	SBIC 0x13,4
	RJMP _0x10B
	CALL SUBOPT_0x2A
; 0000 020E for(count2=0;count2<=batas;count2++){espeed1[count2]=speed1[count2];}
_0x10D:
	CALL SUBOPT_0x2B
	BRLO _0x10E
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_espeed1)
	SBCI R27,HIGH(-_espeed1)
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_speed1)
	SBCI R31,HIGH(-_speed1)
	LD   R30,Z
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x10D
_0x10E:
; 0000 020F                 saved();
	RCALL _saved
; 0000 0210                 break;}
	RJMP _0xFA
; 0000 0211 delay_ms(150);
_0x10B:
	CALL SUBOPT_0x2F
; 0000 0212 }
	RJMP _0xF8
_0xFA:
; 0000 0213 }
	RJMP _0x2080005
;
;//-------------fungsi setting rencana cek point set timer--------//
;void rencana1()
; 0000 0217 {int xx;
_rencana1:
; 0000 0218 xx=1;
	CALL SUBOPT_0x30
;	xx -> R16,R17
; 0000 0219 while(1){
_0x10F:
; 0000 021A if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0x113
	SBIS 0x13,2
	RJMP _0x113
	SBIS 0x13,3
	RJMP _0x113
	SBIS 0x13,4
	RJMP _0x113
	SBIC 0x13,1
	RJMP _0x112
_0x113:
	CBI  0x12,7
; 0000 021B else{led=1;}
	RJMP _0x117
_0x112:
	SBI  0x12,7
_0x117:
; 0000 021C lmp=1;
	CALL SUBOPT_0x23
; 0000 021D lcd_putsf("    [SETTING]");
; 0000 021E lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 021F sprintf(buff,"Cp%02d Time=%03d    ",xx,plan[xx]);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,329
	CALL SUBOPT_0x24
	LDI  R26,LOW(_plan)
	LDI  R27,HIGH(_plan)
	CALL SUBOPT_0x25
	CALL SUBOPT_0x19
; 0000 0220 lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0221 lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0222 if(!s1){if(++xx>20){xx=1;}lcd_clear();}
	SBIC 0x13,0
	RJMP _0x11C
	MOVW R30,R16
	ADIW R30,1
	MOVW R16,R30
	SBIW R30,21
	BRLT _0x11D
	__GETWRN 16,17,1
_0x11D:
	CALL _lcd_clear
; 0000 0223 if(!s5){if(--xx==0){xx=20;}lcd_clear();}
_0x11C:
	SBIC 0x13,1
	RJMP _0x11E
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	BRNE _0x11F
	__GETWRN 16,17,20
_0x11F:
	CALL _lcd_clear
; 0000 0224 if(!s2){plan[xx]=plan[xx]+1;}
_0x11E:
	SBIC 0x13,2
	RJMP _0x120
	CALL SUBOPT_0x35
	CALL SUBOPT_0x29
; 0000 0225 if(!s3){plan[xx]=plan[xx]-1;}
_0x120:
	SBIC 0x13,3
	RJMP _0x121
	CALL SUBOPT_0x35
	CALL SUBOPT_0x1C
	SBIW R30,1
	MOVW R26,R0
	ST   X,R30
; 0000 0226 if(!s4){lcd_clear();
_0x121:
	SBIC 0x13,4
	RJMP _0x122
	CALL SUBOPT_0x2A
; 0000 0227 for(count2=0;count2<=20;count2++){eplan[count2]=plan[count2];}
_0x124:
	LDS  R26,_count2
	CPI  R26,LOW(0x15)
	BRSH _0x125
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_eplan)
	SBCI R27,HIGH(-_eplan)
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_plan)
	SBCI R31,HIGH(-_plan)
	LD   R30,Z
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x124
_0x125:
; 0000 0228                 saved();
	RCALL _saved
; 0000 0229                 break;}
	RJMP _0x111
; 0000 022A delay_ms(150);
_0x122:
	CALL SUBOPT_0x2F
; 0000 022B }
	RJMP _0x10F
_0x111:
; 0000 022C }
	RJMP _0x2080005
;
;//-------------fungsi setting rencana cek point set counter--------//
;void rencana2()
; 0000 0230 {int xx;
_rencana2:
; 0000 0231 xx=1;
	CALL SUBOPT_0x30
;	xx -> R16,R17
; 0000 0232 while(1){
_0x126:
; 0000 0233 if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0x12A
	SBIS 0x13,2
	RJMP _0x12A
	SBIS 0x13,3
	RJMP _0x12A
	SBIS 0x13,4
	RJMP _0x12A
	SBIC 0x13,1
	RJMP _0x129
_0x12A:
	CBI  0x12,7
; 0000 0234 else{led=1;}
	RJMP _0x12E
_0x129:
	SBI  0x12,7
_0x12E:
; 0000 0235 lmp=1;
	CALL SUBOPT_0x23
; 0000 0236 lcd_putsf("    [SETTING]");
; 0000 0237 lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0238 sprintf(buff,"Cp%02d Read=%03d    ",xx,read[xx]);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,350
	CALL SUBOPT_0x24
	LDI  R26,LOW(_read)
	LDI  R27,HIGH(_read)
	CALL SUBOPT_0x25
	CALL SUBOPT_0x19
; 0000 0239 lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 023A lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 023B if(!s1){if(++xx>20){xx=1;}lcd_clear();}
	SBIC 0x13,0
	RJMP _0x133
	MOVW R30,R16
	ADIW R30,1
	MOVW R16,R30
	SBIW R30,21
	BRLT _0x134
	__GETWRN 16,17,1
_0x134:
	CALL _lcd_clear
; 0000 023C if(!s5){if(--xx==0){xx=20;}lcd_clear();}
_0x133:
	SBIC 0x13,1
	RJMP _0x135
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	BRNE _0x136
	__GETWRN 16,17,20
_0x136:
	CALL _lcd_clear
; 0000 023D if(!s2){read[xx]=read[xx]+1;}
_0x135:
	SBIC 0x13,2
	RJMP _0x137
	CALL SUBOPT_0x36
	CALL SUBOPT_0x29
; 0000 023E if(!s3){read[xx]=read[xx]-1;}
_0x137:
	SBIC 0x13,3
	RJMP _0x138
	CALL SUBOPT_0x36
	CALL SUBOPT_0x1C
	SBIW R30,1
	MOVW R26,R0
	ST   X,R30
; 0000 023F if(!s4){lcd_clear();
_0x138:
	SBIC 0x13,4
	RJMP _0x139
	CALL SUBOPT_0x2A
; 0000 0240 for(count2=0;count2<=20;count2++){eread[count2]=read[count2];}
_0x13B:
	LDS  R26,_count2
	CPI  R26,LOW(0x15)
	BRSH _0x13C
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_eread)
	SBCI R27,HIGH(-_eread)
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_read)
	SBCI R31,HIGH(-_read)
	LD   R30,Z
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x13B
_0x13C:
; 0000 0241                 saved();
	RCALL _saved
; 0000 0242                 break;}
	RJMP _0x128
; 0000 0243 delay_ms(150);
_0x139:
	CALL SUBOPT_0x2F
; 0000 0244 }
	RJMP _0x126
_0x128:
; 0000 0245 }
	RJMP _0x2080005
;
;//-------------fungsi ceking sensor--------//
;void ceksensor()
; 0000 0249 {int xx=0;
_ceksensor:
; 0000 024A while(1){
	CALL SUBOPT_0x0
;	xx -> R16,R17
_0x13D:
; 0000 024B if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0x141
	SBIS 0x13,2
	RJMP _0x141
	SBIS 0x13,3
	RJMP _0x141
	SBIS 0x13,4
	RJMP _0x141
	SBIC 0x13,1
	RJMP _0x140
_0x141:
	CBI  0x12,7
; 0000 024C else{led=1;}
	RJMP _0x145
_0x140:
	SBI  0x12,7
_0x145:
; 0000 024D lmp=1;
	CALL SUBOPT_0x23
; 0000 024E lcd_putsf("    [SETTING]");
; 0000 024F lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0250 sprintf(buff,"Sensor%d ->%d     ",xx,in);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,371
	CALL SUBOPT_0x24
	LDS  R30,_in
	CALL SUBOPT_0x17
	CALL SUBOPT_0x19
; 0000 0251 lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0252 lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0253 if(xx>13){xx=0;}
	__CPWRN 16,17,14
	BRLT _0x14A
	__GETWRN 16,17,0
; 0000 0254 if(xx<0){xx=13;}
_0x14A:
	TST  R17
	BRPL _0x14B
	__GETWRN 16,17,13
; 0000 0255 if(!s2){xx=xx+1;}
_0x14B:
	SBIC 0x13,2
	RJMP _0x14C
	__ADDWRN 16,17,1
; 0000 0256 if(!s3){xx=xx-1;}
_0x14C:
	SBIC 0x13,3
	RJMP _0x14D
	__SUBWRN 16,17,1
; 0000 0257 if(xx<7){L=1;R=0;in=read_adc(xx);}
_0x14D:
	__CPWRN 16,17,7
	BRGE _0x14E
	SBI  0x15,7
	CBI  0x15,6
	ST   -Y,R16
	CALL SUBOPT_0x37
; 0000 0258 if(xx>=7){L=0;R=1;in=read_adc(xx-7);}
_0x14E:
	__CPWRN 16,17,7
	BRLT _0x153
	CBI  0x15,7
	SBI  0x15,6
	MOVW R30,R16
	SBIW R30,7
	ST   -Y,R30
	CALL SUBOPT_0x37
; 0000 0259 if(!s4){
_0x153:
	SBIC 0x13,4
	RJMP _0x158
; 0000 025A                 lcd_clear();
	CALL _lcd_clear
; 0000 025B                 break;}
	RJMP _0x13F
; 0000 025C delay_ms(150);
_0x158:
	CALL SUBOPT_0x2F
; 0000 025D }
	RJMP _0x13D
_0x13F:
; 0000 025E }
	RJMP _0x2080005
;
;//-------------fungsi setting mode darurat--------//
;void darurat()
; 0000 0262 {
_darurat:
; 0000 0263 int ss=0;
; 0000 0264 while(1){
	CALL SUBOPT_0x0
;	ss -> R16,R17
_0x159:
; 0000 0265 if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0x15D
	SBIS 0x13,2
	RJMP _0x15D
	SBIS 0x13,3
	RJMP _0x15D
	SBIS 0x13,4
	RJMP _0x15D
	SBIC 0x13,1
	RJMP _0x15C
_0x15D:
	CBI  0x12,7
; 0000 0266 else{led=1;}
	RJMP _0x161
_0x15C:
	SBI  0x12,7
_0x161:
; 0000 0267 lmp=1;
	CALL SUBOPT_0x23
; 0000 0268 lcd_putsf("    [SETTING]");
; 0000 0269 lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 026A sprintf(buff,"Cek Point[%02d]      ",ss);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,390
	CALL SUBOPT_0x24
	CALL SUBOPT_0x1E
; 0000 026B lcd_gotoxy(0,1);
; 0000 026C lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 026D if(!s2){if(++ss>batas){ss=0;}delay_ms(150);}
	SBIC 0x13,2
	RJMP _0x166
	CALL SUBOPT_0x26
	BRGE _0x167
	__GETWRN 16,17,0
_0x167:
	CALL SUBOPT_0x2F
; 0000 026E if(!s3){if(--ss<=-1){ss=batas;}delay_ms(150);}
_0x166:
	SBIC 0x13,3
	RJMP _0x168
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	MOVW R26,R30
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x169
	LDS  R16,_batas
	CLR  R17
_0x169:
	CALL SUBOPT_0x2F
; 0000 026F if(!s4||!s6){lcd_clear();
_0x168:
	SBIS 0x13,4
	RJMP _0x16B
	SBIC 0x13,5
	RJMP _0x16A
_0x16B:
	CALL _lcd_clear
; 0000 0270                 if(ss>0){start=read[ss];
	CLR  R0
	CP   R0,R16
	CPC  R0,R17
	BRGE _0x16D
	LDI  R26,LOW(_read)
	LDI  R27,HIGH(_read)
	ADD  R26,R16
	ADC  R27,R17
	LD   R30,X
	STS  _start,R30
; 0000 0271                 timer[start]=plan[ss];
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_timer)
	SBCI R31,HIGH(-_timer)
	MOVW R0,R30
	LDI  R26,LOW(_plan)
	LDI  R27,HIGH(_plan)
	ADD  R26,R16
	ADC  R27,R17
	LD   R30,X
	MOVW R26,R0
	ST   X,R30
; 0000 0272                 }
; 0000 0273                 lcd_clear();
_0x16D:
	CALL _lcd_clear
; 0000 0274                 break;}
	RJMP _0x15B
; 0000 0275 }
_0x16A:
	RJMP _0x159
_0x15B:
; 0000 0276 }
	RJMP _0x2080005
;
;//-------------fungsi setting menu--------//
;void setting()
; 0000 027A {
_setting:
; 0000 027B 
; 0000 027C 
; 0000 027D int n;
; 0000 027E n=0;
	CALL SUBOPT_0x0
;	n -> R16,R17
; 0000 027F while(1){
_0x16E:
; 0000 0280 lmp=1;
	SBI  0x18,3
; 0000 0281 
; 0000 0282 if(!s1||!s2||!s3||!s4||!s5){led=0;}
	SBIS 0x13,0
	RJMP _0x174
	SBIS 0x13,2
	RJMP _0x174
	SBIS 0x13,3
	RJMP _0x174
	SBIS 0x13,4
	RJMP _0x174
	SBIC 0x13,1
	RJMP _0x173
_0x174:
	CBI  0x12,7
; 0000 0283 else{led=1;}
	RJMP _0x178
_0x173:
	SBI  0x12,7
_0x178:
; 0000 0284 if(!s5){n=n-1;lcd_clear();}
	SBIC 0x13,1
	RJMP _0x17B
	__SUBWRN 16,17,1
	CALL _lcd_clear
; 0000 0285 if(n==-1){n=18;}
_0x17B:
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x17C
	__GETWRN 16,17,18
; 0000 0286 if(!s1){n=n+1;lcd_clear();}
_0x17C:
	SBIC 0x13,0
	RJMP _0x17D
	__ADDWRN 16,17,1
	CALL _lcd_clear
; 0000 0287 if(n==19){n=0;}
_0x17D:
	LDI  R30,LOW(19)
	LDI  R31,HIGH(19)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x17E
	__GETWRN 16,17,0
; 0000 0288 
; 0000 0289                 if(n==1){
_0x17E:
	CALL SUBOPT_0x1F
	BRNE _0x17F
; 0000 028A                 lcd_gotoxy(4,0);
	CALL SUBOPT_0x38
; 0000 028B                 lcd_putsf("[SETTING]");
; 0000 028C                         sprintf(buff,"1.Calibration %d ", m);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,412
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R10
	CALL SUBOPT_0x39
; 0000 028D                         lcd_gotoxy(0,1);
; 0000 028E                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 028F                         if(!s2){autoscan();}
	SBIS 0x13,2
	RCALL _autoscan
; 0000 0290                         if(!s3){m++;
	SBIC 0x13,3
	RJMP _0x181
	MOVW R30,R10
	ADIW R30,1
	MOVW R10,R30
; 0000 0291                         if(m==2){m=0;}}}
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CP   R30,R10
	CPC  R31,R11
	BRNE _0x182
	CLR  R10
	CLR  R11
_0x182:
_0x181:
; 0000 0292                 if(n==2){
_0x17F:
	CALL SUBOPT_0x21
	BRNE _0x183
; 0000 0293                 lcd_gotoxy(4,0);
	CALL SUBOPT_0x38
; 0000 0294                 lcd_putsf("[SETTING]");
; 0000 0295                         sprintf(buff,"2.Speed=%d   ",max1);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,430
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R8
	CALL SUBOPT_0x39
; 0000 0296                         lcd_gotoxy(0,1);
; 0000 0297                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0298                         if(!s2){max1=max1+5;
	SBIC 0x13,2
	RJMP _0x184
	MOVW R30,R8
	ADIW R30,5
	MOVW R8,R30
; 0000 0299                         if (max1>255){max1=0;}}
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	CP   R30,R8
	CPC  R31,R9
	BRGE _0x185
	CLR  R8
	CLR  R9
_0x185:
; 0000 029A                         if(!s3){max1=max1-5;
_0x184:
	SBIC 0x13,3
	RJMP _0x186
	MOVW R30,R8
	SBIW R30,5
	MOVW R8,R30
; 0000 029B                         if (max1<0){max1=255;}}}
	CLR  R0
	CP   R8,R0
	CPC  R9,R0
	BRGE _0x187
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	MOVW R8,R30
_0x187:
_0x186:
; 0000 029C                 if(n==3 ){
_0x183:
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x188
; 0000 029D                 lcd_gotoxy(4,0);
	CALL SUBOPT_0x38
; 0000 029E                 lcd_putsf("[SETTING]");
; 0000 029F                         sprintf(buff,"3.Kec.Belok=%d   ",lc);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,444
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R12
	CALL SUBOPT_0x39
; 0000 02A0                         lcd_gotoxy(0,1);
; 0000 02A1                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 02A2                         if(!s2){lc=lc+5;
	SBIC 0x13,2
	RJMP _0x189
	MOVW R30,R12
	ADIW R30,5
	MOVW R12,R30
; 0000 02A3                         if (lc>255){lc=0;}}
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	CP   R30,R12
	CPC  R31,R13
	BRGE _0x18A
	CLR  R12
	CLR  R13
_0x18A:
; 0000 02A4                         if(!s3){lc=lc-5;
_0x189:
	SBIC 0x13,3
	RJMP _0x18B
	MOVW R30,R12
	SBIW R30,5
	MOVW R12,R30
; 0000 02A5                         if (lc<0){lc=255;}}}
	CLR  R0
	CP   R12,R0
	CPC  R13,R0
	BRGE _0x18C
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	MOVW R12,R30
_0x18C:
_0x18B:
; 0000 02A6                 if(n==4){
_0x188:
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x18D
; 0000 02A7                 lcd_gotoxy(4,0);
	CALL SUBOPT_0x38
; 0000 02A8                 lcd_putsf("[SETTING]");
; 0000 02A9                         sprintf(buff,"4.");
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,462
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	CALL _sprintf
	ADIW R28,4
; 0000 02AA                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 02AB                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 02AC 
; 0000 02AD                         }
; 0000 02AE                 if(n==5){
_0x18D:
	LDI  R30,LOW(5)
	LDI  R31,HIGH(5)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x18E
; 0000 02AF                 lcd_gotoxy(4,0);
	CALL SUBOPT_0x38
; 0000 02B0                 lcd_putsf("[SETTING]");
; 0000 02B1                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 02B2                         lcd_putsf("5.PID ");
	__POINTW1FN _0x0,465
	CALL SUBOPT_0x6
; 0000 02B3                         if(!s2){pid();}}
	SBIS 0x13,2
	RCALL _pid
; 0000 02B4                 if(n==6){
_0x18E:
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	CP   R30,R16
	CPC  R31,R17
	BREQ PC+3
	JMP _0x190
; 0000 02B5                 awalStrategi:
_0x191:
; 0000 02B6                 lcd_clear();
	CALL _lcd_clear
; 0000 02B7                 lcd_gotoxy(4,0);
	CALL SUBOPT_0x38
; 0000 02B8                 lcd_putsf("[SETTING]");
; 0000 02B9                   lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 02BA                   lcd_putsf("6.Strategi");
	__POINTW1FN _0x0,472
	CALL SUBOPT_0x6
; 0000 02BB                   if(!s2){
	SBIC 0x13,2
	RJMP _0x192
; 0000 02BC                    int p_strategi=0;
; 0000 02BD                   lcd_clear();
	SBIW R28,2
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
;	p_strategi -> Y+0
	CALL _lcd_clear
; 0000 02BE 
; 0000 02BF                 while(1){
_0x193:
; 0000 02C0                 if(!s1){p_strategi=p_strategi+1;lcd_clear();delay_ms(250);}
	SBIC 0x13,0
	RJMP _0x196
	CALL SUBOPT_0x3A
	LDI  R30,LOW(250)
	LDI  R31,HIGH(250)
	CALL SUBOPT_0x22
; 0000 02C1                 if(!s5){p_strategi=p_strategi-1;lcd_clear();delay_ms(250);}
_0x196:
	SBIC 0x13,1
	RJMP _0x197
	LD   R30,Y
	LDD  R31,Y+1
	SBIW R30,1
	ST   Y,R30
	STD  Y+1,R31
	CALL _lcd_clear
	LDI  R30,LOW(250)
	LDI  R31,HIGH(250)
	CALL SUBOPT_0x22
; 0000 02C2                 if(p_strategi==-1){p_strategi=4;}
_0x197:
	LD   R26,Y
	LDD  R27,Y+1
	CPI  R26,LOW(0xFFFF)
	LDI  R30,HIGH(0xFFFF)
	CPC  R27,R30
	BRNE _0x198
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	ST   Y,R30
	STD  Y+1,R31
; 0000 02C3                 if(p_strategi==5){p_strategi=0;}
_0x198:
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,5
	BRNE _0x199
	LDI  R30,LOW(0)
	STD  Y+0,R30
	STD  Y+0+1,R30
; 0000 02C4 
; 0000 02C5                         if(p_strategi==0){
_0x199:
	LD   R30,Y
	LDD  R31,Y+1
	SBIW R30,0
	BRNE _0x19A
; 0000 02C6                         lcd_gotoxy(2,0);
	CALL SUBOPT_0x3B
; 0000 02C7                         lcd_putsf("[6.Strategi]");
; 0000 02C8                         sprintf(buff,"1.Speed Stra=%d   ", vc);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,496
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x3C
	CALL SUBOPT_0x39
; 0000 02C9                         lcd_gotoxy(0,1);
; 0000 02CA                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 02CB                         if(!s2){
	SBIC 0x13,2
	RJMP _0x19B
; 0000 02CC                         vc=vc+5;delay_ms(150);
	CALL SUBOPT_0x3C
	ADIW R30,5
	CALL SUBOPT_0x3D
; 0000 02CD                         if(vc>255){vc=0;}}
	LDS  R26,_vc
	LDS  R27,_vc+1
	CPI  R26,LOW(0x100)
	LDI  R30,HIGH(0x100)
	CPC  R27,R30
	BRLT _0x19C
	LDI  R30,LOW(0)
	STS  _vc,R30
	STS  _vc+1,R30
_0x19C:
; 0000 02CE                         if(!s3){vc=vc-5;delay_ms(150);
_0x19B:
	SBIC 0x13,3
	RJMP _0x19D
	CALL SUBOPT_0x3C
	SBIW R30,5
	CALL SUBOPT_0x3D
; 0000 02CF                         if (vc<0){vc=255;}}
	LDS  R26,_vc+1
	TST  R26
	BRPL _0x19E
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	STS  _vc,R30
	STS  _vc+1,R31
_0x19E:
; 0000 02D0                         }
_0x19D:
; 0000 02D1 
; 0000 02D2                         if(p_strategi==1){
_0x19A:
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,1
	BRNE _0x19F
; 0000 02D3                         lcd_gotoxy(2,0);
	CALL SUBOPT_0x3B
; 0000 02D4                         lcd_putsf("[6.Strategi]");
; 0000 02D5                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 02D6                         lcd_putsf("2.Start A");
	__POINTW1FN _0x0,515
	CALL SUBOPT_0x6
; 0000 02D7                         }
; 0000 02D8 
; 0000 02D9                         if(p_strategi==2){
_0x19F:
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,2
	BRNE _0x1A0
; 0000 02DA                         lcd_gotoxy(2,0);
	CALL SUBOPT_0x3B
; 0000 02DB                         lcd_putsf("[6.Strategi]");
; 0000 02DC                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 02DD                         lcd_putsf("3.Start B");
	__POINTW1FN _0x0,525
	CALL SUBOPT_0x6
; 0000 02DE                         }
; 0000 02DF 
; 0000 02E0                         if(p_strategi==3){
_0x1A0:
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,3
	BRNE _0x1A1
; 0000 02E1                         lcd_gotoxy(2,0);
	CALL SUBOPT_0x3B
; 0000 02E2                         lcd_putsf("[6.Strategi]");
; 0000 02E3                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 02E4                         lcd_putsf("4.Start C");
	__POINTW1FN _0x0,535
	CALL SUBOPT_0x6
; 0000 02E5                         }
; 0000 02E6 
; 0000 02E7                         if(p_strategi==4){
_0x1A1:
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,4
	BRNE _0x1A2
; 0000 02E8                         lcd_gotoxy(2,0);
	CALL SUBOPT_0x3B
; 0000 02E9                         lcd_putsf("[6.Strategi]");
; 0000 02EA                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 02EB                         lcd_putsf("5.Start D");
	__POINTW1FN _0x0,545
	CALL SUBOPT_0x6
; 0000 02EC                         }
; 0000 02ED 
; 0000 02EE                         if(!s6){goto awalStrategi;}
_0x1A2:
	SBIS 0x13,5
	RJMP _0x191
; 0000 02EF 
; 0000 02F0                   }
	RJMP _0x193
; 0000 02F1 
; 0000 02F2 
; 0000 02F3                 }
; 0000 02F4                 /*
; 0000 02F5                 int p_strategi=0;
; 0000 02F6                 while(1){
; 0000 02F7                 if(!s3){p_strategi=p_strategi+1;lcd_clear();delay_ms(250);}
; 0000 02F8                 if(p_strategi==2){p_strategi=0;}
; 0000 02F9                         if(p_strategi==0){
; 0000 02FA                         lcd_gotoxy(0,1);
; 0000 02FB                         lcd_putsf("6.Strategi [1]");
; 0000 02FC                         }
; 0000 02FD 
; 0000 02FE                         if(p_strategi==1){
; 0000 02FF                         lcd_gotoxy(0,1);
; 0000 0300                         lcd_putsf("6.Strategi [2]");
; 0000 0301                         }
; 0000 0302 
; 0000 0303                 } */
; 0000 0304 
; 0000 0305                        //if(!s2){pintas();}
; 0000 0306 
; 0000 0307                         }
_0x192:
; 0000 0308                 if(n==7){
_0x190:
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1A4
; 0000 0309                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 030A                         lcd_putsf("7.");
	__POINTW1FN _0x0,555
	CALL SUBOPT_0x6
; 0000 030B                         //if(!s2){pintas1();}
; 0000 030C                         }
; 0000 030D 
; 0000 030E                 if(n==8){
_0x1A4:
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1A5
; 0000 030F                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0310                         lcd_putsf("8.Timer      ");
	__POINTW1FN _0x0,558
	CALL SUBOPT_0x6
; 0000 0311                         if(!s2){waktu();}}
	SBIS 0x13,2
	RCALL _waktu
; 0000 0312                 if(n==9){
_0x1A5:
	LDI  R30,LOW(9)
	LDI  R31,HIGH(9)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1A7
; 0000 0313                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0314                         lcd_putsf("9.Speed1 Count     ");
	__POINTW1FN _0x0,572
	CALL SUBOPT_0x6
; 0000 0315                         if(!s2){kecepatan();}}
	SBIS 0x13,2
	RCALL _kecepatan
; 0000 0316                 if(n==10){
_0x1A7:
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1A9
; 0000 0317                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0318                         lcd_putsf("10.Speed2 Count     ");
	__POINTW1FN _0x0,592
	CALL SUBOPT_0x6
; 0000 0319                         if(!s2){kecepatan1();}}
	SBIS 0x13,2
	RCALL _kecepatan1
; 0000 031A                 if(n==11){
_0x1A9:
	LDI  R30,LOW(11)
	LDI  R31,HIGH(11)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1AB
; 0000 031B                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 031C                         lcd_putsf("11.Delay       ");
	__POINTW1FN _0x0,613
	CALL SUBOPT_0x6
; 0000 031D                         if(!s2){delay();}}
	SBIS 0x13,2
	RCALL _delay
; 0000 031E                 if(n==12){
_0x1AB:
	LDI  R30,LOW(12)
	LDI  R31,HIGH(12)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1AD
; 0000 031F                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0320                         lcd_putsf("11.Plan Timer    ");
	__POINTW1FN _0x0,629
	CALL SUBOPT_0x6
; 0000 0321                         if(!s2){rencana1();}}
	SBIS 0x13,2
	RCALL _rencana1
; 0000 0322                 if(n==13){
_0x1AD:
	LDI  R30,LOW(13)
	LDI  R31,HIGH(13)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1AF
; 0000 0323                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0324                         lcd_putsf("12.Atur CP");
	__POINTW1FN _0x0,647
	CALL SUBOPT_0x6
; 0000 0325                         if(!s2){rencana2();}}
	SBIS 0x13,2
	RCALL _rencana2
; 0000 0326                 if(n==14){
_0x1AF:
	LDI  R30,LOW(14)
	LDI  R31,HIGH(14)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1B1
; 0000 0327                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0328                         if(mode==1){lcd_putsf("13.[Counter] Normal ");}
	LDS  R26,_mode
	CPI  R26,LOW(0x1)
	BRNE _0x1B2
	__POINTW1FN _0x0,658
	CALL SUBOPT_0x6
; 0000 0329                         if(mode==0){lcd_putsf("13.Jalan Aja");}
_0x1B2:
	LDS  R30,_mode
	CPI  R30,0
	BRNE _0x1B3
	__POINTW1FN _0x0,679
	CALL SUBOPT_0x6
; 0000 032A                         if(!s2){mode=0;}
_0x1B3:
	SBIC 0x13,2
	RJMP _0x1B4
	LDI  R30,LOW(0)
	STS  _mode,R30
; 0000 032B                         if(!s3){mode=1;}
_0x1B4:
	SBIC 0x13,3
	RJMP _0x1B5
	LDI  R30,LOW(1)
	STS  _mode,R30
; 0000 032C                         }
_0x1B5:
; 0000 032D                 if(n==15){
_0x1B1:
	LDI  R30,LOW(15)
	LDI  R31,HIGH(15)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1B6
; 0000 032E                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 032F                         if(modekanan==1){lcd_putsf("14.Counter 2 ");}
	LDS  R26,_modekanan
	CPI  R26,LOW(0x1)
	BRNE _0x1B7
	__POINTW1FN _0x0,692
	CALL SUBOPT_0x6
; 0000 0330                         if(modekanan==0){lcd_putsf("14.Counter 1 ");}
_0x1B7:
	LDS  R30,_modekanan
	CPI  R30,0
	BRNE _0x1B8
	__POINTW1FN _0x0,706
	CALL SUBOPT_0x6
; 0000 0331                         if(!s2){modekanan=1;}
_0x1B8:
	SBIC 0x13,2
	RJMP _0x1B9
	LDI  R30,LOW(1)
	STS  _modekanan,R30
; 0000 0332                         if(!s3){modekanan=0;}}
_0x1B9:
	SBIC 0x13,3
	RJMP _0x1BA
	LDI  R30,LOW(0)
	STS  _modekanan,R30
_0x1BA:
; 0000 0333                 if(n==16){
_0x1B6:
	LDI  R30,LOW(16)
	LDI  R31,HIGH(16)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1BB
; 0000 0334                         sprintf(buff,"15.Smoothing=%d   ", pulsa);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,720
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_pulsa
	CALL SUBOPT_0x17
	CALL SUBOPT_0x1E
; 0000 0335                         lcd_gotoxy(0,1);
; 0000 0336                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0337                         if(!s2){
	SBIC 0x13,2
	RJMP _0x1BC
; 0000 0338                         pulsa=pulsa+1;if (pulsa>255){pulsa=0;}}
	LDS  R30,_pulsa
	SUBI R30,-LOW(1)
	STS  _pulsa,R30
	LDS  R26,_pulsa
	LDI  R30,LOW(255)
	CP   R30,R26
	BRSH _0x1BD
	LDI  R30,LOW(0)
	STS  _pulsa,R30
_0x1BD:
; 0000 0339                         if(!s3){pulsa=pulsa-1;if (pulsa<0){pulsa=255;}}}
_0x1BC:
	SBIC 0x13,3
	RJMP _0x1BE
	LDS  R30,_pulsa
	CALL SUBOPT_0x20
	STS  _pulsa,R30
	LDS  R26,_pulsa
_0x1BE:
; 0000 033A                 if(n==17){
_0x1BB:
	LDI  R30,LOW(17)
	LDI  R31,HIGH(17)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1C0
; 0000 033B                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 033C                         lcd_putsf("16.Cek Sensor");
	__POINTW1FN _0x0,739
	CALL SUBOPT_0x6
; 0000 033D                         if(!s2){ceksensor();}}
	SBIS 0x13,2
	RCALL _ceksensor
; 0000 033E                 if(n==18){
_0x1C0:
	LDI  R30,LOW(18)
	LDI  R31,HIGH(18)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x1C2
; 0000 033F                         sprintf(buff,"17.Rem =%d   ",lc1);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,753
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x3E
	CALL SUBOPT_0x39
; 0000 0340                         lcd_gotoxy(0,1);
; 0000 0341                         lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 0342                         if(!s2){lc1=lc1+5;
	SBIC 0x13,2
	RJMP _0x1C3
	CALL SUBOPT_0x3E
	ADIW R30,5
	CALL SUBOPT_0x3F
; 0000 0343                         if (lc1>255){lc1=0;}}
	CALL SUBOPT_0x40
	CPI  R26,LOW(0x100)
	LDI  R30,HIGH(0x100)
	CPC  R27,R30
	BRLT _0x1C4
	LDI  R30,LOW(0)
	STS  _lc1,R30
	STS  _lc1+1,R30
_0x1C4:
; 0000 0344                         if(!s3){lc1=lc1-5;
_0x1C3:
	SBIC 0x13,3
	RJMP _0x1C5
	CALL SUBOPT_0x3E
	SBIW R30,5
	CALL SUBOPT_0x3F
; 0000 0345                         if (lc1<0){lc1=255;}}}
	LDS  R26,_lc1+1
	TST  R26
	BRPL _0x1C6
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	CALL SUBOPT_0x3F
_0x1C6:
_0x1C5:
; 0000 0346                 if(n==0){
_0x1C2:
	MOV  R0,R16
	OR   R0,R17
	BRNE _0x1C7
; 0000 0347 
; 0000 0348                         lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0349                         if(encomp==2){lcd_putsf("18.White Line ");}
	CALL SUBOPT_0x41
	SBIW R26,2
	BRNE _0x1C8
	__POINTW1FN _0x0,767
	CALL SUBOPT_0x6
; 0000 034A                         if(encomp==1){lcd_putsf("18.Black Line ");}
_0x1C8:
	CALL SUBOPT_0x41
	SBIW R26,1
	BRNE _0x1C9
	__POINTW1FN _0x0,782
	CALL SUBOPT_0x6
; 0000 034B                         if(encomp==0){lcd_putsf("18.Auto Line  ");}
_0x1C9:
	CALL SUBOPT_0x42
	SBIW R30,0
	BRNE _0x1CA
	__POINTW1FN _0x0,797
	CALL SUBOPT_0x6
; 0000 034C                         if(!s2){encomp=encomp+1;if (encomp>2){encomp=0;}}
_0x1CA:
	SBIC 0x13,2
	RJMP _0x1CB
	CALL SUBOPT_0x42
	ADIW R30,1
	CALL SUBOPT_0x43
	CALL SUBOPT_0x41
	SBIW R26,3
	BRLT _0x1CC
	LDI  R30,LOW(0)
	STS  _encomp,R30
	STS  _encomp+1,R30
_0x1CC:
; 0000 034D                         if(!s3){encomp=encomp-1;if (encomp<0){encomp=2;}}}
_0x1CB:
	SBIC 0x13,3
	RJMP _0x1CD
	CALL SUBOPT_0x42
	SBIW R30,1
	CALL SUBOPT_0x43
	LDS  R26,_encomp+1
	TST  R26
	BRPL _0x1CE
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL SUBOPT_0x43
_0x1CE:
_0x1CD:
; 0000 034E 
; 0000 034F         if(!s4){
_0x1C7:
	SBIC 0x13,4
	RJMP _0x1CF
; 0000 0350                 if(pulsa!=epulsa){epulsa=pulsa;}
	LDI  R26,LOW(_epulsa)
	LDI  R27,HIGH(_epulsa)
	CALL __EEPROMRDB
	LDS  R26,_pulsa
	CP   R30,R26
	BREQ _0x1D0
	LDS  R30,_pulsa
	LDI  R26,LOW(_epulsa)
	LDI  R27,HIGH(_epulsa)
	CALL __EEPROMWRB
; 0000 0351                 if(mode!=emode){emode=mode;}
_0x1D0:
	LDI  R26,LOW(_emode)
	LDI  R27,HIGH(_emode)
	CALL __EEPROMRDB
	LDS  R26,_mode
	CP   R30,R26
	BREQ _0x1D1
	LDS  R30,_mode
	LDI  R26,LOW(_emode)
	LDI  R27,HIGH(_emode)
	CALL __EEPROMWRB
; 0000 0352                 if(modekanan!=emodekanan){emodekanan=modekanan;}
_0x1D1:
	LDI  R26,LOW(_emodekanan)
	LDI  R27,HIGH(_emodekanan)
	CALL __EEPROMRDB
	LDS  R26,_modekanan
	CP   R30,R26
	BREQ _0x1D2
	LDS  R30,_modekanan
	LDI  R26,LOW(_emodekanan)
	LDI  R27,HIGH(_emodekanan)
	CALL __EEPROMWRB
; 0000 0353                 if(lc!=elc){elc=lc;}
_0x1D2:
	LDI  R26,LOW(_elc)
	LDI  R27,HIGH(_elc)
	CALL __EEPROMRDB
	MOVW R26,R12
	CALL SUBOPT_0x44
	BREQ _0x1D3
	MOV  R30,R12
	LDI  R26,LOW(_elc)
	LDI  R27,HIGH(_elc)
	CALL __EEPROMWRB
; 0000 0354                 if(lc1!=elc1){elc1=lc1;}
_0x1D3:
	LDI  R26,LOW(_elc1)
	LDI  R27,HIGH(_elc1)
	CALL __EEPROMRDB
	CALL SUBOPT_0x40
	CALL SUBOPT_0x44
	BREQ _0x1D4
	LDS  R30,_lc1
	LDI  R26,LOW(_elc1)
	LDI  R27,HIGH(_elc1)
	CALL __EEPROMWRB
; 0000 0355                 if(vc!=evc){evc=vc;}
_0x1D4:
	LDI  R26,LOW(_evc)
	LDI  R27,HIGH(_evc)
	CALL __EEPROMRDB
	LDS  R26,_vc
	LDS  R27,_vc+1
	CALL SUBOPT_0x44
	BREQ _0x1D5
	LDS  R30,_vc
	LDI  R26,LOW(_evc)
	LDI  R27,HIGH(_evc)
	CALL __EEPROMWRB
; 0000 0356                 if(max1!=emax1){emax1=max1;}
_0x1D5:
	LDI  R26,LOW(_emax1)
	LDI  R27,HIGH(_emax1)
	CALL __EEPROMRDB
	MOVW R26,R8
	CALL SUBOPT_0x44
	BREQ _0x1D6
	MOV  R30,R8
	LDI  R26,LOW(_emax1)
	LDI  R27,HIGH(_emax1)
	CALL __EEPROMWRB
; 0000 0357                 if(encomp!=eencomp){eencomp=encomp;}
_0x1D6:
	LDI  R26,LOW(_eencomp)
	LDI  R27,HIGH(_eencomp)
	CALL __EEPROMRDB
	CALL SUBOPT_0x41
	CALL SUBOPT_0x44
	BREQ _0x1D7
	LDS  R30,_encomp
	LDI  R26,LOW(_eencomp)
	LDI  R27,HIGH(_eencomp)
	CALL __EEPROMWRB
; 0000 0358                 saved();
_0x1D7:
	CALL _saved
; 0000 0359                 break;}
	RJMP _0x170
; 0000 035A delay_ms(150);
_0x1CF:
	CALL SUBOPT_0x2F
; 0000 035B }
	RJMP _0x16E
_0x170:
; 0000 035C }
_0x2080005:
	LD   R16,Y+
	LD   R17,Y+
	RET
;
;//-------------fungsi scansensor--------//
;void scansensor()
; 0000 0360 {
_scansensor:
; 0000 0361 if(sensitive[adc]<in){sen=0;sm=0;}
	CALL SUBOPT_0x45
	LD   R26,Z
	LDS  R30,_in
	CP   R26,R30
	BRSH _0x1D8
	LDI  R30,LOW(0)
	STS  _sen,R30
	STS  _sen+1,R30
	STS  _sm,R30
	STS  _sm+1,R30
; 0000 0362 dep=0;
_0x1D8:
	LDI  R30,LOW(0)
	STS  _dep,R30
	STS  _dep+1,R30
; 0000 0363 sam=0;
	STS  _sam,R30
; 0000 0364 sam1=0;
	STS  _sam1,R30
; 0000 0365         for(adc=0;adc<=6;adc++){
	STS  _adc,R30
_0x1DA:
	LDS  R26,_adc
	CPI  R26,LOW(0x7)
	BRLO PC+3
	JMP _0x1DB
; 0000 0366         in=read_adc(adc+1);
	LDS  R30,_adc
	SUBI R30,-LOW(1)
	ST   -Y,R30
	CALL SUBOPT_0x37
; 0000 0367         L=1;
	SBI  0x15,7
; 0000 0368         R=0;
	CBI  0x15,6
; 0000 0369 if(adc==0){
	LDS  R30,_adc
	CPI  R30,0
	BRNE _0x1E0
; 0000 036A         lcd_gotoxy(8,0);
	LDI  R30,LOW(8)
	CALL SUBOPT_0x46
; 0000 036B         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x1E1
; 0000 036C         dep=dep+64;
	CALL SUBOPT_0x48
	SUBI R30,LOW(-64)
	SBCI R31,HIGH(-64)
	CALL SUBOPT_0x49
; 0000 036D         lcd_putchar(0xff);sen=8;
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	CALL SUBOPT_0x4A
; 0000 036E         }
; 0000 036F         else lcd_putchar(0x5f);
	RJMP _0x1E2
_0x1E1:
	CALL SUBOPT_0x2
; 0000 0370         }
_0x1E2:
; 0000 0371 if(adc==1){
_0x1E0:
	LDS  R26,_adc
	CPI  R26,LOW(0x1)
	BRNE _0x1E3
; 0000 0372         lcd_gotoxy(6,0);
	LDI  R30,LOW(6)
	CALL SUBOPT_0x46
; 0000 0373         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x1E4
; 0000 0374         dep=dep+128;
	CALL SUBOPT_0x48
	SUBI R30,LOW(-128)
	SBCI R31,HIGH(-128)
	CALL SUBOPT_0x49
; 0000 0375         lcd_putchar(0xff);sen=6;
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	CALL SUBOPT_0x4A
; 0000 0376         }
; 0000 0377         else lcd_putchar(0x5f);
	RJMP _0x1E5
_0x1E4:
	CALL SUBOPT_0x2
; 0000 0378         }
_0x1E5:
; 0000 0379 if(adc==2){
_0x1E3:
	LDS  R26,_adc
	CPI  R26,LOW(0x2)
	BRNE _0x1E6
; 0000 037A         lcd_gotoxy(5,0);
	LDI  R30,LOW(5)
	CALL SUBOPT_0x46
; 0000 037B         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x1E7
; 0000 037C         dep=dep+256;
	CALL SUBOPT_0x48
	SUBI R30,LOW(-256)
	SBCI R31,HIGH(-256)
	CALL SUBOPT_0x49
; 0000 037D         lcd_putchar(0xff);sen=5;
	LDI  R30,LOW(5)
	LDI  R31,HIGH(5)
	CALL SUBOPT_0x4A
; 0000 037E         }
; 0000 037F         else lcd_putchar(0x5f);
	RJMP _0x1E8
_0x1E7:
	CALL SUBOPT_0x2
; 0000 0380         }
_0x1E8:
; 0000 0381 if(adc==3){
_0x1E6:
	LDS  R26,_adc
	CPI  R26,LOW(0x3)
	BRNE _0x1E9
; 0000 0382         lcd_gotoxy(4,0);
	LDI  R30,LOW(4)
	CALL SUBOPT_0x46
; 0000 0383         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x1EA
; 0000 0384         dep=dep+512;
	CALL SUBOPT_0x48
	SUBI R30,LOW(-512)
	SBCI R31,HIGH(-512)
	CALL SUBOPT_0x49
; 0000 0385         lcd_putchar(0xff);sen=4;
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	CALL SUBOPT_0x4A
; 0000 0386         }
; 0000 0387         else lcd_putchar(0x5f);
	RJMP _0x1EB
_0x1EA:
	CALL SUBOPT_0x2
; 0000 0388         }
_0x1EB:
; 0000 0389 if(adc==4){
_0x1E9:
	LDS  R26,_adc
	CPI  R26,LOW(0x4)
	BRNE _0x1EC
; 0000 038A         lcd_gotoxy(3,0);
	LDI  R30,LOW(3)
	CALL SUBOPT_0x46
; 0000 038B         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x1ED
; 0000 038C         dep=dep+1024;
	CALL SUBOPT_0x48
	SUBI R30,LOW(-1024)
	SBCI R31,HIGH(-1024)
	CALL SUBOPT_0x49
; 0000 038D         lcd_putchar(0xff);sen=3;
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL SUBOPT_0x4A
; 0000 038E         }
; 0000 038F         else lcd_putchar(0x5f);
	RJMP _0x1EE
_0x1ED:
	CALL SUBOPT_0x2
; 0000 0390         }
_0x1EE:
; 0000 0391 if(adc==5){
_0x1EC:
	LDS  R26,_adc
	CPI  R26,LOW(0x5)
	BRNE _0x1EF
; 0000 0392         lcd_gotoxy(2,0);
	LDI  R30,LOW(2)
	CALL SUBOPT_0x46
; 0000 0393         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x1F0
; 0000 0394         dep=dep+2024;
	CALL SUBOPT_0x48
	SUBI R30,LOW(-2024)
	SBCI R31,HIGH(-2024)
	CALL SUBOPT_0x49
; 0000 0395         lcd_putchar(0xff);sen=2;
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL SUBOPT_0x4A
; 0000 0396         }
; 0000 0397         else lcd_putchar(0x5f);
	RJMP _0x1F1
_0x1F0:
	CALL SUBOPT_0x2
; 0000 0398         }
_0x1F1:
; 0000 0399 if(adc==6){
_0x1EF:
	LDS  R26,_adc
	CPI  R26,LOW(0x6)
	BRNE _0x1F2
; 0000 039A         lcd_gotoxy(1,0);
	LDI  R30,LOW(1)
	CALL SUBOPT_0x46
; 0000 039B         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x1F3
; 0000 039C         sam=sam+2;
	LDS  R30,_sam
	SUBI R30,-LOW(2)
	STS  _sam,R30
; 0000 039D         lcd_putchar(0xff);sen=1;
	CALL SUBOPT_0x4
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CALL SUBOPT_0x4A
; 0000 039E         }
; 0000 039F         else lcd_putchar(0x5f);
	RJMP _0x1F4
_0x1F3:
	CALL SUBOPT_0x2
; 0000 03A0         }
_0x1F4:
; 0000 03A1 }
_0x1F2:
	CALL SUBOPT_0x4B
	RJMP _0x1DA
_0x1DB:
; 0000 03A2 for(adc=7;adc<=13;adc++){
	LDI  R30,LOW(7)
	STS  _adc,R30
_0x1F6:
	LDS  R26,_adc
	CPI  R26,LOW(0xE)
	BRLO PC+3
	JMP _0x1F7
; 0000 03A3         in=read_adc(adc-6);
	LDS  R30,_adc
	LDI  R31,0
	SBIW R30,6
	ST   -Y,R30
	CALL SUBOPT_0x37
; 0000 03A4         L=0;
	CBI  0x15,7
; 0000 03A5         R=1;
	SBI  0x15,6
; 0000 03A6 if(adc==7){
	LDS  R26,_adc
	CPI  R26,LOW(0x7)
	BRNE _0x1FC
; 0000 03A7         lcd_gotoxy(7,0);
	LDI  R30,LOW(7)
	CALL SUBOPT_0x46
; 0000 03A8         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x1FD
; 0000 03A9         dep=dep+32;
	CALL SUBOPT_0x48
	ADIW R30,32
	CALL SUBOPT_0x49
; 0000 03AA         lcd_putchar(0xff);sen=7;
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	CALL SUBOPT_0x4A
; 0000 03AB         }
; 0000 03AC         else lcd_putchar(0x5f);
	RJMP _0x1FE
_0x1FD:
	CALL SUBOPT_0x2
; 0000 03AD         }
_0x1FE:
; 0000 03AE if(adc==8){
_0x1FC:
	LDS  R26,_adc
	CPI  R26,LOW(0x8)
	BRNE _0x1FF
; 0000 03AF         lcd_gotoxy(9,0);
	LDI  R30,LOW(9)
	CALL SUBOPT_0x46
; 0000 03B0         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x200
; 0000 03B1         dep=dep+16;
	CALL SUBOPT_0x48
	ADIW R30,16
	CALL SUBOPT_0x49
; 0000 03B2         lcd_putchar(0xff);sen=9;
	LDI  R30,LOW(9)
	LDI  R31,HIGH(9)
	CALL SUBOPT_0x4A
; 0000 03B3         }
; 0000 03B4         else lcd_putchar(0x5f);
	RJMP _0x201
_0x200:
	CALL SUBOPT_0x2
; 0000 03B5         }
_0x201:
; 0000 03B6 if(adc==9){
_0x1FF:
	LDS  R26,_adc
	CPI  R26,LOW(0x9)
	BRNE _0x202
; 0000 03B7         lcd_gotoxy(10,0);
	LDI  R30,LOW(10)
	CALL SUBOPT_0x46
; 0000 03B8         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x203
; 0000 03B9         dep=dep+8;
	CALL SUBOPT_0x48
	ADIW R30,8
	CALL SUBOPT_0x49
; 0000 03BA         lcd_putchar(0xff);sen=10;
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL SUBOPT_0x4A
; 0000 03BB         }
; 0000 03BC         else lcd_putchar(0x5f);
	RJMP _0x204
_0x203:
	CALL SUBOPT_0x2
; 0000 03BD         }
_0x204:
; 0000 03BE if(adc==10){
_0x202:
	LDS  R26,_adc
	CPI  R26,LOW(0xA)
	BRNE _0x205
; 0000 03BF         lcd_gotoxy(11,0);
	LDI  R30,LOW(11)
	CALL SUBOPT_0x46
; 0000 03C0         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x206
; 0000 03C1         dep=dep+4;
	CALL SUBOPT_0x48
	ADIW R30,4
	CALL SUBOPT_0x49
; 0000 03C2         lcd_putchar(0xff);sen=11;
	LDI  R30,LOW(11)
	LDI  R31,HIGH(11)
	CALL SUBOPT_0x4A
; 0000 03C3         }
; 0000 03C4         else lcd_putchar(0x5f);
	RJMP _0x207
_0x206:
	CALL SUBOPT_0x2
; 0000 03C5         }
_0x207:
; 0000 03C6 if(adc==11){
_0x205:
	LDS  R26,_adc
	CPI  R26,LOW(0xB)
	BRNE _0x208
; 0000 03C7         lcd_gotoxy(12,0);
	LDI  R30,LOW(12)
	CALL SUBOPT_0x46
; 0000 03C8         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x209
; 0000 03C9         dep=dep+2;
	CALL SUBOPT_0x48
	ADIW R30,2
	CALL SUBOPT_0x49
; 0000 03CA         lcd_putchar(0xff);sen=12;
	LDI  R30,LOW(12)
	LDI  R31,HIGH(12)
	CALL SUBOPT_0x4A
; 0000 03CB         }
; 0000 03CC         else lcd_putchar(0x5f);
	RJMP _0x20A
_0x209:
	CALL SUBOPT_0x2
; 0000 03CD         }
_0x20A:
; 0000 03CE if(adc==12){
_0x208:
	LDS  R26,_adc
	CPI  R26,LOW(0xC)
	BRNE _0x20B
; 0000 03CF         lcd_gotoxy(13,0);
	LDI  R30,LOW(13)
	CALL SUBOPT_0x46
; 0000 03D0         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x20C
; 0000 03D1         dep=dep+1;
	CALL SUBOPT_0x48
	ADIW R30,1
	CALL SUBOPT_0x49
; 0000 03D2         lcd_putchar(0xff);sen=13;
	LDI  R30,LOW(13)
	LDI  R31,HIGH(13)
	CALL SUBOPT_0x4A
; 0000 03D3         }
; 0000 03D4         else lcd_putchar(0x5f);
	RJMP _0x20D
_0x20C:
	CALL SUBOPT_0x2
; 0000 03D5         }
_0x20D:
; 0000 03D6 if(adc==13){
_0x20B:
	LDS  R26,_adc
	CPI  R26,LOW(0xD)
	BRNE _0x20E
; 0000 03D7         lcd_gotoxy(14,0);
	LDI  R30,LOW(14)
	CALL SUBOPT_0x46
; 0000 03D8         if(in>sensitive[adc]){
	CALL SUBOPT_0x47
	BRSH _0x20F
; 0000 03D9         sam=sam+1;
	LDS  R30,_sam
	SUBI R30,-LOW(1)
	STS  _sam,R30
; 0000 03DA         lcd_putchar(0xff);sen=14;
	CALL SUBOPT_0x4
	LDI  R30,LOW(14)
	LDI  R31,HIGH(14)
	CALL SUBOPT_0x4A
; 0000 03DB         }
; 0000 03DC         else lcd_putchar(0x5f);
	RJMP _0x210
_0x20F:
	CALL SUBOPT_0x2
; 0000 03DD         }
_0x210:
; 0000 03DE }
_0x20E:
	CALL SUBOPT_0x4B
	RJMP _0x1F6
_0x1F7:
; 0000 03DF depan=dep;
	CALL SUBOPT_0x48
	CALL SUBOPT_0x4C
; 0000 03E0 samping=sam;
	STS  _samping,R30
; 0000 03E1 samping1=sam1;
	LDS  R30,_sam1
	STS  _samping1,R30
; 0000 03E2 }
	RET
;
;void stop_time(){
; 0000 03E4 void stop_time(){
_stop_time:
; 0000 03E5 pwm_off();
	CALL _pwm_off
; 0000 03E6 
; 0000 03E7 lcd_clear();
	CALL _lcd_clear
; 0000 03E8 while(1){
_0x211:
; 0000 03E9 lmp=1;
	SBI  0x18,3
; 0000 03EA aktif=0;
	CLT
	BLD  R2,0
; 0000 03EB output=1;
	SBI  0x12,1
; 0000 03EC time[start]=cacah;
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_time)
	SBCI R31,HIGH(-_time)
	LDS  R26,_cacah
	STD  Z+0,R26
; 0000 03ED  lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 03EE  sprintf(buff,"TIMER:%d COUNT:%d",time[start],start);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,812
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_time)
	SBCI R31,HIGH(-_time)
	LD   R30,Z
	CALL SUBOPT_0x17
	LDS  R30,_start
	CALL SUBOPT_0x17
	CALL SUBOPT_0x19
; 0000 03EF  lcd_puts(buff);
	CALL SUBOPT_0x16
	CALL _lcd_puts
; 0000 03F0  delay_ms(1);
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CALL SUBOPT_0x22
; 0000 03F1 motor(0,0);
	CALL SUBOPT_0xF
	ST   -Y,R31
	ST   -Y,R30
	CALL _motor
; 0000 03F2 if(time[start]>=timer[start])break;
	CALL SUBOPT_0x8
	CALL SUBOPT_0x4D
	BRLO _0x211
; 0000 03F3 }
; 0000 03F4 pwm_on();
	CALL _pwm_on
; 0000 03F5 output=0;
	CBI  0x12,1
; 0000 03F6 lcd_clear();
	RJMP _0x2080004
; 0000 03F7 }
;
;void no_line(){
; 0000 03F9 void no_line(){
_no_line:
; 0000 03FA lcd_clear();
	CALL _lcd_clear
; 0000 03FB lmp=1;
	SBI  0x18,3
; 0000 03FC  lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 03FD  sprintf(buff,"%03d<%02d>%03d %03d   ",max1,start,max1,tunda);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,830
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R8
	CALL SUBOPT_0x4E
	LDS  R30,_start
	CALL SUBOPT_0x17
	MOVW R30,R8
	CALL SUBOPT_0x4E
	LDS  R30,_tunda
	CALL SUBOPT_0x17
	CALL SUBOPT_0x4F
; 0000 03FE  lcd_puts(buff);
	CALL _lcd_puts
; 0000 03FF tunda=del[start];
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_del)
	SBCI R31,HIGH(-_del)
	LD   R30,Z
	STS  _tunda,R30
; 0000 0400 motor(max1,max1);
	ST   -Y,R9
	ST   -Y,R8
	ST   -Y,R9
	ST   -Y,R8
	CALL _motor
; 0000 0401 delay_ms(tunda);
	CALL SUBOPT_0x12
; 0000 0402 aktif=0;
	CLT
	BLD  R2,0
; 0000 0403 lcd_clear();
_0x2080004:
	CALL _lcd_clear
; 0000 0404 }
	RET
;//-------------fungsi rem--------//
;void ngerem()
; 0000 0407 {
_ngerem:
; 0000 0408 if(lc1>0){
	CALL SUBOPT_0x40
	CALL __CPW02
	BRGE _0x21D
; 0000 0409 mundur();
	CALL _mundur
; 0000 040A delay_ms(lc1);
	CALL SUBOPT_0x3E
	CALL SUBOPT_0x22
; 0000 040B }
; 0000 040C }
_0x21D:
	RET
;
;//-------------fungsi program yang di jalankan--------//
;void program(){
; 0000 040F void program(){
_program:
; 0000 0410 if(input==0)output=1;
	SBIC 0x10,0
	RJMP _0x21E
	SBI  0x12,1
; 0000 0411 else output=0;
	RJMP _0x221
_0x21E:
	CBI  0x12,1
; 0000 0412 lmp=0;
_0x221:
	CBI  0x18,3
; 0000 0413 time[start]=cacah;
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_time)
	SBCI R31,HIGH(-_time)
	LDS  R26,_cacah
	STD  Z+0,R26
; 0000 0414 if(time[start]<timer[start]&&mode==1){led=0;max1=speed[start];}
	CALL SUBOPT_0x8
	CALL SUBOPT_0x4D
	BRSH _0x227
	LDS  R26,_mode
	CPI  R26,LOW(0x1)
	BREQ _0x228
_0x227:
	RJMP _0x226
_0x228:
	CBI  0x12,7
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_speed)
	SBCI R31,HIGH(-_speed)
	LD   R8,Z
	CLR  R9
; 0000 0415 if(time[start]>=timer[start]&&mode==1){led=1;max1=speed1[start];}
_0x226:
	CALL SUBOPT_0x8
	CALL SUBOPT_0x4D
	BRLO _0x22C
	LDS  R26,_mode
	CPI  R26,LOW(0x1)
	BREQ _0x22D
_0x22C:
	RJMP _0x22B
_0x22D:
	SBI  0x12,7
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_speed1)
	SBCI R31,HIGH(-_speed1)
	LD   R8,Z
	CLR  R9
; 0000 0416 if(error>=-11&&error<=11){
_0x22B:
	CALL SUBOPT_0xC
	CPI  R26,LOW(0xFFF5)
	LDI  R30,HIGH(0xFFF5)
	CPC  R27,R30
	BRLT _0x231
	CALL SUBOPT_0xC
	SBIW R26,12
	BRLT _0x232
_0x231:
	RJMP _0x230
_0x232:
; 0000 0417 protec=0;
	LDI  R30,LOW(0)
	STS  _protec,R30
; 0000 0418 }
; 0000 0419 /*
; 0000 041A if(error<=-31||error>=31){
; 0000 041B lock=0;
; 0000 041C }
; 0000 041D 
; 0000 041E */
; 0000 041F if(error<=52 && error>=20){lock=0;}
_0x230:
	CALL SUBOPT_0xC
	SBIW R26,53
	BRGE _0x234
	CALL SUBOPT_0xC
	SBIW R26,20
	BRGE _0x235
_0x234:
	RJMP _0x233
_0x235:
	CLT
	BLD  R2,1
; 0000 0420 if(error<=-52 && error<=-20){lock=0;}
_0x233:
	CALL SUBOPT_0xC
	LDI  R30,LOW(65484)
	LDI  R31,HIGH(65484)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x237
	CALL SUBOPT_0xC
	LDI  R30,LOW(65516)
	LDI  R31,HIGH(65516)
	CP   R30,R26
	CPC  R31,R27
	BRGE _0x238
_0x237:
	RJMP _0x236
_0x238:
	CLT
	BLD  R2,1
; 0000 0421 
; 0000 0422 
; 0000 0423 scansensor();
_0x236:
	RCALL _scansensor
; 0000 0424 if(encomp==1){lmp=0;}
	CALL SUBOPT_0x41
	SBIW R26,1
	BRNE _0x239
	CBI  0x18,3
; 0000 0425 if(encomp==2){depan= 4095-dep;
_0x239:
	CALL SUBOPT_0x41
	SBIW R26,2
	BRNE _0x23C
	CALL SUBOPT_0x50
; 0000 0426             samping=13-sam;
	CALL SUBOPT_0x51
; 0000 0427             lmp=1;
; 0000 0428             }
; 0000 0429 if(invers==1&&encomp==0){
_0x23C:
	LDS  R26,_invers
	CPI  R26,LOW(0x1)
	BRNE _0x240
	CALL SUBOPT_0x41
	SBIW R26,0
	BREQ _0x241
_0x240:
	RJMP _0x23F
_0x241:
; 0000 042A             depan= 4095-dep;
	CALL SUBOPT_0x50
; 0000 042B             samping=13-sam;
	CALL SUBOPT_0x51
; 0000 042C             lmp=1;
; 0000 042D             }
; 0000 042E          else {
	RJMP _0x244
_0x23F:
; 0000 042F             invers=0;
	LDI  R30,LOW(0)
	STS  _invers,R30
; 0000 0430             inv = 0;
	STS  _inv,R30
; 0000 0431             lmp=0;
	CBI  0x18,3
; 0000 0432              }
_0x244:
; 0000 0433  switch (depan)  {
	CALL SUBOPT_0x52
; 0000 0434  case 0b111111111110:
	CPI  R30,LOW(0xFFE)
	LDI  R26,HIGH(0xFFE)
	CPC  R31,R26
	BREQ _0x24B
; 0000 0435  case 0b111111111100:
	CPI  R30,LOW(0xFFC)
	LDI  R26,HIGH(0xFFC)
	CPC  R31,R26
	BRNE _0x24C
_0x24B:
; 0000 0436  case 0b111111111101:
	RJMP _0x24D
_0x24C:
	CPI  R30,LOW(0xFFD)
	LDI  R26,HIGH(0xFFD)
	CPC  R31,R26
	BRNE _0x24E
_0x24D:
; 0000 0437  case 0b111111111001:
	RJMP _0x24F
_0x24E:
	CPI  R30,LOW(0xFF9)
	LDI  R26,HIGH(0xFF9)
	CPC  R31,R26
	BRNE _0x250
_0x24F:
; 0000 0438  case 0b111111111011:
	RJMP _0x251
_0x250:
	CPI  R30,LOW(0xFFB)
	LDI  R26,HIGH(0xFFB)
	CPC  R31,R26
	BRNE _0x252
_0x251:
; 0000 0439  case 0b111111110011:
	RJMP _0x253
_0x252:
	CPI  R30,LOW(0xFF3)
	LDI  R26,HIGH(0xFF3)
	CPC  R31,R26
	BRNE _0x254
_0x253:
; 0000 043A  case 0b111111110111:
	RJMP _0x255
_0x254:
	CPI  R30,LOW(0xFF7)
	LDI  R26,HIGH(0xFF7)
	CPC  R31,R26
	BRNE _0x256
_0x255:
; 0000 043B  case 0b111111100111:
	RJMP _0x257
_0x256:
	CPI  R30,LOW(0xFE7)
	LDI  R26,HIGH(0xFE7)
	CPC  R31,R26
	BRNE _0x258
_0x257:
; 0000 043C  case 0b111111101111:
	RJMP _0x259
_0x258:
	CPI  R30,LOW(0xFEF)
	LDI  R26,HIGH(0xFEF)
	CPC  R31,R26
	BRNE _0x25A
_0x259:
; 0000 043D  case 0b111111001111:
	RJMP _0x25B
_0x25A:
	CPI  R30,LOW(0xFCF)
	LDI  R26,HIGH(0xFCF)
	CPC  R31,R26
	BRNE _0x25C
_0x25B:
; 0000 043E  case 0b111111011111:
	RJMP _0x25D
_0x25C:
	CPI  R30,LOW(0xFDF)
	LDI  R26,HIGH(0xFDF)
	CPC  R31,R26
	BRNE _0x25E
_0x25D:
; 0000 043F 
; 0000 0440  case 0b111110011111:
	RJMP _0x25F
_0x25E:
	CPI  R30,LOW(0xF9F)
	LDI  R26,HIGH(0xF9F)
	CPC  R31,R26
	BRNE _0x260
_0x25F:
; 0000 0441 
; 0000 0442  case 0b111110111111:
	RJMP _0x261
_0x260:
	CPI  R30,LOW(0xFBF)
	LDI  R26,HIGH(0xFBF)
	CPC  R31,R26
	BRNE _0x262
_0x261:
; 0000 0443  case 0b111100111111:
	RJMP _0x263
_0x262:
	CPI  R30,LOW(0xF3F)
	LDI  R26,HIGH(0xF3F)
	CPC  R31,R26
	BRNE _0x264
_0x263:
; 0000 0444  case 0b111101111111:
	RJMP _0x265
_0x264:
	CPI  R30,LOW(0xF7F)
	LDI  R26,HIGH(0xF7F)
	CPC  R31,R26
	BRNE _0x266
_0x265:
; 0000 0445  case 0b111001111111:
	RJMP _0x267
_0x266:
	CPI  R30,LOW(0xE7F)
	LDI  R26,HIGH(0xE7F)
	CPC  R31,R26
	BRNE _0x268
_0x267:
; 0000 0446  case 0b111011111111:
	RJMP _0x269
_0x268:
	CPI  R30,LOW(0xEFF)
	LDI  R26,HIGH(0xEFF)
	CPC  R31,R26
	BRNE _0x26A
_0x269:
; 0000 0447  case 0b110011111111:
	RJMP _0x26B
_0x26A:
	CPI  R30,LOW(0xCFF)
	LDI  R26,HIGH(0xCFF)
	CPC  R31,R26
	BRNE _0x26C
_0x26B:
; 0000 0448  case 0b110111111111:
	RJMP _0x26D
_0x26C:
	CPI  R30,LOW(0xDFF)
	LDI  R26,HIGH(0xDFF)
	CPC  R31,R26
	BRNE _0x26E
_0x26D:
; 0000 0449  case 0b100111111111:
	RJMP _0x26F
_0x26E:
	CPI  R30,LOW(0x9FF)
	LDI  R26,HIGH(0x9FF)
	CPC  R31,R26
	BRNE _0x270
_0x26F:
; 0000 044A  case 0b101111111111:
	RJMP _0x271
_0x270:
	CPI  R30,LOW(0xBFF)
	LDI  R26,HIGH(0xBFF)
	CPC  R31,R26
	BRNE _0x272
_0x271:
; 0000 044B  case 0b001111111111:
	RJMP _0x273
_0x272:
	CPI  R30,LOW(0x3FF)
	LDI  R26,HIGH(0x3FF)
	CPC  R31,R26
	BRNE _0x274
_0x273:
; 0000 044C  case 0b011111111111:
	RJMP _0x275
_0x274:
	CPI  R30,LOW(0x7FF)
	LDI  R26,HIGH(0x7FF)
	CPC  R31,R26
	BRNE _0x276
_0x275:
; 0000 044D  if (inv==0&&encomp==0)invers++;
	LDS  R26,_inv
	CPI  R26,LOW(0x0)
	BRNE _0x278
	CALL SUBOPT_0x41
	SBIW R26,0
	BREQ _0x279
_0x278:
	RJMP _0x277
_0x279:
	LDS  R30,_invers
	SUBI R30,-LOW(1)
	STS  _invers,R30
; 0000 044E  else inv = 0; break;
	RJMP _0x27A
_0x277:
	LDI  R30,LOW(0)
	STS  _inv,R30
_0x27A:
	RJMP _0x249
; 0000 044F  case 0b000000000001:        error=-31;   break;
_0x276:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x27B
	LDI  R30,LOW(65505)
	LDI  R31,HIGH(65505)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0450  case 0b000000000011:       error=-27;   break;
_0x27B:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x27C
	LDI  R30,LOW(65509)
	LDI  R31,HIGH(65509)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0451  case 0b000000000010:       error=-25;   break;
_0x27C:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x27D
	LDI  R30,LOW(65511)
	LDI  R31,HIGH(65511)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0452  case 0b000000000110:       error=-21;   break;
_0x27D:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x27E
	LDI  R30,LOW(65515)
	LDI  R31,HIGH(65515)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0453  case 0b000000000100:       error=-17;   break;
_0x27E:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x27F
	LDI  R30,LOW(65519)
	LDI  R31,HIGH(65519)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0454  case 0b000000001100:       error=-15;   break;
_0x27F:
	CPI  R30,LOW(0xC)
	LDI  R26,HIGH(0xC)
	CPC  R31,R26
	BRNE _0x280
	LDI  R30,LOW(65521)
	LDI  R31,HIGH(65521)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0455  case 0b000000001000:       error=-11;   break;
_0x280:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x281
	LDI  R30,LOW(65525)
	LDI  R31,HIGH(65525)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0456  case 0b000000011000:       error=-7;   break;
_0x281:
	CPI  R30,LOW(0x18)
	LDI  R26,HIGH(0x18)
	CPC  R31,R26
	BRNE _0x282
	LDI  R30,LOW(65529)
	LDI  R31,HIGH(65529)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0457  case 0b000000010000:       error=-5;   break;
_0x282:
	CPI  R30,LOW(0x10)
	LDI  R26,HIGH(0x10)
	CPC  R31,R26
	BRNE _0x283
	LDI  R30,LOW(65531)
	LDI  R31,HIGH(65531)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0458  case 0b000001010000:       error=-3;   break; //di balik
_0x283:
	CPI  R30,LOW(0x50)
	LDI  R26,HIGH(0x50)
	CPC  R31,R26
	BRNE _0x284
	LDI  R30,LOW(65533)
	LDI  R31,HIGH(65533)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0459  case 0b000001000000:       error=-1;   break; //di balik
_0x284:
	CPI  R30,LOW(0x40)
	LDI  R26,HIGH(0x40)
	CPC  R31,R26
	BRNE _0x285
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 045A  case 0b000001100000:       error=0;    break;
_0x285:
	CPI  R30,LOW(0x60)
	LDI  R26,HIGH(0x60)
	CPC  R31,R26
	BRNE _0x286
	CALL SUBOPT_0x54
	RJMP _0x249
; 0000 045B 
; 0000 045C  case 0b000000100000:       error=1;    break; //di balik
_0x286:
	CPI  R30,LOW(0x20)
	LDI  R26,HIGH(0x20)
	CPC  R31,R26
	BRNE _0x287
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 045D  case 0b000010100000:       error=3;    break; //di balik
_0x287:
	CPI  R30,LOW(0xA0)
	LDI  R26,HIGH(0xA0)
	CPC  R31,R26
	BRNE _0x288
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 045E  case 0b000010000000:       error=5;    break;
_0x288:
	CPI  R30,LOW(0x80)
	LDI  R26,HIGH(0x80)
	CPC  R31,R26
	BRNE _0x289
	LDI  R30,LOW(5)
	LDI  R31,HIGH(5)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 045F  case 0b000110000000:       error=7;    break;
_0x289:
	CPI  R30,LOW(0x180)
	LDI  R26,HIGH(0x180)
	CPC  R31,R26
	BRNE _0x28A
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0460  case 0b000100000000:       error=11;   break;
_0x28A:
	CPI  R30,LOW(0x100)
	LDI  R26,HIGH(0x100)
	CPC  R31,R26
	BRNE _0x28B
	LDI  R30,LOW(11)
	LDI  R31,HIGH(11)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0461  case 0b001100000000:       error=15;   break;
_0x28B:
	CPI  R30,LOW(0x300)
	LDI  R26,HIGH(0x300)
	CPC  R31,R26
	BRNE _0x28C
	LDI  R30,LOW(15)
	LDI  R31,HIGH(15)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0462  case 0b001000000000:       error=17;   break;
_0x28C:
	CPI  R30,LOW(0x200)
	LDI  R26,HIGH(0x200)
	CPC  R31,R26
	BRNE _0x28D
	LDI  R30,LOW(17)
	LDI  R31,HIGH(17)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0463  case 0b011000000000:       error=21;   break;
_0x28D:
	CPI  R30,LOW(0x600)
	LDI  R26,HIGH(0x600)
	CPC  R31,R26
	BRNE _0x28E
	LDI  R30,LOW(21)
	LDI  R31,HIGH(21)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0464  case 0b010000000000:       error=25;   break;
_0x28E:
	CPI  R30,LOW(0x400)
	LDI  R26,HIGH(0x400)
	CPC  R31,R26
	BRNE _0x28F
	LDI  R30,LOW(25)
	LDI  R31,HIGH(25)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0465  case 0b110000000000:       error=27;   break;
_0x28F:
	CPI  R30,LOW(0xC00)
	LDI  R26,HIGH(0xC00)
	CPC  R31,R26
	BRNE _0x290
	LDI  R30,LOW(27)
	LDI  R31,HIGH(27)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0466  case 0b100000000000:       error=31;   break;
_0x290:
	CPI  R30,LOW(0x800)
	LDI  R26,HIGH(0x800)
	CPC  R31,R26
	BRNE _0x291
	LDI  R30,LOW(31)
	LDI  R31,HIGH(31)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0467 
; 0000 0468  case 0b000000000111:       error=-21;    break;
_0x291:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x292
	LDI  R30,LOW(65515)
	LDI  R31,HIGH(65515)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0469  case 0b000000001111:       error=-17;    break;
_0x292:
	CPI  R30,LOW(0xF)
	LDI  R26,HIGH(0xF)
	CPC  R31,R26
	BRNE _0x293
	LDI  R30,LOW(65519)
	LDI  R31,HIGH(65519)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 046A  case 0b000000001110:       error=-15;    break;
_0x293:
	CPI  R30,LOW(0xE)
	LDI  R26,HIGH(0xE)
	CPC  R31,R26
	BRNE _0x294
	LDI  R30,LOW(65521)
	LDI  R31,HIGH(65521)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 046B  case 0b000000011110:       error=-11;    break;
_0x294:
	CPI  R30,LOW(0x1E)
	LDI  R26,HIGH(0x1E)
	CPC  R31,R26
	BRNE _0x295
	LDI  R30,LOW(65525)
	LDI  R31,HIGH(65525)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 046C  case 0b000000011100:       error=-7;     break;
_0x295:
	CPI  R30,LOW(0x1C)
	LDI  R26,HIGH(0x1C)
	CPC  R31,R26
	BRNE _0x296
	LDI  R30,LOW(65529)
	LDI  R31,HIGH(65529)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 046D  case 0b000001011100:       error=-5;     break; //di balik
_0x296:
	CPI  R30,LOW(0x5C)
	LDI  R26,HIGH(0x5C)
	CPC  R31,R26
	BRNE _0x297
	LDI  R30,LOW(65531)
	LDI  R31,HIGH(65531)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 046E  case 0b000001011000:       error=-3;     break; //di balik
_0x297:
	CPI  R30,LOW(0x58)
	LDI  R26,HIGH(0x58)
	CPC  R31,R26
	BRNE _0x298
	LDI  R30,LOW(65533)
	LDI  R31,HIGH(65533)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 046F  case 0b000001110000:
_0x298:
	CPI  R30,LOW(0x70)
	LDI  R26,HIGH(0x70)
	CPC  R31,R26
	BREQ _0x29A
; 0000 0470  case 0b111001101111:
	CPI  R30,LOW(0xE6F)
	LDI  R26,HIGH(0xE6F)
	CPC  R31,R26
	BRNE _0x29B
_0x29A:
; 0000 0471  case 0b111011100111:
	RJMP _0x29C
_0x29B:
	CPI  R30,LOW(0xEE7)
	LDI  R26,HIGH(0xEE7)
	CPC  R31,R26
	BRNE _0x29D
_0x29C:
; 0000 0472  case 0b111111111111:
	RJMP _0x29E
_0x29D:
	CPI  R30,LOW(0xFFF)
	LDI  R26,HIGH(0xFFF)
	CPC  R31,R26
	BRNE _0x29F
_0x29E:
; 0000 0473  case 0b011111111110:
	RJMP _0x2A0
_0x29F:
	CPI  R30,LOW(0x7FE)
	LDI  R26,HIGH(0x7FE)
	CPC  R31,R26
	BRNE _0x2A1
_0x2A0:
; 0000 0474  case 0b001111111100:
	RJMP _0x2A2
_0x2A1:
	CPI  R30,LOW(0x3FC)
	LDI  R26,HIGH(0x3FC)
	CPC  R31,R26
	BRNE _0x2A3
_0x2A2:
; 0000 0475  case 0b000111111000:
	RJMP _0x2A4
_0x2A3:
	CPI  R30,LOW(0x1F8)
	LDI  R26,HIGH(0x1F8)
	CPC  R31,R26
	BRNE _0x2A5
_0x2A4:
; 0000 0476  case 0b000011100000:
	RJMP _0x2A6
_0x2A5:
	CPI  R30,LOW(0xE0)
	LDI  R26,HIGH(0xE0)
	CPC  R31,R26
	BRNE _0x2A7
_0x2A6:
; 0000 0477  case 0b000011110000:       error=0;     break;
	RJMP _0x2A8
_0x2A7:
	CPI  R30,LOW(0xF0)
	LDI  R26,HIGH(0xF0)
	CPC  R31,R26
	BRNE _0x2A9
_0x2A8:
	CALL SUBOPT_0x54
	RJMP _0x249
; 0000 0478 
; 0000 0479  case 0b000110100000:       error=3;     break; //di balik
_0x2A9:
	CPI  R30,LOW(0x1A0)
	LDI  R26,HIGH(0x1A0)
	CPC  R31,R26
	BRNE _0x2AA
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 047A  case 0b001110100000:       error=5;     break; //di balik
_0x2AA:
	CPI  R30,LOW(0x3A0)
	LDI  R26,HIGH(0x3A0)
	CPC  R31,R26
	BRNE _0x2AB
	LDI  R30,LOW(5)
	LDI  R31,HIGH(5)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 047B  case 0b001110000000:       error=7;     break;
_0x2AB:
	CPI  R30,LOW(0x380)
	LDI  R26,HIGH(0x380)
	CPC  R31,R26
	BRNE _0x2AC
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 047C  case 0b011110000000:       error=11;    break;
_0x2AC:
	CPI  R30,LOW(0x780)
	LDI  R26,HIGH(0x780)
	CPC  R31,R26
	BRNE _0x2AD
	LDI  R30,LOW(11)
	LDI  R31,HIGH(11)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 047D  case 0b011100000000:       error=15;    break;
_0x2AD:
	CPI  R30,LOW(0x700)
	LDI  R26,HIGH(0x700)
	CPC  R31,R26
	BRNE _0x2AE
	LDI  R30,LOW(15)
	LDI  R31,HIGH(15)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 047E  case 0b111100000000:       error=17;    break;
_0x2AE:
	CPI  R30,LOW(0xF00)
	LDI  R26,HIGH(0xF00)
	CPC  R31,R26
	BRNE _0x2AF
	LDI  R30,LOW(17)
	LDI  R31,HIGH(17)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 047F  case 0b111000000000:       error=21;    break;
_0x2AF:
	CPI  R30,LOW(0xE00)
	LDI  R26,HIGH(0xE00)
	CPC  R31,R26
	BRNE _0x2B0
	LDI  R30,LOW(21)
	LDI  R31,HIGH(21)
	CALL SUBOPT_0x53
	RJMP _0x249
; 0000 0480 
; 0000 0481  case 0b000000000000:
_0x2B0:
	SBIW R30,0
	BREQ PC+3
	JMP _0x249
; 0000 0482 
; 0000 0483 // Right sharp
; 0000 0484  if(scan==0){
	LDS  R30,_scan
	CPI  R30,0
	BRNE _0x2B2
; 0000 0485  if(samping==0b01){
	LDS  R26,_samping
	CPI  R26,LOW(0x1)
	BRNE _0x2B3
; 0000 0486  if(depan==0){
	CALL SUBOPT_0x52
	SBIW R30,0
	BRNE _0x2B4
; 0000 0487  if(lock==0)ngerem();
	SBRS R2,1
	RCALL _ngerem
; 0000 0488  lock=1;
	CALL SUBOPT_0x55
; 0000 0489  error=52;
; 0000 048A  kananlancip();
; 0000 048B  scan=1;
; 0000 048C  }
; 0000 048D  }
_0x2B4:
; 0000 048E 
; 0000 048F  if(depan==0b000000000001){
_0x2B3:
	CALL SUBOPT_0x56
	SBIW R26,1
	BRNE _0x2B6
; 0000 0490  if(lock==0)ngerem();
	SBRS R2,1
	RCALL _ngerem
; 0000 0491  lock=1;
	CALL SUBOPT_0x55
; 0000 0492  error=52;
; 0000 0493  kananlancip();
; 0000 0494  scan=1;
; 0000 0495  }
; 0000 0496 
; 0000 0497 
; 0000 0498  if(depan==0b000000000010){
_0x2B6:
	CALL SUBOPT_0x56
	SBIW R26,2
	BRNE _0x2B8
; 0000 0499  if(lock==0)ngerem();
	SBRS R2,1
	RCALL _ngerem
; 0000 049A  lock=1;
	CALL SUBOPT_0x55
; 0000 049B  error=52;
; 0000 049C  kananlancip();
; 0000 049D  scan=1;
; 0000 049E  }
; 0000 049F 
; 0000 04A0  /*
; 0000 04A1  if(samping==0b1100){
; 0000 04A2  if(depan==0){
; 0000 04A3  if(lock==0)ngerem();
; 0000 04A4  lock=1;
; 0000 04A5  error=52;
; 0000 04A6  kananlancip();
; 0000 04A7  scan=1;
; 0000 04A8  }
; 0000 04A9  }
; 0000 04AA  */
; 0000 04AB  // lancip kiri
; 0000 04AC  if(samping==0b10){
_0x2B8:
	LDS  R26,_samping
	CPI  R26,LOW(0x2)
	BRNE _0x2BA
; 0000 04AD   if(depan==0){
	CALL SUBOPT_0x52
	SBIW R30,0
	BRNE _0x2BB
; 0000 04AE   if(lock==0)ngerem();
	SBRS R2,1
	RCALL _ngerem
; 0000 04AF   lock=1;
	CALL SUBOPT_0x57
; 0000 04B0   error=-52;
; 0000 04B1   kirilancip();
; 0000 04B2   scan=1;
; 0000 04B3   }
; 0000 04B4   }
_0x2BB:
; 0000 04B5 
; 0000 04B6 
; 0000 04B7   if(depan==0b010000000000){
_0x2BA:
	CALL SUBOPT_0x56
	CPI  R26,LOW(0x400)
	LDI  R30,HIGH(0x400)
	CPC  R27,R30
	BRNE _0x2BD
; 0000 04B8   if(lock==0)ngerem();
	SBRS R2,1
	RCALL _ngerem
; 0000 04B9   lock=1;
	CALL SUBOPT_0x57
; 0000 04BA   error=-52;
; 0000 04BB   kirilancip();
; 0000 04BC   scan=1;
; 0000 04BD   }
; 0000 04BE 
; 0000 04BF   if(depan==0b100000000000){
_0x2BD:
	CALL SUBOPT_0x56
	CPI  R26,LOW(0x800)
	LDI  R30,HIGH(0x800)
	CPC  R27,R30
	BRNE _0x2BF
; 0000 04C0   if(lock==0)ngerem();
	SBRS R2,1
	RCALL _ngerem
; 0000 04C1   lock=1;
	CALL SUBOPT_0x57
; 0000 04C2   error=-52;
; 0000 04C3   kirilancip();
; 0000 04C4   scan=1;
; 0000 04C5   }
; 0000 04C6 
; 0000 04C7 
; 0000 04C8 
; 0000 04C9   }
_0x2BF:
; 0000 04CA 
; 0000 04CB 
; 0000 04CC 
; 0000 04CD 
; 0000 04CE   }
_0x2B2:
_0x249:
; 0000 04CF   if(samping1<=0){xcc=0;}
	LDS  R26,_samping1
	CPI  R26,0
	BRNE _0x2C1
	LDI  R30,LOW(0)
	STS  _xcc,R30
	STS  _xcc+1,R30
; 0000 04D0   if(samping1>0||cut[start+1]==5){
_0x2C1:
	LDS  R26,_samping1
	CPI  R26,0
	BRNE _0x2C3
	CALL SUBOPT_0x8
	__ADDW1MN _cut,1
	LD   R26,Z
	CPI  R26,LOW(0x5)
	BREQ _0x2C3
	RJMP _0x2C2
_0x2C3:
; 0000 04D1         if(protec==0&&mode==1){
	LDS  R26,_protec
	CPI  R26,LOW(0x0)
	BRNE _0x2C6
	LDS  R26,_mode
	CPI  R26,LOW(0x1)
	BREQ _0x2C7
_0x2C6:
	RJMP _0x2C5
_0x2C7:
; 0000 04D2         if(time[start]>=timer[start]){
	CALL SUBOPT_0x8
	CALL SUBOPT_0x4D
	BRSH PC+3
	JMP _0x2C8
; 0000 04D3         aktif=1;cacah=0;
	SET
	BLD  R2,0
	LDI  R30,LOW(0)
	STS  _cacah,R30
; 0000 04D4         if(pass>0)start++;
	LDS  R26,_pass
	LDS  R27,_pass+1
	CALL __CPW02
	BRGE _0x2C9
	LDS  R30,_start
	SUBI R30,-LOW(1)
	STS  _start,R30
; 0000 04D5         counting=cut[start];
_0x2C9:
	CALL SUBOPT_0x8
	SUBI R30,LOW(-_cut)
	SBCI R31,HIGH(-_cut)
	LD   R30,Z
	STS  _counting,R30
; 0000 04D6         if(counting==1||counting==2||counting==3||counting==4||counting==5){
	LDS  R26,_counting
	CPI  R26,LOW(0x1)
	BREQ _0x2CB
	CPI  R26,LOW(0x2)
	BREQ _0x2CB
	CPI  R26,LOW(0x3)
	BREQ _0x2CB
	CPI  R26,LOW(0x4)
	BREQ _0x2CB
	CPI  R26,LOW(0x5)
	BRNE _0x2CA
_0x2CB:
; 0000 04D7         if(lc1>0){
	CALL SUBOPT_0x40
	CALL __CPW02
	BRGE _0x2CD
; 0000 04D8         if(xcc<2)xcc++;
	LDS  R26,_xcc
	LDS  R27,_xcc+1
	SBIW R26,2
	BRGE _0x2CE
	LDI  R26,LOW(_xcc)
	LDI  R27,HIGH(_xcc)
	CALL SUBOPT_0x58
; 0000 04D9         if(xcc==1){
_0x2CE:
	LDS  R26,_xcc
	LDS  R27,_xcc+1
	SBIW R26,1
	BRNE _0x2CF
; 0000 04DA         lmp=0;
	CBI  0x18,3
; 0000 04DB         ngerem();
	RCALL _ngerem
; 0000 04DC         aktif=0;
	CLT
	BLD  R2,0
; 0000 04DD         }
; 0000 04DE         }
_0x2CF:
; 0000 04DF         }
_0x2CD:
; 0000 04E0         if(counting==2){kanan();}
_0x2CA:
	LDS  R26,_counting
	CPI  R26,LOW(0x2)
	BRNE _0x2D2
	CALL _kanan
; 0000 04E1         if(counting==3){kiri();}
_0x2D2:
	LDS  R26,_counting
	CPI  R26,LOW(0x3)
	BRNE _0x2D3
	CALL _kiri
; 0000 04E2         if(counting==4){no_line();}
_0x2D3:
	LDS  R26,_counting
	CPI  R26,LOW(0x4)
	BRNE _0x2D4
	RCALL _no_line
; 0000 04E3         if(counting==5){stop_time();}
_0x2D4:
	LDS  R26,_counting
	CPI  R26,LOW(0x5)
	BRNE _0x2D5
	RCALL _stop_time
; 0000 04E4         }
_0x2D5:
; 0000 04E5         protec=1;
_0x2C8:
	LDI  R30,LOW(1)
	STS  _protec,R30
; 0000 04E6         }
; 0000 04E7         }
_0x2C5:
; 0000 04E8 
; 0000 04E9 // rumus PID
; 0000 04EA rumus_pid();
_0x2C2:
	CALL _rumus_pid
; 0000 04EB if(max1==0)motor(0,0);
	MOV  R0,R8
	OR   R0,R9
	BRNE _0x2D6
	CALL SUBOPT_0xF
	ST   -Y,R31
	ST   -Y,R30
	RJMP _0x37B
; 0000 04EC else motor(lpwm,rpwm);
_0x2D6:
	ST   -Y,R7
	ST   -Y,R6
	ST   -Y,R5
	ST   -Y,R4
_0x37B:
	CALL _motor
; 0000 04ED if(error>=-11&&error<=11){
	CALL SUBOPT_0xC
	CPI  R26,LOW(0xFFF5)
	LDI  R30,HIGH(0xFFF5)
	CPC  R27,R30
	BRLT _0x2D9
	CALL SUBOPT_0xC
	SBIW R26,12
	BRLT _0x2DA
_0x2D9:
	RJMP _0x2D8
_0x2DA:
; 0000 04EE  scan=0;aktif=0;
	LDI  R30,LOW(0)
	STS  _scan,R30
	CLT
	BLD  R2,0
; 0000 04EF }
; 0000 04F0 else if ((error>50)||(error<-50)){
	RJMP _0x2DB
_0x2D8:
	CALL SUBOPT_0xC
	SBIW R26,51
	BRGE _0x2DD
	CALL SUBOPT_0xC
	CPI  R26,LOW(0xFFCE)
	LDI  R30,HIGH(0xFFCE)
	CPC  R27,R30
	BRGE _0x2DC
_0x2DD:
; 0000 04F1  scan=1;
	LDI  R30,LOW(1)
	STS  _scan,R30
; 0000 04F2         if(error==52)kananlancip();
	CALL SUBOPT_0xC
	SBIW R26,52
	BRNE _0x2DF
	CALL _kananlancip
; 0000 04F3         else if(error==-52)kirilancip();
	RJMP _0x2E0
_0x2DF:
	CALL SUBOPT_0xC
	CPI  R26,LOW(0xFFCC)
	LDI  R30,HIGH(0xFFCC)
	CPC  R27,R30
	BRNE _0x2E1
	CALL _kirilancip
; 0000 04F4  }
_0x2E1:
_0x2E0:
; 0000 04F5  lcd_gotoxy(0,1);
_0x2DC:
_0x2DB:
	CALL SUBOPT_0x13
; 0000 04F6  //sprintf(buff,"%03d<%02d>%03d %03d   ",lpwm,start,rpwm,cacah);
; 0000 04F7  sprintf(buff,"%03d <%02d> %03d %03d   ",lpwm,error,rpwm,cacah);
	CALL SUBOPT_0x16
	__POINTW1FN _0x0,853
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R6
	CALL SUBOPT_0x4E
	CALL SUBOPT_0x9
	CALL SUBOPT_0x4E
	MOVW R30,R4
	CALL SUBOPT_0x4E
	LDS  R30,_cacah
	CALL SUBOPT_0x17
	CALL SUBOPT_0x4F
; 0000 04F8  lcd_puts(buff);
	CALL _lcd_puts
; 0000 04F9  }
	RET
;// Declare your global variables here
;
;
;
;
;
;
;
;void pilihStart(){
; 0000 0502 void pilihStart(){
_pilihStart:
; 0000 0503 while(1){
_0x2E2:
; 0000 0504 if(!s6){pilih_start=pilih_start+1;delay_ms(200);}
	SBIC 0x13,5
	RJMP _0x2E5
	LDS  R30,_pilih_start
	LDS  R31,_pilih_start+1
	ADIW R30,1
	STS  _pilih_start,R30
	STS  _pilih_start+1,R31
	CALL SUBOPT_0x59
; 0000 0505             if(pilih_start=4){pilih_start=0;}
_0x2E5:
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	STS  _pilih_start,R30
	STS  _pilih_start+1,R31
	SBIW R30,0
	BREQ _0x2E6
	LDI  R30,LOW(0)
	STS  _pilih_start,R30
	STS  _pilih_start+1,R30
; 0000 0506                 if(pilih_start==0){
_0x2E6:
	LDS  R30,_pilih_start
	LDS  R31,_pilih_start+1
	SBIW R30,0
	BRNE _0x2E7
; 0000 0507                     lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0508                     lcd_putsf(".Start=A");
	__POINTW1FN _0x0,878
	CALL SUBOPT_0x6
; 0000 0509                     lcd_gotoxy(9,1);
	CALL SUBOPT_0x5A
; 0000 050A                     lcd_putsf(" CP=1");
	CALL SUBOPT_0x5B
; 0000 050B                 }
; 0000 050C 
; 0000 050D                 if(pilih_start==1){
_0x2E7:
	CALL SUBOPT_0x5C
	SBIW R26,1
	BRNE _0x2E8
; 0000 050E                     lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 050F                     lcd_putsf(".Start=B");
	__POINTW1FN _0x0,893
	CALL SUBOPT_0x6
; 0000 0510                     lcd_gotoxy(9,1);
	CALL SUBOPT_0x5A
; 0000 0511                     lcd_putsf(" CP=1");
	CALL SUBOPT_0x5B
; 0000 0512                 }
; 0000 0513 
; 0000 0514                 if(pilih_start==2){
_0x2E8:
	CALL SUBOPT_0x5C
	SBIW R26,2
	BRNE _0x2E9
; 0000 0515                     lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0516                     lcd_putsf(".Start=C");
	__POINTW1FN _0x0,902
	CALL SUBOPT_0x6
; 0000 0517                     lcd_gotoxy(9,1);
	CALL SUBOPT_0x5A
; 0000 0518                     lcd_putsf(" CP=1");
	CALL SUBOPT_0x5B
; 0000 0519                 }
; 0000 051A 
; 0000 051B                 if(pilih_start==3){
_0x2E9:
	CALL SUBOPT_0x5C
	SBIW R26,3
	BRNE _0x2EA
; 0000 051C                     lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 051D                     lcd_putsf(".Start=D");
	__POINTW1FN _0x0,911
	CALL SUBOPT_0x6
; 0000 051E                     lcd_gotoxy(9,1);
	CALL SUBOPT_0x5A
; 0000 051F                     lcd_putsf(" CP=1");
	CALL SUBOPT_0x5B
; 0000 0520                 }
; 0000 0521 }
_0x2EA:
	RJMP _0x2E2
; 0000 0522 
; 0000 0523 }
;
;
;
;
;
;
;void main(void)
; 0000 052B {
_main:
; 0000 052C int p_start=0;
; 0000 052D 
; 0000 052E PORTA=0xFF;
;	p_start -> R16,R17
	__GETWRN 16,17,0
	LDI  R30,LOW(255)
	OUT  0x1B,R30
; 0000 052F DDRA=0x00;
	LDI  R30,LOW(0)
	OUT  0x1A,R30
; 0000 0530 PORTB=0x00;
	OUT  0x18,R30
; 0000 0531 DDRB=0x08;
	LDI  R30,LOW(8)
	OUT  0x17,R30
; 0000 0532 PORTC=0x3F;
	LDI  R30,LOW(63)
	OUT  0x15,R30
; 0000 0533 DDRC=0xC0;
	LDI  R30,LOW(192)
	OUT  0x14,R30
; 0000 0534 PORTD=0x81;
	LDI  R30,LOW(129)
	OUT  0x12,R30
; 0000 0535 DDRD=0xFE;
	LDI  R30,LOW(254)
	OUT  0x11,R30
; 0000 0536 TCCR0=0x05;
	LDI  R30,LOW(5)
	OUT  0x33,R30
; 0000 0537 TIMSK=0x01;
	LDI  R30,LOW(1)
	OUT  0x39,R30
; 0000 0538 ADCSRA=0x84;
	LDI  R30,LOW(132)
	OUT  0x6,R30
; 0000 0539 lcd_init(16);
	LDI  R30,LOW(16)
	ST   -Y,R30
	CALL _lcd_init
; 0000 053A lcd_gotoxy(2,0);
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	CALL _lcd_gotoxy
; 0000 053B lcd_puts("  Welcome To");
	__POINTW1MN _0x2EB,0
	ST   -Y,R31
	ST   -Y,R30
	CALL _lcd_puts
; 0000 053C delay_ms(200);
	CALL SUBOPT_0x59
; 0000 053D lcd_gotoxy(3,1);
	LDI  R30,LOW(3)
	ST   -Y,R30
	CALL SUBOPT_0x1
; 0000 053E lcd_puts(" TEUM CORP.");
	__POINTW1MN _0x2EB,13
	ST   -Y,R31
	ST   -Y,R30
	CALL _lcd_puts
; 0000 053F pwm_off();
	CALL SUBOPT_0x1D
; 0000 0540 stop();
; 0000 0541 delay_ms(1000);
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL SUBOPT_0x22
; 0000 0542 
; 0000 0543 if(!s3){
	SBIC 0x13,3
	RJMP _0x2EC
; 0000 0544 int n=0;
; 0000 0545 lmp=1;
	SBIW R28,2
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
;	n -> Y+0
	SBI  0x18,3
; 0000 0546 lcd_clear();
	CALL _lcd_clear
; 0000 0547 delay_ms(500);
	CALL SUBOPT_0x14
; 0000 0548 
; 0000 0549 while(1){
_0x2EF:
; 0000 054A 
; 0000 054B if(!s3){n=n+1;lcd_clear();delay_ms(200);}
	SBIC 0x13,3
	RJMP _0x2F2
	CALL SUBOPT_0x3A
	CALL SUBOPT_0x59
; 0000 054C if(n==2){n=0;}
_0x2F2:
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,2
	BRNE _0x2F3
	LDI  R30,LOW(0)
	STD  Y+0,R30
	STD  Y+0+1,R30
; 0000 054D 
; 0000 054E     if(n==0){
_0x2F3:
	LD   R30,Y
	LDD  R31,Y+1
	SBIW R30,0
	BRNE _0x2F4
; 0000 054F     lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0550     lcd_putsf("Format Data[N]");
	__POINTW1FN _0x0,945
	CALL SUBOPT_0x6
; 0000 0551         if(!s2){
	SBIC 0x13,2
	RJMP _0x2F5
; 0000 0552          lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0553          lcd_putsf("batal format");
	__POINTW1FN _0x0,960
	CALL SUBOPT_0x6
; 0000 0554          delay_ms(500);
	CALL SUBOPT_0x14
; 0000 0555          goto exit;}
	RJMP _0x2F6
; 0000 0556     }
_0x2F5:
; 0000 0557 
; 0000 0558     if(n==1){
_0x2F4:
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,1
	BREQ PC+3
	JMP _0x2F7
; 0000 0559     lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 055A     lcd_putsf("Format Data[Y]");
	__POINTW1FN _0x0,973
	CALL SUBOPT_0x6
; 0000 055B         if(!s2){
	SBIC 0x13,2
	RJMP _0x2F8
; 0000 055C         lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 055D         lcd_putsf("Proses Format");
	__POINTW1FN _0x0,988
	CALL SUBOPT_0x6
; 0000 055E 
; 0000 055F lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 0560 lcd_putsf("................");
	__POINTW1FN _0x0,1002
	CALL SUBOPT_0x6
; 0000 0561 //-------------start formating--------//
; 0000 0562 for(count2=1;count2<=batas;count2++){ecut[count2]=1;}
	LDI  R30,LOW(1)
	STS  _count2,R30
_0x2FA:
	CALL SUBOPT_0x2B
	BRLO _0x2FB
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_ecut)
	SBCI R27,HIGH(-_ecut)
	LDI  R30,LOW(1)
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x2FA
_0x2FB:
; 0000 0563 for(count2=1;count2<=batas;count2++){ecut1[count2]=1;}
	LDI  R30,LOW(1)
	STS  _count2,R30
_0x2FD:
	CALL SUBOPT_0x2B
	BRLO _0x2FE
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_ecut1)
	SBCI R27,HIGH(-_ecut1)
	LDI  R30,LOW(1)
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x2FD
_0x2FE:
; 0000 0564 for(count2=1;count2<=batas;count2++){edel[count2]=255;}
	LDI  R30,LOW(1)
	STS  _count2,R30
_0x300:
	CALL SUBOPT_0x2B
	BRLO _0x301
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_edel)
	SBCI R27,HIGH(-_edel)
	LDI  R30,LOW(255)
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x300
_0x301:
; 0000 0565 for(count2=0;count2<=20;count2++){eread[count2]=0;}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x303:
	LDS  R26,_count2
	CPI  R26,LOW(0x15)
	BRSH _0x304
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_eread)
	SBCI R27,HIGH(-_eread)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x303
_0x304:
; 0000 0566 for(count2=0;count2<=20;count2++){eplan[count2]=0;}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x306:
	LDS  R26,_count2
	CPI  R26,LOW(0x15)
	BRSH _0x307
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_eplan)
	SBCI R27,HIGH(-_eplan)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x306
_0x307:
; 0000 0567 for(count2=0;count2<=batas;count2++){espeed[count2]=100;}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x309:
	CALL SUBOPT_0x2B
	BRLO _0x30A
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_espeed)
	SBCI R27,HIGH(-_espeed)
	LDI  R30,LOW(100)
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x309
_0x30A:
; 0000 0568 for(count2=0;count2<=batas;count2++){espeed1[count2]=80;}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x30C:
	CALL SUBOPT_0x2B
	BRLO _0x30D
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_espeed1)
	SBCI R27,HIGH(-_espeed1)
	LDI  R30,LOW(80)
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x30C
_0x30D:
; 0000 0569 for(count2=0;count2<=batas;count2++){etimer[count2]=1;}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x30F:
	CALL SUBOPT_0x2B
	BRLO _0x310
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_etimer)
	SBCI R27,HIGH(-_etimer)
	LDI  R30,LOW(1)
	CALL __EEPROMWRB
	CALL SUBOPT_0x2E
	RJMP _0x30F
_0x310:
; 0000 056A for(adc=0;adc<16;adc++){esensitive[adc]=100;}
	LDI  R30,LOW(0)
	STS  _adc,R30
_0x312:
	LDS  R26,_adc
	CPI  R26,LOW(0x10)
	BRSH _0x313
	CALL SUBOPT_0x5D
	LDI  R30,LOW(100)
	CALL __EEPROMWRB
	CALL SUBOPT_0x4B
	RJMP _0x312
_0x313:
; 0000 056B lmp=1;
	SBI  0x18,3
; 0000 056C eencomp=0;
	LDI  R26,LOW(_eencomp)
	LDI  R27,HIGH(_eencomp)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
; 0000 056D emode=0;
	LDI  R26,LOW(_emode)
	LDI  R27,HIGH(_emode)
	CALL __EEPROMWRB
; 0000 056E emodekanan=0;
	LDI  R26,LOW(_emodekanan)
	LDI  R27,HIGH(_emodekanan)
	CALL __EEPROMWRB
; 0000 056F epulsa=5;
	LDI  R26,LOW(_epulsa)
	LDI  R27,HIGH(_epulsa)
	LDI  R30,LOW(5)
	CALL __EEPROMWRB
; 0000 0570 ekp=10;
	LDI  R26,LOW(_ekp)
	LDI  R27,HIGH(_ekp)
	LDI  R30,LOW(10)
	CALL __EEPROMWRB
; 0000 0571 ekd=100;
	LDI  R26,LOW(_ekd)
	LDI  R27,HIGH(_ekd)
	LDI  R30,LOW(100)
	CALL __EEPROMWRB
; 0000 0572 eki=0;
	LDI  R26,LOW(_eki)
	LDI  R27,HIGH(_eki)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
; 0000 0573 elc=120;
	LDI  R26,LOW(_elc)
	LDI  R27,HIGH(_elc)
	LDI  R30,LOW(120)
	CALL __EEPROMWRB
; 0000 0574 elc1=0;
	LDI  R26,LOW(_elc1)
	LDI  R27,HIGH(_elc1)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
; 0000 0575 evc=120;
	LDI  R26,LOW(_evc)
	LDI  R27,HIGH(_evc)
	LDI  R30,LOW(120)
	CALL __EEPROMWRB
; 0000 0576 emax1=100;
	LDI  R26,LOW(_emax1)
	LDI  R27,HIGH(_emax1)
	LDI  R30,LOW(100)
	CALL __EEPROMWRB
; 0000 0577 loading();
	CALL _loading
; 0000 0578 lcd_gotoxy(0,0);
	CALL SUBOPT_0x15
; 0000 0579 lcd_putsf("Format Selesai!");
	__POINTW1FN _0x0,1019
	CALL SUBOPT_0x6
; 0000 057A delay_ms(1000);
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL SUBOPT_0x22
; 0000 057B 
; 0000 057C goto exit;
	RJMP _0x2F6
; 0000 057D 
; 0000 057E 
; 0000 057F         }
; 0000 0580 
; 0000 0581     }
_0x2F8:
; 0000 0582 
; 0000 0583   }
_0x2F7:
	RJMP _0x2EF
; 0000 0584 
; 0000 0585 }
; 0000 0586 
; 0000 0587 exit2:
_0x2EC:
_0x316:
; 0000 0588 stop();
	CALL _stop
; 0000 0589 lmp=1;
	SBI  0x18,3
; 0000 058A //-------------data dari eeprom di copy ke ram--------//
; 0000 058B for(count2=1;count2<=batas;count2++){cut[count2]=ecut[count2];}
	LDI  R30,LOW(1)
	STS  _count2,R30
_0x31A:
	CALL SUBOPT_0x2B
	BRLO _0x31B
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_cut)
	SBCI R31,HIGH(-_cut)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x5E
	CALL SUBOPT_0x2E
	RJMP _0x31A
_0x31B:
; 0000 058C for(count2=1;count2<=batas;count2++){cut1[count2]=ecut1[count2];}
	LDI  R30,LOW(1)
	STS  _count2,R30
_0x31D:
	CALL SUBOPT_0x2B
	BRLO _0x31E
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_cut1)
	SBCI R31,HIGH(-_cut1)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x5F
	CALL SUBOPT_0x2E
	RJMP _0x31D
_0x31E:
; 0000 058D for(count2=1;count2<=batas;count2++){del[count2]=edel[count2];}
	LDI  R30,LOW(1)
	STS  _count2,R30
_0x320:
	CALL SUBOPT_0x2B
	BRLO _0x321
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_del)
	SBCI R31,HIGH(-_del)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x60
	CALL SUBOPT_0x2E
	RJMP _0x320
_0x321:
; 0000 058E for(count2=0;count2<=20;count2++){read[count2]=eread[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x323:
	LDS  R26,_count2
	CPI  R26,LOW(0x15)
	BRSH _0x324
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_read)
	SBCI R31,HIGH(-_read)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x61
	CALL SUBOPT_0x2E
	RJMP _0x323
_0x324:
; 0000 058F for(count2=0;count2<=20;count2++){plan[count2]=eplan[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x326:
	LDS  R26,_count2
	CPI  R26,LOW(0x15)
	BRSH _0x327
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_plan)
	SBCI R31,HIGH(-_plan)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x62
	CALL SUBOPT_0x2E
	RJMP _0x326
_0x327:
; 0000 0590 for(count2=0;count2<=batas;count2++){speed[count2]=espeed[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x329:
	CALL SUBOPT_0x2B
	BRLO _0x32A
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_speed)
	SBCI R31,HIGH(-_speed)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x63
	CALL SUBOPT_0x2E
	RJMP _0x329
_0x32A:
; 0000 0591 for(count2=0;count2<=batas;count2++){speed1[count2]=espeed1[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x32C:
	CALL SUBOPT_0x2B
	BRLO _0x32D
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_speed1)
	SBCI R31,HIGH(-_speed1)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x64
	CALL SUBOPT_0x2E
	RJMP _0x32C
_0x32D:
; 0000 0592 for(count2=0;count2<=batas;count2++){timer[count2]=etimer[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x32F:
	CALL SUBOPT_0x2B
	BRLO _0x330
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_timer)
	SBCI R31,HIGH(-_timer)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x65
	CALL SUBOPT_0x2E
	RJMP _0x32F
_0x330:
; 0000 0593 for(count2=0;count2<=batas;count2++){time[count2]=0;}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x332:
	CALL SUBOPT_0x2B
	BRLO _0x333
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_time)
	SBCI R31,HIGH(-_time)
	LDI  R26,LOW(0)
	STD  Z+0,R26
	CALL SUBOPT_0x2E
	RJMP _0x332
_0x333:
; 0000 0594 for(adc=0;adc<16;adc++){sensitive[adc]=esensitive[adc];}
	LDI  R30,LOW(0)
	STS  _adc,R30
_0x335:
	LDS  R26,_adc
	CPI  R26,LOW(0x10)
	BRSH _0x336
	CALL SUBOPT_0x45
	MOVW R0,R30
	CALL SUBOPT_0x5D
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	CALL SUBOPT_0x4B
	RJMP _0x335
_0x336:
; 0000 0595 mode=emode;
	LDI  R26,LOW(_emode)
	LDI  R27,HIGH(_emode)
	CALL __EEPROMRDB
	STS  _mode,R30
; 0000 0596 modekanan=emodekanan;
	LDI  R26,LOW(_emodekanan)
	LDI  R27,HIGH(_emodekanan)
	CALL __EEPROMRDB
	STS  _modekanan,R30
; 0000 0597 encomp=eencomp;
	LDI  R26,LOW(_eencomp)
	LDI  R27,HIGH(_eencomp)
	CALL SUBOPT_0x66
	CALL SUBOPT_0x43
; 0000 0598 pulsa=epulsa;
	LDI  R26,LOW(_epulsa)
	LDI  R27,HIGH(_epulsa)
	CALL __EEPROMRDB
	STS  _pulsa,R30
; 0000 0599 start=0;
	LDI  R30,LOW(0)
	STS  _start,R30
; 0000 059A aktif=1;
	SET
	BLD  R2,0
; 0000 059B cacah=0;
	STS  _cacah,R30
; 0000 059C lc=elc;
	LDI  R26,LOW(_elc)
	LDI  R27,HIGH(_elc)
	CALL __EEPROMRDB
	MOV  R12,R30
	CLR  R13
; 0000 059D lc1=elc1;
	LDI  R26,LOW(_elc1)
	LDI  R27,HIGH(_elc1)
	CALL SUBOPT_0x66
	CALL SUBOPT_0x3F
; 0000 059E vc=evc;
	LDI  R26,LOW(_evc)
	LDI  R27,HIGH(_evc)
	CALL SUBOPT_0x66
	STS  _vc,R30
	STS  _vc+1,R31
; 0000 059F max1=emax1;
	LDI  R26,LOW(_emax1)
	LDI  R27,HIGH(_emax1)
	CALL __EEPROMRDB
	MOV  R8,R30
	CLR  R9
; 0000 05A0 kp=ekp;
	LDI  R26,LOW(_ekp)
	LDI  R27,HIGH(_ekp)
	CALL __EEPROMRDB
	STS  _kp,R30
; 0000 05A1 ki=eki;
	LDI  R26,LOW(_eki)
	LDI  R27,HIGH(_eki)
	CALL __EEPROMRDB
	STS  _ki,R30
; 0000 05A2 kd=ekd;
	LDI  R26,LOW(_ekd)
	LDI  R27,HIGH(_ekd)
	CALL __EEPROMRDB
	STS  _kd,R30
; 0000 05A3 SP=0;
	LDI  R30,LOW(0)
	STS  _SP,R30
; 0000 05A4 PV = 0;
	STS  _PV,R30
	STS  _PV+1,R30
; 0000 05A5 lasterror = 0;
	STS  _lasterror,R30
	STS  _lasterror+1,R30
; 0000 05A6 error = 0;
	CALL SUBOPT_0x54
; 0000 05A7 led=1;
	SBI  0x12,7
; 0000 05A8 if (!s1){goto exit3;}
	SBIS 0x13,0
	RJMP _0x33A
; 0000 05A9 goto exit;
	RJMP _0x2F6
; 0000 05AA exit3:
_0x33A:
; 0000 05AB lcd_clear();
	CALL _lcd_clear
; 0000 05AC L=0;
	CBI  0x15,7
; 0000 05AD R=0;
	CBI  0x15,6
; 0000 05AE aktif=1;
	SET
	BLD  R2,0
; 0000 05AF setting();
	CALL _setting
; 0000 05B0 led=1;
	SBI  0x12,7
; 0000 05B1 
; 0000 05B2 exit4:
_0x341:
; 0000 05B3 pilihStart();
	RCALL _pilihStart
; 0000 05B4 
; 0000 05B5 exit:
_0x2F6:
; 0000 05B6 lcd_clear();
	CALL _lcd_clear
; 0000 05B7 
; 0000 05B8 while (1) {
_0x342:
; 0000 05B9 lmp=1;
	SBI  0x18,3
; 0000 05BA scansensor();
	CALL _scansensor
; 0000 05BB 
; 0000 05BC if(!s3){p_start=p_start+1;delay_ms(200);}
	SBIC 0x13,3
	RJMP _0x347
	__ADDWRN 16,17,1
	CALL SUBOPT_0x59
; 0000 05BD if(p_start==2){p_start=0;}
_0x347:
	CALL SUBOPT_0x21
	BRNE _0x348
	__GETWRN 16,17,0
; 0000 05BE 
; 0000 05BF         if(p_start==0){
_0x348:
	MOV  R0,R16
	OR   R0,R17
	BRNE _0x349
; 0000 05C0             lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 05C1             lcd_putsf(".Start=A");
	__POINTW1FN _0x0,878
	CALL SUBOPT_0x6
; 0000 05C2             lcd_gotoxy(9,1);
	CALL SUBOPT_0x5A
; 0000 05C3             lcd_putsf(" CP=1");
	CALL SUBOPT_0x5B
; 0000 05C4             goto exit4;
	RJMP _0x341
; 0000 05C5 
; 0000 05C6         }
; 0000 05C7 
; 0000 05C8         if(p_start==1){
_0x349:
	CALL SUBOPT_0x1F
	BRNE _0x34A
; 0000 05C9             lcd_gotoxy(0,1);
	CALL SUBOPT_0x13
; 0000 05CA             lcd_putsf(" Start=A");
	__POINTW1FN _0x0,1035
	CALL SUBOPT_0x6
; 0000 05CB             lcd_gotoxy(9,1);
	CALL SUBOPT_0x5A
; 0000 05CC             lcd_putsf(".CP=1");
	__POINTW1FN _0x0,1044
	CALL SUBOPT_0x6
; 0000 05CD 
; 0000 05CE         }
; 0000 05CF 
; 0000 05D0 
; 0000 05D1 
; 0000 05D2 
; 0000 05D3 
; 0000 05D4 //sprintf(buff,"[%d-%d] SCAN    ",sen,sam);
; 0000 05D5 //lcd_puts(buff);
; 0000 05D6 //if(pass>=0){lcd_putsf("+");}
; 0000 05D7 //if(pass<=0){lcd_putsf("-");}
; 0000 05D8 if (!s1)goto exit2; //masuk ke menu setting
_0x34A:
	SBIS 0x13,0
	RJMP _0x316
; 0000 05D9 //if (!s4||!s6)break;
; 0000 05DA }
	RJMP _0x342
; 0000 05DB lcd_clear();
; 0000 05DC if (mode==1){delay_ms(500);}
; 0000 05DD L=0;
; 0000 05DE R=0;
; 0000 05DF 
; 0000 05E0 //-------------data dari eeprom di copy ke ram--------//
; 0000 05E1 for(count2=1;count2<=batas;count2++){cut[count2]=ecut[count2];}
_0x352:
	CALL SUBOPT_0x2B
	BRLO _0x353
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_cut)
	SBCI R31,HIGH(-_cut)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x5E
	CALL SUBOPT_0x2E
	RJMP _0x352
_0x353:
; 0000 05E2 for(count2=1;count2<=batas;count2++){cut1[count2]=ecut1[count2];}
	LDI  R30,LOW(1)
	STS  _count2,R30
_0x355:
	CALL SUBOPT_0x2B
	BRLO _0x356
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_cut1)
	SBCI R31,HIGH(-_cut1)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x5F
	CALL SUBOPT_0x2E
	RJMP _0x355
_0x356:
; 0000 05E3 for(count2=1;count2<=batas;count2++){del[count2]=edel[count2];}
	LDI  R30,LOW(1)
	STS  _count2,R30
_0x358:
	CALL SUBOPT_0x2B
	BRLO _0x359
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_del)
	SBCI R31,HIGH(-_del)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x60
	CALL SUBOPT_0x2E
	RJMP _0x358
_0x359:
; 0000 05E4 for(count2=0;count2<=20;count2++){read[count2]=eread[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x35B:
	LDS  R26,_count2
	CPI  R26,LOW(0x15)
	BRSH _0x35C
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_read)
	SBCI R31,HIGH(-_read)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x61
	CALL SUBOPT_0x2E
	RJMP _0x35B
_0x35C:
; 0000 05E5 for(count2=0;count2<=20;count2++){plan[count2]=eplan[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x35E:
	LDS  R26,_count2
	CPI  R26,LOW(0x15)
	BRSH _0x35F
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_plan)
	SBCI R31,HIGH(-_plan)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x62
	CALL SUBOPT_0x2E
	RJMP _0x35E
_0x35F:
; 0000 05E6 for(count2=0;count2<=batas;count2++){speed[count2]=espeed[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x361:
	CALL SUBOPT_0x2B
	BRLO _0x362
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_speed)
	SBCI R31,HIGH(-_speed)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x63
	CALL SUBOPT_0x2E
	RJMP _0x361
_0x362:
; 0000 05E7 for(count2=0;count2<=batas;count2++){speed1[count2]=espeed1[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x364:
	CALL SUBOPT_0x2B
	BRLO _0x365
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_speed1)
	SBCI R31,HIGH(-_speed1)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x64
	CALL SUBOPT_0x2E
	RJMP _0x364
_0x365:
; 0000 05E8 for(count2=0;count2<=batas;count2++){timer[count2]=etimer[count2];}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x367:
	CALL SUBOPT_0x2B
	BRLO _0x368
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_timer)
	SBCI R31,HIGH(-_timer)
	MOVW R0,R30
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x65
	CALL SUBOPT_0x2E
	RJMP _0x367
_0x368:
; 0000 05E9 for(count2=0;count2<=batas;count2++){time[count2]=0;}
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x36A:
	CALL SUBOPT_0x2B
	BRLO _0x36B
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_time)
	SBCI R31,HIGH(-_time)
	LDI  R26,LOW(0)
	STD  Z+0,R26
	CALL SUBOPT_0x2E
	RJMP _0x36A
_0x36B:
; 0000 05EA for(adc=0;adc<16;adc++){sensitive[adc]=esensitive[adc];}
	LDI  R30,LOW(0)
	STS  _adc,R30
_0x36D:
	LDS  R26,_adc
	CPI  R26,LOW(0x10)
	BRSH _0x36E
	CALL SUBOPT_0x45
	MOVW R0,R30
	CALL SUBOPT_0x5D
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	CALL SUBOPT_0x4B
	RJMP _0x36D
_0x36E:
; 0000 05EB if(modekanan==1){for(count2=0;count2<batas;count2++){cut[count2]=cut1[count2];}}
	LDS  R26,_modekanan
	CPI  R26,LOW(0x1)
	BRNE _0x36F
	LDI  R30,LOW(0)
	STS  _count2,R30
_0x371:
	LDS  R30,_batas
	LDS  R26,_count2
	CP   R26,R30
	BRSH _0x372
	CALL SUBOPT_0x2C
	SUBI R26,LOW(-_cut)
	SBCI R27,HIGH(-_cut)
	CALL SUBOPT_0x2D
	SUBI R30,LOW(-_cut1)
	SBCI R31,HIGH(-_cut1)
	LD   R30,Z
	ST   X,R30
	CALL SUBOPT_0x2E
	RJMP _0x371
_0x372:
; 0000 05EC if (mode==1)darurat();
_0x36F:
	LDS  R26,_mode
	CPI  R26,LOW(0x1)
	BRNE _0x373
	CALL _darurat
; 0000 05ED lmp=0;
_0x373:
	CBI  0x18,3
; 0000 05EE pwm_on();
	CALL _pwm_on
; 0000 05EF aktif=1;
	SET
	BLD  R2,0
; 0000 05F0 #asm("sei")
	sei
; 0000 05F1 while (1)
_0x376:
; 0000 05F2       {
; 0000 05F3       // Place your code here
; 0000 05F4       program();
	RCALL _program
; 0000 05F5       scansensor();
	CALL _scansensor
; 0000 05F6       if (!s1){pwm_off();stop();goto exit;}
	SBIC 0x13,0
	RJMP _0x379
	CALL SUBOPT_0x1D
	RJMP _0x2F6
; 0000 05F7       };
_0x379:
	RJMP _0x376
; 0000 05F8 
; 0000 05F9 }
_0x37A:
	RJMP _0x37A

	.DSEG
_0x2EB:
	.BYTE 0x19
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_put_buff_G100:
	ST   -Y,R17
	ST   -Y,R16
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x2000010
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,4
	CALL __GETW1P
	MOVW R16,R30
	SBIW R30,0
	BREQ _0x2000012
	__CPWRN 16,17,2
	BRLO _0x2000013
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	__PUTW1SNS 2,4
_0x2000012:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL SUBOPT_0x58
	SBIW R30,1
	LDD  R26,Y+4
	STD  Z+0,R26
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	TST  R31
	BRMI _0x2000014
	CALL SUBOPT_0x58
_0x2000014:
_0x2000013:
	RJMP _0x2000015
_0x2000010:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	ST   X+,R30
	ST   X,R31
_0x2000015:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,5
	RET
__print_G100:
	SBIW R28,6
	CALL __SAVELOCR6
	LDI  R17,0
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0x2000016:
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ADIW R30,1
	STD  Y+18,R30
	STD  Y+18+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R18,R30
	CPI  R30,0
	BRNE PC+3
	JMP _0x2000018
	MOV  R30,R17
	CPI  R30,0
	BRNE _0x200001C
	CPI  R18,37
	BRNE _0x200001D
	LDI  R17,LOW(1)
	RJMP _0x200001E
_0x200001D:
	CALL SUBOPT_0x67
_0x200001E:
	RJMP _0x200001B
_0x200001C:
	CPI  R30,LOW(0x1)
	BRNE _0x200001F
	CPI  R18,37
	BRNE _0x2000020
	CALL SUBOPT_0x67
	RJMP _0x20000C9
_0x2000020:
	LDI  R17,LOW(2)
	LDI  R20,LOW(0)
	LDI  R16,LOW(0)
	CPI  R18,45
	BRNE _0x2000021
	LDI  R16,LOW(1)
	RJMP _0x200001B
_0x2000021:
	CPI  R18,43
	BRNE _0x2000022
	LDI  R20,LOW(43)
	RJMP _0x200001B
_0x2000022:
	CPI  R18,32
	BRNE _0x2000023
	LDI  R20,LOW(32)
	RJMP _0x200001B
_0x2000023:
	RJMP _0x2000024
_0x200001F:
	CPI  R30,LOW(0x2)
	BRNE _0x2000025
_0x2000024:
	LDI  R21,LOW(0)
	LDI  R17,LOW(3)
	CPI  R18,48
	BRNE _0x2000026
	ORI  R16,LOW(128)
	RJMP _0x200001B
_0x2000026:
	RJMP _0x2000027
_0x2000025:
	CPI  R30,LOW(0x3)
	BREQ PC+3
	JMP _0x200001B
_0x2000027:
	CPI  R18,48
	BRLO _0x200002A
	CPI  R18,58
	BRLO _0x200002B
_0x200002A:
	RJMP _0x2000029
_0x200002B:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x200001B
_0x2000029:
	MOV  R30,R18
	CPI  R30,LOW(0x63)
	BRNE _0x200002F
	CALL SUBOPT_0x68
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	LDD  R26,Z+4
	ST   -Y,R26
	CALL SUBOPT_0x69
	RJMP _0x2000030
_0x200002F:
	CPI  R30,LOW(0x73)
	BRNE _0x2000032
	CALL SUBOPT_0x68
	CALL SUBOPT_0x6A
	CALL _strlen
	MOV  R17,R30
	RJMP _0x2000033
_0x2000032:
	CPI  R30,LOW(0x70)
	BRNE _0x2000035
	CALL SUBOPT_0x68
	CALL SUBOPT_0x6A
	CALL _strlenf
	MOV  R17,R30
	ORI  R16,LOW(8)
_0x2000033:
	ORI  R16,LOW(2)
	ANDI R16,LOW(127)
	LDI  R19,LOW(0)
	RJMP _0x2000036
_0x2000035:
	CPI  R30,LOW(0x64)
	BREQ _0x2000039
	CPI  R30,LOW(0x69)
	BRNE _0x200003A
_0x2000039:
	ORI  R16,LOW(4)
	RJMP _0x200003B
_0x200003A:
	CPI  R30,LOW(0x75)
	BRNE _0x200003C
_0x200003B:
	LDI  R30,LOW(_tbl10_G100*2)
	LDI  R31,HIGH(_tbl10_G100*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R17,LOW(5)
	RJMP _0x200003D
_0x200003C:
	CPI  R30,LOW(0x58)
	BRNE _0x200003F
	ORI  R16,LOW(8)
	RJMP _0x2000040
_0x200003F:
	CPI  R30,LOW(0x78)
	BREQ PC+3
	JMP _0x2000071
_0x2000040:
	LDI  R30,LOW(_tbl16_G100*2)
	LDI  R31,HIGH(_tbl16_G100*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R17,LOW(4)
_0x200003D:
	SBRS R16,2
	RJMP _0x2000042
	CALL SUBOPT_0x68
	CALL SUBOPT_0x6B
	LDD  R26,Y+11
	TST  R26
	BRPL _0x2000043
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	CALL __ANEGW1
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDI  R20,LOW(45)
_0x2000043:
	CPI  R20,0
	BREQ _0x2000044
	SUBI R17,-LOW(1)
	RJMP _0x2000045
_0x2000044:
	ANDI R16,LOW(251)
_0x2000045:
	RJMP _0x2000046
_0x2000042:
	CALL SUBOPT_0x68
	CALL SUBOPT_0x6B
_0x2000046:
_0x2000036:
	SBRC R16,0
	RJMP _0x2000047
_0x2000048:
	CP   R17,R21
	BRSH _0x200004A
	SBRS R16,7
	RJMP _0x200004B
	SBRS R16,2
	RJMP _0x200004C
	ANDI R16,LOW(251)
	MOV  R18,R20
	SUBI R17,LOW(1)
	RJMP _0x200004D
_0x200004C:
	LDI  R18,LOW(48)
_0x200004D:
	RJMP _0x200004E
_0x200004B:
	LDI  R18,LOW(32)
_0x200004E:
	CALL SUBOPT_0x67
	SUBI R21,LOW(1)
	RJMP _0x2000048
_0x200004A:
_0x2000047:
	MOV  R19,R17
	SBRS R16,1
	RJMP _0x200004F
_0x2000050:
	CPI  R19,0
	BREQ _0x2000052
	SBRS R16,3
	RJMP _0x2000053
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LPM  R18,Z+
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x2000054
_0x2000053:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R18,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
_0x2000054:
	CALL SUBOPT_0x67
	CPI  R21,0
	BREQ _0x2000055
	SUBI R21,LOW(1)
_0x2000055:
	SUBI R19,LOW(1)
	RJMP _0x2000050
_0x2000052:
	RJMP _0x2000056
_0x200004F:
_0x2000058:
	LDI  R18,LOW(48)
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __GETW1PF
	STD  Y+8,R30
	STD  Y+8+1,R31
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,2
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x200005A:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x200005C
	SUBI R18,-LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	SUB  R30,R26
	SBC  R31,R27
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0x200005A
_0x200005C:
	CPI  R18,58
	BRLO _0x200005D
	SBRS R16,3
	RJMP _0x200005E
	SUBI R18,-LOW(7)
	RJMP _0x200005F
_0x200005E:
	SUBI R18,-LOW(39)
_0x200005F:
_0x200005D:
	SBRC R16,4
	RJMP _0x2000061
	CPI  R18,49
	BRSH _0x2000063
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,1
	BRNE _0x2000062
_0x2000063:
	RJMP _0x20000CA
_0x2000062:
	CP   R21,R19
	BRLO _0x2000067
	SBRS R16,0
	RJMP _0x2000068
_0x2000067:
	RJMP _0x2000066
_0x2000068:
	LDI  R18,LOW(32)
	SBRS R16,7
	RJMP _0x2000069
	LDI  R18,LOW(48)
_0x20000CA:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x200006A
	ANDI R16,LOW(251)
	ST   -Y,R20
	CALL SUBOPT_0x69
	CPI  R21,0
	BREQ _0x200006B
	SUBI R21,LOW(1)
_0x200006B:
_0x200006A:
_0x2000069:
_0x2000061:
	CALL SUBOPT_0x67
	CPI  R21,0
	BREQ _0x200006C
	SUBI R21,LOW(1)
_0x200006C:
_0x2000066:
	SUBI R19,LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,2
	BRLO _0x2000059
	RJMP _0x2000058
_0x2000059:
_0x2000056:
	SBRS R16,0
	RJMP _0x200006D
_0x200006E:
	CPI  R21,0
	BREQ _0x2000070
	SUBI R21,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	CALL SUBOPT_0x69
	RJMP _0x200006E
_0x2000070:
_0x200006D:
_0x2000071:
_0x2000030:
_0x20000C9:
	LDI  R17,LOW(0)
_0x200001B:
	RJMP _0x2000016
_0x2000018:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __GETW1P
	CALL __LOADLOCR6
	ADIW R28,20
	RET
_sprintf:
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	CALL __SAVELOCR4
	CALL SUBOPT_0x6C
	SBIW R30,0
	BRNE _0x2000072
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x2080003
_0x2000072:
	MOVW R26,R28
	ADIW R26,6
	CALL __ADDW2R15
	MOVW R16,R26
	CALL SUBOPT_0x6C
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
	MOVW R26,R28
	ADIW R26,10
	CALL __ADDW2R15
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(_put_buff_G100)
	LDI  R31,HIGH(_put_buff_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,10
	ST   -Y,R31
	ST   -Y,R30
	RCALL __print_G100
	MOVW R18,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R30,R18
_0x2080003:
	CALL __LOADLOCR4
	ADIW R28,10
	POP  R15
	RET
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.DSEG

	.CSEG
__lcd_write_nibble_G101:
	LD   R30,Y
	ANDI R30,LOW(0x10)
	BREQ _0x2020004
	SBI  0x18,4
	RJMP _0x2020005
_0x2020004:
	CBI  0x18,4
_0x2020005:
	LD   R30,Y
	ANDI R30,LOW(0x20)
	BREQ _0x2020006
	SBI  0x18,5
	RJMP _0x2020007
_0x2020006:
	CBI  0x18,5
_0x2020007:
	LD   R30,Y
	ANDI R30,LOW(0x40)
	BREQ _0x2020008
	SBI  0x18,6
	RJMP _0x2020009
_0x2020008:
	CBI  0x18,6
_0x2020009:
	LD   R30,Y
	ANDI R30,LOW(0x80)
	BREQ _0x202000A
	SBI  0x18,7
	RJMP _0x202000B
_0x202000A:
	CBI  0x18,7
_0x202000B:
	__DELAY_USB 11
	SBI  0x18,2
	__DELAY_USB 27
	CBI  0x18,2
	__DELAY_USB 27
	RJMP _0x2080001
__lcd_write_data:
	LD   R30,Y
	ST   -Y,R30
	RCALL __lcd_write_nibble_G101
    ld    r30,y
    swap  r30
    st    y,r30
	LD   R30,Y
	ST   -Y,R30
	RCALL __lcd_write_nibble_G101
	__DELAY_USW 200
	RJMP _0x2080001
_lcd_gotoxy:
	LD   R30,Y
	LDI  R31,0
	SUBI R30,LOW(-__base_y_G101)
	SBCI R31,HIGH(-__base_y_G101)
	LD   R30,Z
	LDD  R26,Y+1
	ADD  R30,R26
	ST   -Y,R30
	RCALL __lcd_write_data
	LDD  R30,Y+1
	STS  __lcd_x,R30
	LD   R30,Y
	STS  __lcd_y,R30
	ADIW R28,2
	RET
_lcd_clear:
	LDI  R30,LOW(2)
	CALL SUBOPT_0x6D
	LDI  R30,LOW(12)
	ST   -Y,R30
	RCALL __lcd_write_data
	LDI  R30,LOW(1)
	CALL SUBOPT_0x6D
	LDI  R30,LOW(0)
	STS  __lcd_y,R30
	STS  __lcd_x,R30
	RET
_lcd_putchar:
	LD   R26,Y
	CPI  R26,LOW(0xA)
	BREQ _0x2020011
	LDS  R30,__lcd_maxx
	LDS  R26,__lcd_x
	CP   R26,R30
	BRLO _0x2020010
_0x2020011:
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDS  R30,__lcd_y
	SUBI R30,-LOW(1)
	STS  __lcd_y,R30
	ST   -Y,R30
	RCALL _lcd_gotoxy
	LD   R26,Y
	CPI  R26,LOW(0xA)
	BRNE _0x2020013
	RJMP _0x2080001
_0x2020013:
_0x2020010:
	LDS  R30,__lcd_x
	SUBI R30,-LOW(1)
	STS  __lcd_x,R30
	SBI  0x18,0
	LD   R30,Y
	ST   -Y,R30
	RCALL __lcd_write_data
	CBI  0x18,0
	RJMP _0x2080001
_lcd_puts:
	ST   -Y,R17
_0x2020014:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R30,X+
	STD  Y+1,R26
	STD  Y+1+1,R27
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x2020016
	ST   -Y,R17
	RCALL _lcd_putchar
	RJMP _0x2020014
_0x2020016:
	RJMP _0x2080002
_lcd_putsf:
	ST   -Y,R17
_0x2020017:
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,1
	STD  Y+1,R30
	STD  Y+1+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x2020019
	ST   -Y,R17
	RCALL _lcd_putchar
	RJMP _0x2020017
_0x2020019:
_0x2080002:
	LDD  R17,Y+0
	ADIW R28,3
	RET
_lcd_init:
	SBI  0x17,4
	SBI  0x17,5
	SBI  0x17,6
	SBI  0x17,7
	SBI  0x17,2
	SBI  0x17,0
	SBI  0x17,1
	CBI  0x18,2
	CBI  0x18,0
	CBI  0x18,1
	LD   R30,Y
	STS  __lcd_maxx,R30
	SUBI R30,-LOW(128)
	__PUTB1MN __base_y_G101,2
	LD   R30,Y
	SUBI R30,-LOW(192)
	__PUTB1MN __base_y_G101,3
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	CALL SUBOPT_0x22
	CALL SUBOPT_0x6E
	CALL SUBOPT_0x6E
	CALL SUBOPT_0x6E
	LDI  R30,LOW(32)
	ST   -Y,R30
	RCALL __lcd_write_nibble_G101
	__DELAY_USW 400
	LDI  R30,LOW(40)
	ST   -Y,R30
	RCALL __lcd_write_data
	LDI  R30,LOW(4)
	ST   -Y,R30
	RCALL __lcd_write_data
	LDI  R30,LOW(133)
	ST   -Y,R30
	RCALL __lcd_write_data
	LDI  R30,LOW(6)
	ST   -Y,R30
	RCALL __lcd_write_data
	RCALL _lcd_clear
_0x2080001:
	ADIW R28,1
	RET

	.CSEG

	.CSEG
_strlen:
    ld   r26,y+
    ld   r27,y+
    clr  r30
    clr  r31
strlen0:
    ld   r22,x+
    tst  r22
    breq strlen1
    adiw r30,1
    rjmp strlen0
strlen1:
    ret
_strlenf:
    clr  r26
    clr  r27
    ld   r30,y+
    ld   r31,y+
strlenf0:
	lpm  r0,z+
    tst  r0
    breq strlenf1
    adiw r26,1
    rjmp strlenf0
strlenf1:
    movw r30,r26
    ret

	.ESEG
_esensitive:
	.BYTE 0xE
_espeed:
	.BYTE 0x65
_espeed1:
	.BYTE 0x65
_etimer:
	.BYTE 0x65
_eplan:
	.BYTE 0x15
_eread:
	.BYTE 0x15
_ecut:
	.BYTE 0x65
_ecut1:
	.BYTE 0x65
_edel:
	.BYTE 0x65
_eencomp:
	.DB  0x0
_emode:
	.DB  0x0
_emodekanan:
	.DB  0x0
_epulsa:
	.DB  0x5
_ekp:
	.DB  0xA
_ekd:
	.DB  0x64
_eki:
	.DB  0x0
_elc:
	.DB  0x78
_elc1:
	.DB  0x0
_evc:
	.DB  0x78
_emax1:
	.DB  0x64

	.DSEG
_vc:
	.BYTE 0x2
_I:
	.BYTE 0x2
_PV:
	.BYTE 0x2
_error:
	.BYTE 0x2
_lasterror:
	.BYTE 0x2
_encomp:
	.BYTE 0x2
_lc1:
	.BYTE 0x2
_xcc:
	.BYTE 0x2
_kp:
	.BYTE 0x1
_kd:
	.BYTE 0x1
_ki:
	.BYTE 0x1
_pulsa:
	.BYTE 0x1
_batas:
	.BYTE 0x1
_timer:
	.BYTE 0x65
_speed:
	.BYTE 0x65
_speed1:
	.BYTE 0x65
_count2:
	.BYTE 0x1
_start:
	.BYTE 0x1
_time:
	.BYTE 0x65
_cacah:
	.BYTE 0x1
_cc:
	.BYTE 0x1
_plan:
	.BYTE 0x15
_read:
	.BYTE 0x15
_SP:
	.BYTE 0x1
_mode:
	.BYTE 0x1
_cut:
	.BYTE 0x65
_cut1:
	.BYTE 0x65
_counting:
	.BYTE 0x1
_protec:
	.BYTE 0x1
_del:
	.BYTE 0x65
_tunda:
	.BYTE 0x1
_modekanan:
	.BYTE 0x1
_sensitive:
	.BYTE 0xE
_in:
	.BYTE 0x1
_adc:
	.BYTE 0x1
_sam:
	.BYTE 0x1
_samping:
	.BYTE 0x1
_sam1:
	.BYTE 0x1
_samping1:
	.BYTE 0x1
_hight:
	.BYTE 0xE
_low:
	.BYTE 0xE
_scan:
	.BYTE 0x1
_inv:
	.BYTE 0x1
_invers:
	.BYTE 0x1
_dep:
	.BYTE 0x2
_depan:
	.BYTE 0x2
_sen:
	.BYTE 0x2
_sm:
	.BYTE 0x2
_pass:
	.BYTE 0x2
_buff:
	.BYTE 0x21
_pilih_start:
	.BYTE 0x2
__base_y_G101:
	.BYTE 0x4
__lcd_x:
	.BYTE 0x1
__lcd_y:
	.BYTE 0x1
__lcd_maxx:
	.BYTE 0x1

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x0:
	ST   -Y,R17
	ST   -Y,R16
	__GETWRN 16,17,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 56 TIMES, CODE SIZE REDUCTION:107 WORDS
SUBOPT_0x1:
	LDI  R30,LOW(1)
	ST   -Y,R30
	JMP  _lcd_gotoxy

;OPTIMIZER ADDED SUBROUTINE, CALLED 15 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x2:
	LDI  R30,LOW(95)
	ST   -Y,R30
	JMP  _lcd_putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x3:
	LDI  R30,LOW(80)
	LDI  R31,HIGH(80)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 15 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x4:
	LDI  R30,LOW(255)
	ST   -Y,R30
	JMP  _lcd_putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x5:
	CALL _lcd_clear
	LDI  R30,LOW(0)
	ST   -Y,R30
	ST   -Y,R30
	JMP  _lcd_gotoxy

;OPTIMIZER ADDED SUBROUTINE, CALLED 67 TIMES, CODE SIZE REDUCTION:129 WORDS
SUBOPT_0x6:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _lcd_putsf

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x7:
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 16 TIMES, CODE SIZE REDUCTION:42 WORDS
SUBOPT_0x8:
	LDS  R30,_start
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x9:
	LDS  R30,_error
	LDS  R31,_error+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xA:
	LDS  R26,_I
	LDS  R27,_I+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xB:
	LDS  R30,_kp
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 13 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0xC:
	LDS  R26,_error
	LDS  R27,_error+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:16 WORDS
SUBOPT_0xD:
	CALL __MULW12
	ADD  R30,R8
	ADC  R31,R9
	MOVW R22,R30
	LDS  R26,_lasterror
	LDS  R27,_lasterror+1
	RCALL SUBOPT_0x9
	SUB  R30,R26
	SBC  R31,R27
	MOVW R26,R30
	LDS  R30,_kd
	LDI  R31,0
	CALL __MULW12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0xE:
	LDS  R30,_ki
	LDI  R31,0
	RCALL SUBOPT_0xA
	CALL __MULW12
	MOVW R26,R30
	LDI  R30,LOW(35)
	LDI  R31,HIGH(35)
	CALL __DIVW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0xF:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x10:
	CALL __SAVELOCR4
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	SUB  R30,R12
	SBC  R31,R13
	SUBI R30,LOW(-65281)
	SBCI R31,HIGH(-65281)
	MOVW R16,R30
	MOVW R30,R12
	ADIW R30,0
	MOVW R18,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x11:
	SUBI R30,LOW(-_del)
	SBCI R31,HIGH(-_del)
	LD   R30,Z
	STS  _tunda,R30
	LDS  R26,_vc
	LDS  R27,_vc+1
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	SUB  R30,R26
	SBC  R31,R27
	SUBI R30,LOW(-65281)
	SBCI R31,HIGH(-65281)
	MOVW R16,R30
	MOVW R30,R12
	ADIW R30,0
	MOVW R18,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x12:
	LDS  R30,_tunda
	LDI  R31,0
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 48 TIMES, CODE SIZE REDUCTION:91 WORDS
SUBOPT_0x13:
	LDI  R30,LOW(0)
	ST   -Y,R30
	RJMP SUBOPT_0x1

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x14:
	LDI  R30,LOW(500)
	LDI  R31,HIGH(500)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 17 TIMES, CODE SIZE REDUCTION:61 WORDS
SUBOPT_0x15:
	LDI  R30,LOW(0)
	ST   -Y,R30
	ST   -Y,R30
	JMP  _lcd_gotoxy

;OPTIMIZER ADDED SUBROUTINE, CALLED 44 TIMES, CODE SIZE REDUCTION:83 WORDS
SUBOPT_0x16:
	LDI  R30,LOW(_buff)
	LDI  R31,HIGH(_buff)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 17 TIMES, CODE SIZE REDUCTION:45 WORDS
SUBOPT_0x17:
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 9 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x18:
	MOVW R30,R16
	CALL __CWD1
	CALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 9 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x19:
	LDI  R24,8
	CALL _sprintf
	ADIW R28,12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x1A:
	ST   -Y,R30
	CALL _read_adc
	MOV  R21,R30
	LDI  R26,LOW(_low)
	LDI  R27,HIGH(_low)
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	CP   R21,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1B:
	LDI  R26,LOW(_hight)
	LDI  R27,HIGH(_hight)
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	CP   R30,R21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x1C:
	LD   R30,X
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1D:
	CALL _pwm_off
	JMP  _stop

;OPTIMIZER ADDED SUBROUTINE, CALLED 10 TIMES, CODE SIZE REDUCTION:33 WORDS
SUBOPT_0x1E:
	LDI  R24,4
	CALL _sprintf
	ADIW R28,8
	RJMP SUBOPT_0x13

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1F:
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CP   R30,R16
	CPC  R31,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x20:
	LDI  R31,0
	SBIW R30,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x21:
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CP   R30,R16
	CPC  R31,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 26 TIMES, CODE SIZE REDUCTION:47 WORDS
SUBOPT_0x22:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0x23:
	SBI  0x18,3
	__POINTW1FN _0x0,163
	RJMP SUBOPT_0x6

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x24:
	ST   -Y,R31
	ST   -Y,R30
	RJMP SUBOPT_0x18

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x25:
	ADD  R26,R16
	ADC  R27,R17
	LD   R30,X
	RJMP SUBOPT_0x17

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:33 WORDS
SUBOPT_0x26:
	MOVW R30,R16
	ADIW R30,1
	MOVW R16,R30
	MOVW R26,R30
	LDS  R30,_batas
	LDI  R31,0
	CP   R30,R26
	CPC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x27:
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	CPI  R30,LOW(0xFFFF)
	LDI  R26,HIGH(0xFFFF)
	CPC  R31,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x28:
	MOVW R30,R16
	SUBI R30,LOW(-_timer)
	SBCI R31,HIGH(-_timer)
	MOVW R0,R30
	LDI  R26,LOW(_timer)
	LDI  R27,HIGH(_timer)
	ADD  R26,R16
	ADC  R27,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x29:
	LD   R30,X
	SUBI R30,-LOW(1)
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x2A:
	CALL _lcd_clear
	LDI  R30,LOW(0)
	STS  _count2,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 24 TIMES, CODE SIZE REDUCTION:66 WORDS
SUBOPT_0x2B:
	LDS  R30,_batas
	LDS  R26,_count2
	CP   R30,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 31 TIMES, CODE SIZE REDUCTION:87 WORDS
SUBOPT_0x2C:
	LDS  R26,_count2
	LDI  R27,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 25 TIMES, CODE SIZE REDUCTION:69 WORDS
SUBOPT_0x2D:
	LDS  R30,_count2
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 33 TIMES, CODE SIZE REDUCTION:93 WORDS
SUBOPT_0x2E:
	LDS  R30,_count2
	SUBI R30,-LOW(1)
	STS  _count2,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 12 TIMES, CODE SIZE REDUCTION:19 WORDS
SUBOPT_0x2F:
	LDI  R30,LOW(150)
	LDI  R31,HIGH(150)
	RJMP SUBOPT_0x22

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x30:
	ST   -Y,R17
	ST   -Y,R16
	__GETWRN 16,17,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x31:
	MOVW R30,R16
	SUBI R30,LOW(-_del)
	SBCI R31,HIGH(-_del)
	MOVW R0,R30
	LDI  R26,LOW(_del)
	LDI  R27,HIGH(_del)
	ADD  R26,R16
	ADC  R27,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x32:
	LD   R30,X
	SUBI R30,-LOW(5)
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x33:
	MOVW R30,R16
	SUBI R30,LOW(-_speed)
	SBCI R31,HIGH(-_speed)
	MOVW R0,R30
	LDI  R26,LOW(_speed)
	LDI  R27,HIGH(_speed)
	ADD  R26,R16
	ADC  R27,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x34:
	MOVW R30,R16
	SUBI R30,LOW(-_speed1)
	SBCI R31,HIGH(-_speed1)
	MOVW R0,R30
	LDI  R26,LOW(_speed1)
	LDI  R27,HIGH(_speed1)
	ADD  R26,R16
	ADC  R27,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x35:
	MOVW R30,R16
	SUBI R30,LOW(-_plan)
	SBCI R31,HIGH(-_plan)
	MOVW R0,R30
	LDI  R26,LOW(_plan)
	LDI  R27,HIGH(_plan)
	ADD  R26,R16
	ADC  R27,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x36:
	MOVW R30,R16
	SUBI R30,LOW(-_read)
	SBCI R31,HIGH(-_read)
	MOVW R0,R30
	LDI  R26,LOW(_read)
	LDI  R27,HIGH(_read)
	ADD  R26,R16
	ADC  R27,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x37:
	CALL _read_adc
	STS  _in,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:37 WORDS
SUBOPT_0x38:
	LDI  R30,LOW(4)
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	CALL _lcd_gotoxy
	__POINTW1FN _0x0,167
	RJMP SUBOPT_0x6

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x39:
	CALL __CWD1
	CALL __PUTPARD1
	RJMP SUBOPT_0x1E

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x3A:
	LD   R30,Y
	LDD  R31,Y+1
	ADIW R30,1
	ST   Y,R30
	STD  Y+1,R31
	JMP  _lcd_clear

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:29 WORDS
SUBOPT_0x3B:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	CALL _lcd_gotoxy
	__POINTW1FN _0x0,483
	RJMP SUBOPT_0x6

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x3C:
	LDS  R30,_vc
	LDS  R31,_vc+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x3D:
	STS  _vc,R30
	STS  _vc+1,R31
	RJMP SUBOPT_0x2F

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3E:
	LDS  R30,_lc1
	LDS  R31,_lc1+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3F:
	STS  _lc1,R30
	STS  _lc1+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x40:
	LDS  R26,_lc1
	LDS  R27,_lc1+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x41:
	LDS  R26,_encomp
	LDS  R27,_encomp+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x42:
	LDS  R30,_encomp
	LDS  R31,_encomp+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x43:
	STS  _encomp,R30
	STS  _encomp+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x44:
	LDI  R31,0
	CP   R30,R26
	CPC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 17 TIMES, CODE SIZE REDUCTION:77 WORDS
SUBOPT_0x45:
	LDS  R30,_adc
	LDI  R31,0
	SUBI R30,LOW(-_sensitive)
	SBCI R31,HIGH(-_sensitive)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 14 TIMES, CODE SIZE REDUCTION:62 WORDS
SUBOPT_0x46:
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	CALL _lcd_gotoxy
	RJMP SUBOPT_0x45

;OPTIMIZER ADDED SUBROUTINE, CALLED 14 TIMES, CODE SIZE REDUCTION:23 WORDS
SUBOPT_0x47:
	LD   R30,Z
	LDS  R26,_in
	CP   R30,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 13 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x48:
	LDS  R30,_dep
	LDS  R31,_dep+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 12 TIMES, CODE SIZE REDUCTION:41 WORDS
SUBOPT_0x49:
	STS  _dep,R30
	STS  _dep+1,R31
	RJMP SUBOPT_0x4

;OPTIMIZER ADDED SUBROUTINE, CALLED 14 TIMES, CODE SIZE REDUCTION:23 WORDS
SUBOPT_0x4A:
	STS  _sen,R30
	STS  _sen+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x4B:
	LDS  R30,_adc
	SUBI R30,-LOW(1)
	STS  _adc,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x4C:
	STS  _depan,R30
	STS  _depan+1,R31
	LDS  R30,_sam
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0x4D:
	MOVW R0,R30
	SUBI R30,LOW(-_time)
	SBCI R31,HIGH(-_time)
	LD   R26,Z
	MOVW R30,R0
	SUBI R30,LOW(-_timer)
	SBCI R31,HIGH(-_timer)
	LD   R30,Z
	CP   R26,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x4E:
	CALL __CWD1
	CALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x4F:
	LDI  R24,16
	CALL _sprintf
	ADIW R28,20
	RJMP SUBOPT_0x16

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x50:
	LDS  R26,_dep
	LDS  R27,_dep+1
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	SUB  R30,R26
	SBC  R31,R27
	RJMP SUBOPT_0x4C

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x51:
	LDI  R31,0
	LDI  R26,LOW(13)
	LDI  R27,HIGH(13)
	CALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	STS  _samping,R30
	SBI  0x18,3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x52:
	LDS  R30,_depan
	LDS  R31,_depan+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 42 TIMES, CODE SIZE REDUCTION:79 WORDS
SUBOPT_0x53:
	STS  _error,R30
	STS  _error+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x54:
	LDI  R30,LOW(0)
	STS  _error,R30
	STS  _error+1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x55:
	SET
	BLD  R2,1
	LDI  R30,LOW(52)
	LDI  R31,HIGH(52)
	RCALL SUBOPT_0x53
	CALL _kananlancip
	LDI  R30,LOW(1)
	STS  _scan,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x56:
	LDS  R26,_depan
	LDS  R27,_depan+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x57:
	SET
	BLD  R2,1
	LDI  R30,LOW(65484)
	LDI  R31,HIGH(65484)
	RCALL SUBOPT_0x53
	CALL _kirilancip
	LDI  R30,LOW(1)
	STS  _scan,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x58:
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x59:
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	RJMP SUBOPT_0x22

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x5A:
	LDI  R30,LOW(9)
	ST   -Y,R30
	RJMP SUBOPT_0x1

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x5B:
	__POINTW1FN _0x0,887
	RJMP SUBOPT_0x6

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5C:
	LDS  R26,_pilih_start
	LDS  R27,_pilih_start+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x5D:
	LDS  R26,_adc
	LDI  R27,0
	SUBI R26,LOW(-_esensitive)
	SBCI R27,HIGH(-_esensitive)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5E:
	SUBI R26,LOW(-_ecut)
	SBCI R27,HIGH(-_ecut)
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5F:
	SUBI R26,LOW(-_ecut1)
	SBCI R27,HIGH(-_ecut1)
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x60:
	SUBI R26,LOW(-_edel)
	SBCI R27,HIGH(-_edel)
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x61:
	SUBI R26,LOW(-_eread)
	SBCI R27,HIGH(-_eread)
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x62:
	SUBI R26,LOW(-_eplan)
	SBCI R27,HIGH(-_eplan)
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x63:
	SUBI R26,LOW(-_espeed)
	SBCI R27,HIGH(-_espeed)
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x64:
	SUBI R26,LOW(-_espeed1)
	SBCI R27,HIGH(-_espeed1)
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x65:
	SUBI R26,LOW(-_etimer)
	SBCI R27,HIGH(-_etimer)
	CALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x66:
	CALL __EEPROMRDB
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x67:
	ST   -Y,R18
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x68:
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x69:
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x6A:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x6B:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+10,R30
	STD  Y+10+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x6C:
	MOVW R26,R28
	ADIW R26,12
	CALL __ADDW2R15
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x6D:
	ST   -Y,R30
	CALL __lcd_write_data
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	RJMP SUBOPT_0x22

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x6E:
	LDI  R30,LOW(48)
	ST   -Y,R30
	CALL __lcd_write_nibble_G101
	__DELAY_USW 400
	RET


	.CSEG
_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0xFA0
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

__ADDW2R15:
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	RET

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__MULW12U:
	MUL  R31,R26
	MOV  R31,R0
	MUL  R30,R27
	ADD  R31,R0
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	RET

__MULW12:
	RCALL __CHKSIGNW
	RCALL __MULW12U
	BRTC __MULW121
	RCALL __ANEGW1
__MULW121:
	RET

__DIVW21U:
	CLR  R0
	CLR  R1
	LDI  R25,16
__DIVW21U1:
	LSL  R26
	ROL  R27
	ROL  R0
	ROL  R1
	SUB  R0,R30
	SBC  R1,R31
	BRCC __DIVW21U2
	ADD  R0,R30
	ADC  R1,R31
	RJMP __DIVW21U3
__DIVW21U2:
	SBR  R26,1
__DIVW21U3:
	DEC  R25
	BRNE __DIVW21U1
	MOVW R30,R26
	MOVW R26,R0
	RET

__DIVW21:
	RCALL __CHKSIGNW
	RCALL __DIVW21U
	BRTC __DIVW211
	RCALL __ANEGW1
__DIVW211:
	RET

__CHKSIGNW:
	CLT
	SBRS R31,7
	RJMP __CHKSW1
	RCALL __ANEGW1
	SET
__CHKSW1:
	SBRS R27,7
	RJMP __CHKSW2
	COM  R26
	COM  R27
	ADIW R26,1
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSW2:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETW1PF:
	LPM  R0,Z+
	LPM  R31,Z
	MOV  R30,R0
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

__EEPROMRDB:
	SBIC EECR,EEWE
	RJMP __EEPROMRDB
	PUSH R31
	IN   R31,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R30,EEDR
	OUT  SREG,R31
	POP  R31
	RET

__EEPROMWRB:
	SBIS EECR,EEWE
	RJMP __EEPROMWRB1
	WDR
	RJMP __EEPROMWRB
__EEPROMWRB1:
	IN   R25,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R24,EEDR
	CP   R30,R24
	BREQ __EEPROMWRB0
	OUT  EEDR,R30
	SBI  EECR,EEMWE
	SBI  EECR,EEWE
__EEPROMWRB0:
	OUT  SREG,R25
	RET

__CPW02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
