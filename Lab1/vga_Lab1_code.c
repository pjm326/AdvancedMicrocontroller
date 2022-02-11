///////////////////////////////////////
/// 640x480 version!
/// test VGA with hardware video input copy to VGA
// compile with
// gcc pio_test_1.c -o pio 
///////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h> 
#include <sys/shm.h> 
#include <sys/mman.h>
#include <sys/time.h> 
#include <math.h> 


// need SDRAM base address for VGA display

// main bus; PIO
#define FPGA_AXI_BASE 	0xC0000000
#define FPGA_AXI_SPAN   0x00001000

// lw bus; PIO
#define FPGA_LW_BASE 	0xff200000
#define FPGA_LW_SPAN	0x00001000

// bus base
void *h2p_virtual_base;
void *h2p_lw_virtual_base;

// HPS_to_FPGA FIFO status address = 0

volatile unsigned int * lw__pio_write_ptr_rst = NULL;
volatile unsigned int * lw__pio_write_ptr_clk = NULL;
volatile unsigned int * lw__pio_read_ptr_x = NULL;
volatile unsigned int * lw__pio_read_ptr_y = NULL;
volatile unsigned int * lw__pio_read_ptr_z = NULL;

volatile unsigned int * hw__sdram_ptr = NULL;


// read offset is 0x10 for both busses
// remember that eaxh axi master bus needs unique address

#define SDRAM_OFFSET        0x00
#define FPGA_PIO_OFFSET_RST	0x00
#define FPGA_PIO_OFFSET_CLK	0x10
#define FPGA_PIO_OFFSET_X	0x20
#define FPGA_PIO_OFFSET_Y	0x30
#define FPGA_PIO_OFFSET_Z	0x40

// graphics primitives
void VGA_Hline(int, int, int, short) ;

// 16-bit primary colors
#define red  (0+(0<<5)+(31<<11))
#define dark_red (0+(0<<5)+(15<<11))
#define green (0+(63<<5)+(0<<11))
#define dark_green (0+(31<<5)+(0<<11))
#define blue (31+(0<<5)+(0<<11))
#define dark_blue (15+(0<<5)+(0<<11))
#define yellow (0+(63<<5)+(31<<11))
#define cyan (31+(63<<5)+(0<<11))
#define magenta (31+(0<<5)+(31<<11))
#define black (0x0000)
#define gray (15+(31<<5)+(51<<11))
#define white (0xffff)
int colors[] = {red, dark_red, green, dark_green, blue, dark_blue, 
		yellow, cyan, magenta, gray, black, white};

// pixel macro
#define VGA_PIXEL(x,y,color) do{\
	int  *pixel_ptr ;\
	pixel_ptr = (int*)((char *)hw__sdram_ptr + (((y)*640+(x))<<1)) ; \
	*(short *)pixel_ptr = (color);\
} while(0)


// /dev/mem file id
int fd;	
int clk = 0;
int rst = 0;
	
int main(void)

{

	// Declare volatile pointers to I/O registers (volatile 	
	// means that IO load and store instructions will be used 	
	// to access these pointer locations,  
  
	// === get FPGA addresses ==================
    // Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) 	{
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
    
	//============================================
    // get virtual addr that maps to physical
	// for light weight AXI bus
	h2p_lw_virtual_base = mmap( NULL, FPGA_LW_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_LW_BASE );	
	if( h2p_lw_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap1() failed...\n" );
		close( fd );
		return(1);
	}
	// Get the addresses that map to the two parallel ports on the light-weight bus
	lw__pio_write_ptr_rst = (unsigned int *)(h2p_lw_virtual_base + FPGA_PIO_OFFSET_RST);
	lw__pio_write_ptr_clk = (unsigned int *)(h2p_lw_virtual_base + FPGA_PIO_OFFSET_CLK);
	lw__pio_read_ptr_x = (unsigned int *)(h2p_lw_virtual_base + FPGA_PIO_OFFSET_X);
	lw__pio_read_ptr_y = (unsigned int *)(h2p_lw_virtual_base + FPGA_PIO_OFFSET_Y);
	lw__pio_read_ptr_z = (unsigned int *)(h2p_lw_virtual_base + FPGA_PIO_OFFSET_Z);
	
	
	//============================================
	
	// ===========================================
	// get virtual address for
	// AXI bus addr 
	h2p_virtual_base = mmap( NULL, FPGA_AXI_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_AXI_BASE); 	
	if( h2p_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}
    // Get the addresses that map to the two parallel ports on the AXI bus
	
	hw__sdram_ptr = (unsigned int *)(h2p_virtual_base + SDRAM_OFFSET);

	//============================================
	

	rst = 1;
	*(lw__pio_write_ptr_rst) = rst;
	clk = 1;
	*(lw__pio_write_ptr_clk) = clk;
	rst = 0;
	*(lw__pio_write_ptr_rst) = rst;


	while(1) 
	{
		//int num, pio_read;
		//int junk; 
		// input a number
		//junk = scanf("%d", &num);
		
		clk = 0;
		*(lw__pio_write_ptr_clk) = clk;
		sleep(0.10)
		clk = 1;
		*(lw__pio_write_ptr_clk) = clk;

		signed int x_val = *(lw__pio_read_ptr_x)/(2**20);
		signed int y_val = *(lw__pio_read_ptr_y)/(2**20);
		signed int z_val = *(lw__pio_read_ptr_z)/(2**20);

		VGA_Hline(x_val,y_val, x_val + 7, color[1]);

		sleep(0.10);


		// send to PIOs

		// receive back and print
		printf("x read=%d, x int =%d \n", *(lw__pio_read_ptr_x), x_val) ;
		
	} // end while(1)
} // end main


/****************************************************************************************
 * Draw a horixontal line on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_Hline(int x1, int y1, int x2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (x1>x2) SWAP(x1,x2);
	// line
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
}


/// /// ///////////////////////////////////// 
/// end /////////////////////////////////////