/* app_ethercat_test
 *
 * Test appliction for module_ethercat.
 *
 * Copyright 2011, Synapticon GmbH. All rights reserved.
 * Author: Frank Jeschke <jeschke@fjes.de>
 */

#include <platform.h>
#include <print.h>
#include <xs1.h>
#include <flash_C22.h>
#include <ethercat.h>
#include <foefs.h>

#include <flash.h>
#include <flashlib.h>
//#include <uip.h>
//#include <xtcp.h>

#define MAX_BUFFER_SIZE   7400  //7245

on stdcore[1] : out port ledBlue = LED_BLUE;
on stdcore[1] : out port ledGreen = LED_GREEN;
on stdcore[1] : out port ledRed = LED_RED;
unsigned addr=0;
/* request a file from the master */
static void get_file(chanend foe_out, char filename[])
{
	unsigned i, pos=0;
	unsigned outBuffer[20];
	//outBuffer[1] = REQUEST_FILE;p
	
	for (i=0, pos=2; filename[i] != '\n'; i++, pos++) {
		//outBuffer[pos++] = filename[i];p
	}

	//outBuffer[0] = pos;p

	for (i=0; i<pos; i++) {
		//foe_out <: outBuffer[i];p
	}
}

/* example consumer */
static void consumer(chanend coe_in, chanend coe_out, chanend eoe_in, chanend eoe_out
			/*, chanend foe_in, chanend foe_out, chanend pdo_in, chanend pdo_out*/)
{
	timer t;
	const unsigned int delay = 10;
	unsigned int time = 0;

	unsigned int inBuffer[MAX_BUFFER_SIZE];
	//unsigned int outBuffer[MAX_BUFFER_SIZE];
	unsigned int tmp = 0;
	unsigned int size = 0;
	unsigned count = 0;
	unsigned int outType = -1; /* FIXME set with define */
	unsigned outSize;

	unsigned int foePacketNbr = 0;
	int i;

	for (i=0; i<MAX_BUFFER_SIZE; i++) {
		inBuffer[i] = 0;
		//outBuffer[i] = 0;p
	}

	while (1) {
		/* Receive data */
		select {
		case coe_in :> tmp :
			inBuffer[0] = tmp&0xffff;
			//printstr("[APP] Received COE packet\n");
			count=0;

			while (count < inBuffer[0]) {
				coe_in :> tmp;
				inBuffer[count+1] = tmp&0xffff;
				count++;
			}

#if 0
			/* Reply with abort initiate download sequence */
			outType = COE_PACKET;
			outBuffer[0] = 5;
			outBuffer[1] = 0x2000;
			outBuffer[2] = 0x0080;
			outBuffer[3] = 0x001c;
			outBuffer[4] = 0x0000;
			outBuffer[5] = 0x0601;
#endif
			break;

		case eoe_in :> tmp :
			inBuffer[0] = tmp&0xffff;
			//printstr("[APP] Received EOE packet\n");
			count=0;
			while (count < inBuffer[0]) {
				eoe_in :> tmp;
				inBuffer[count+1] = tmp&0xffff;
				count++;
			}
			break;

#if 0
		case foe_in :> tmp :
			size = (uint16_t)(tmp&0xffff);
			count=0;

			while (count < size) {
				tmp = 0;
				foe_in :> tmp;
				inBuffer[count] = (tmp&0xffff);
				count++;
			}

			/* check packet content */
			tmp = (inBuffer[0])&0xff;
			foePacketNbr = inBuffer[1]&0xffff;

			switch (tmp) {
			case 0x01: /* FoE read req */
				//printstr("DEBUG main FoE read request\n");
				/* fixed answer, currently no file is stored */
				outType = FOE_PACKET;
				outBuffer[0] = 3;
				outBuffer[1] = 0x0005; /* error request */
				outBuffer[2] = 0x8001; /* not found */
				outBuffer[3] = 0x0000;
				break;

			case 0x02: /* FoE write req */
				//printstr("DEBUG main FoE write request\n");
				// reply with ack request
				outType = FOE_PACKET;
				outBuffer[0] = 3;
				outBuffer[1] = 0x0004; /* ack request */
				outBuffer[2] = 0x0000;
				outBuffer[3] = 0x0000;
				break;

			case 0x03: /* data request */
				printstr("Ignore data packet\n");
				//printstr("DEBUG main FoE data request, packet number: ");
#if 0 /* since SOEM doesn't support the ACK reply this is not send! */
				outType = FOE_PACKET;
				outBuffer[0] = 3;
#if 0
				outBuffer[1] = 0x0005; /* error request */
				outBuffer[2] = 0x8003; /* not found */
				outBuffer[3] = 0x0000;
#else
				outBuffer[1] = 0x0004; /* ack.req */
				outBuffer[2] = foePacketNbr;
				outBuffer[3] = 0x0000;
#endif
#endif
				break;

			case 0x04: /* ack request */
				printstr("DEBUG main FoE ack request\n");
				break;

			case 0x05: /* error request */
				printstr("DEBUG main FoE error request\n");
				break;

			case 0x06: /* busy request */
				printstr("DEBUG main FoE busy request\n");
				break;
			}

			break;
#endif

#if 0
		case pdo_out :> tmp :
			inBuffer[0] = tmp&0xffff;
			printstr("[APP] Received PDO packet: \n");

			count = 0;
			while (count<inBuffer[0]) {
				tmp = 0;
				pdo_out :> tmp;
				inBuffer[count+1] = (tmp&0xffff);
				count++;
			}

			if (inBuffer[1] == 0xde || inBuffer[1] == 0xad) {
				ledGreen <: 0;
			} else {
				ledGreen <: 1;
			}

			if (inBuffer[1] == 0xaa || inBuffer[1] == 0x66) {
				ledGreen <: 0;
			} else {
				ledRed <: 1;
			}

			/* DEBUG output of received packet: */
			for (i=1;i<count+1;i++) {
				printhex(inBuffer[i]);
				printstr(";");
			}
			printstr(".\n");
			// */

			break;
#endif
		}
/* send data */
		switch (outType /*outBuffer[0]*/) {
		case COE_PACKET:
			count=0;
			//printstr("[APP DEBUG] send CoE packet\n");
			//outSize = outBuffer[0]+1;p
			while (count<outSize) {
			//	coe_out <: outBuffer[count];p
				count++;
			}
			//outBuffer[0] = 0;p
			outType = -1;
			break;

		case EOE_PACKET:
			count=0;
			//printstr("DEBUG send EoE packet\n");
			//outSize = outBuffer[0]+1;p
			while (count<outSize) {
				//eoe_out <: outBuffer[count];p
				count++;
			}
			//outBuffer[0] = 0;p
			outType = -1;
			break;

#if 0 /* FIXME this resides in check_file() */
		case FOE_PACKET:
			count=0;
			//printstr("DEBUG send FoE packet\n");
			//outSize = outBuffer[0]+1;p
			while (count<outSize) {
				foe_out <: outBuffer[count];
				count++;
			}
			//outBuffer[0] = 0;p
			outType = -1; /* FIXME set correct define */
			break;
#endif
		default:
			break;
		}

		t :> time;
		t when timerafter(time+delay) :> void;
	}
}

