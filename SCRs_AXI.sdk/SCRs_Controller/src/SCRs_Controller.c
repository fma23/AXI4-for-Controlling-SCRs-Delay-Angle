#include "xparameters.h"
#include "xstatus.h"
#include "xil_printf.h"
#include "xuartps_hw.h"
#include "xbasic_types.h"
#include "math.h"
#include "platform.h"


#define BUFFER_SIZE 2
#define CyclesPerPeriod  2000000
#define ClockCycles      100000000


int ReceiveBuffer[BUFFER_SIZE]; /* Buffer for Transmitting Data */

Xuint32 *baseaddr_p = (Xuint32 *)XPAR_SCRS_CONTROLLER_0_S00_AXI_BASEADDR;




void Wait(int num);
int sleep(unsigned int seconds);

int Calculate_RisingEdgeCounter(int *temp);
int Calculate_FallingEdgeCounter(int *temp);


int main(void)
{

u8 counter=0;
int temp=0;


int RisingEdgeCounter=0;
int FallingEdgeCounter=0;


 xil_printf("Enter a value between 0 and 90 degrees for phase delay: \n");

 while(1)
 {

	 if(XUartPs_IsReceiveData(STDIN_BASEADDRESS))
	 {
		  counter++;

		  if(counter==1)
		  {
			ReceiveBuffer[0]=0;
			ReceiveBuffer[1]=0;

			ReceiveBuffer[0]=XUartPs_RecvByte(STDIN_BASEADDRESS);     //receive data from terra term
		  }
		  else
		  {

		  ReceiveBuffer[1]=XUartPs_RecvByte(STDIN_BASEADDRESS);     //receive data from terra term

		  temp=(ReceiveBuffer[0]-48)*10;
		  temp=temp+(ReceiveBuffer[1]-48);

		  xil_printf("phase angle delay value entered is: %d \n",temp);

		 //compute rising edge counter
		  RisingEdgeCounter= Calculate_RisingEdgeCounter(&temp);
		  xil_printf("RisingEdgeCounter is %d: \n",RisingEdgeCounter);

		 // compute falling edge counter
		  FallingEdgeCounter= Calculate_FallingEdgeCounter(&RisingEdgeCounter);
		  xil_printf("FallingEdgeCounter is %d: \n",FallingEdgeCounter);

		  counter=0;
		  temp=0;

		  *(baseaddr_p+0) = RisingEdgeCounter;                         //RisingEdgeCounter 2 LSB Bytes
		   xil_printf("register 0 is %d: \n",*(baseaddr_p+0));

		  *(baseaddr_p+1) = FallingEdgeCounter;                        //FallingEdgeCounter 2 MSB bytes
		  xil_printf("register 1 is %d: \n",*(baseaddr_p+1));

		  *(baseaddr_p+2) = 1;  //send a reset
		  sleep(1);
		  *(baseaddr_p+2) = 0;

		  xil_printf("Enter a value between 0 and 90 degrees for phase delay: \n");
		  }


	 }
}


return 0;
}


int Calculate_RisingEdgeCounter(int *temp)
{
	float tempvalue=0;


	tempvalue=(*temp)*CyclesPerPeriod;  //ON time
	tempvalue=tempvalue/360;


	return((int)tempvalue);
}

int Calculate_FallingEdgeCounter(int *RisingEdgeCounter)
{

	float tempvalue=0;

	//tempvalue=0.016667/3;
	tempvalue=0.02/3;
	//tempvalue=tempvalue*100000000+(*RisingEdgeCounter);
	tempvalue=tempvalue*100000000; //-(*RisingEdgeCounter);
	return((int)tempvalue);

}
