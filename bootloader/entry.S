	.macro loop,cunt          
    li		t1,	0xffff            
    li		t2,	\cunt            
1:
	nop                         
	addi    t1, t1, -1         
	bne		t1, x0, 1b         
    li		t1,	0xffff         
	addi    t2, t2, -1         
	bne		t2, x0, 1b         
	.endm                      

	.macro load_data,_src_start,_dst_start,_dst_end 
	bgeu	\_dst_start, \_dst_end, 2f  
1:
	lw      t0, (\_src_start)             
	sw      t0, (\_dst_start)             
	addi    \_src_start, \_src_start, 4   
	addi    \_dst_start, \_dst_start, 4   
	bltu    \_dst_start, \_dst_end, 1b   
2:
	.endm

	.section .text
	.globl _start
	.type _start,@function

_start:
	// load linux nommu image
	// [0x3010_0000:0x3210_0000] --> [0x80000000:0x82000000]
    li		a0,	0x301
	slli	a0,	a0, 20      //a0 = 0x30100000
    li		a1,	0x800
	slli	a1,	a1, 20      //a1 = 0x80000000
    li		a2,	0x820
	slli	a2,	a2, 20      //a2 = 0x82000000
	load_data a0,a1,a2      /* copy 0x30100000 到 0x80000000*/

	// load ysyxSoc.dtb
	// [0x3210_0000:0x3220_0000] --> [0x8200_0000:0x8210_0000]
    li		a0,	0x321
	slli	a0,	a0, 20       //a0 = 0x32100000
    li		a1,	0x820
	slli	a1,	a1, 20       //a1 = 0x82000000
    li		a2,	0x821
	slli	a2,	a2, 20       //a2 = 0x82180000
	load_data a0,a1,a2       /* copy 0x20080000 到 0x82200000*/

    li      a0, 0x00         // hartid
    li	    a1,	0x820        // device tree
    slli    a1,	a1, 20       //a1 = 0x82200000
    
    // Jump to linux-nommu @ 0x80000000
    li	    t0,	0x800
    slli    t0,	t0, 20       //t0 = 0x80000000
    jr      t0                      

    .end