static void check_file(chanend foe_comm, chanend foe_signal, chanend reset)
{
	timer t;
	unsigned time = 0;
	unsigned delay = 100000;
	char name[] = "test";
	unsigned i=0;
	int ctmp=0;
	int notification=0;
	unsigned address=0;

	/* wait some time until ethercat handler is ready */
	t :> time;
	t when timerafter(time+delay) :> void;

	while (1)
	{
		foe_signal :> notification;

		if (notification != FOE_FILE_READY) {
			t :> time;
			t when timerafter(time+delay) :> void;
			continue;
		}

		/* check if a file is present, FIXME: this could be realized by the signaling channel! */
		foe_comm <: FOE_FILE_OPEN;
		i=-1;
		do {
			i++;
			foe_comm <: (int)name[i];
		} while (name[i] != '\0');

		foe_comm :> ctmp;
		switch (ctmp) {
		case FOE_FILE_ERROR:
			//printstr("Error file is not ready\n");
			break;

		case FOE_FILE_ACK:
			/* File is ready read it and print to std. out */
			address=check_file_access(foe_comm, address, reset);
			break;

		default:
			//printstr("Unknown state returned\n");
			break;
		}

		//t :> time;
		//t when timerafter(time+delay) :> void;
	}
}

/* FIXME check channels! */
static void pdo_handler(chanend pdo_out, chanend pdo_in)
{
	unsigned int inBuffer[64];
	unsigned int count=0;
	unsigned int outCount=0;
	unsigned int tmp;

	timer t;
	const unsigned int delay = 100000;
	unsigned int time = 0;

	while (1){
		count = 0;

		select {
		case pdo_in :> tmp :
			inBuffer[0] = tmp&0xffff;
			//printstr("[APP DEBUG] Received PDO packet: \n");

			while (count<inBuffer[0]) {
				tmp = 0;
				pdo_in :> tmp;
				inBuffer[count+1] = (tmp&0xffff);
				//pprinthex(tmp&0xffff);
				count++;
			}
			//printstr("\n");

			if (inBuffer[1] == 0xdead || inBuffer[1] == 0xadde || inBuffer[1] == 0xbeef || inBuffer[1] == 0xefbe) {
				ledGreen <: 0;
			} else {
				ledGreen <: 1;
			}

			if (inBuffer[1] == 0xaaaa || inBuffer[1] == 0x6666) {
				ledRed <: 0;
			} else {
				ledRed <: 1;
			}
			break;
		default:
			break;
		}

#if 0
		if (count>0) {
			/* echo pdo input */
			printstr("[APP DEBUG] echo pdo packet\n");
			outCount=0;
			while (outCount < count) {
				pdo_out <: inBuffer[outCount++];
			}
		}
#endif
		//t :> time;
		//t when timerafter(time+delay) :> void;
	}
}

static void led_handler(void)
{
	timer t;
	const unsigned int delay = 50000000;
	unsigned int time = 0;
	int blueOn = 0;

	while (1) {
		t :> time;
		t when timerafter(time+delay) :> void;

		ledBlue <: blueOn;
		blueOn = ~blueOn & 0x1;
	}
}

int main(void) {

	chan coe_in;   ///< CAN from module_ethercat to consumer
	chan coe_out;  ///< CAN from consumer to module_ethercat
	chan eoe_in;   ///< Ethernet from module_ethercat to consumer
	chan eoe_out;  ///< Ethernet from consumer to module_ethercat
	chan foe_in;   ///< File from module_ethercat to consumer
	chan foe_out;  ///< File from consumer to module_ethercat
	chan pdo_in;
	chan pdo_out;

	chan sig_1, sig_2, sig_3, sig_4;

	par {
		on stdcore[0] : {
			ecat_init();
			ecat_handler(coe_out, coe_in, eoe_out, eoe_in, foe_out, foe_in, pdo_out, pdo_in);
		}

		on stdcore[1] : {
			consumer(coe_in, coe_out, eoe_in, eoe_out  /*, foe_in, foe_out, pdo_in, pdo_out*/);
		}

		on stdcore[0] : {
			check_file(foe_out, foe_in, sig_1);
		}

		on stdcore[1] : {
			pdo_handler(pdo_out, pdo_in);
		}


		on stdcore[0] :	{
			reset_cores(sig_1,sig_2);
		}

		on stdcore[1] : {
			reset_cores(sig_2,sig_3);
		}

		on stdcore[2] : {
			reset_cores(sig_3,sig_4);
		}

		on stdcore[3] :	{
			reset_last_core(sig_4);
		}
	}
	return 0;
}
