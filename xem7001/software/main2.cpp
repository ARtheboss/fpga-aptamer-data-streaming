#include <ostream>
#include <iostream>
#include <bitset>
#include <unordered_set>
#include <vector>

#include "okFrontPanel.h"

using namespace std;

int main() {

    cout << "entry" << endl;

    OpalKelly::FrontPanelDevices devices;
    OpalKelly::FrontPanelPtr devptr = devices.Open();
    okCFrontPanel* const dev = devptr.get();	
    okCFrontPanel::ErrorCode error;

    if (!dev) {
		if (!devices.GetCount()) {
			printf("No connected devices detected.\n");
		} else {
			// We do have some device(s), but not with the specified serial.
			printf("Device could not be opened.\n");
		}

		return (1);
	}
    cout << "dev gotten" << endl;

    //unsigned char dataout[128];
    int i;
    long written;
    
    error = dev->ConfigureFPGA("640kHz.bit");
    // It’s a good idea to check for errors here!

    cout << error << endl;
    
    /*
    // Send brief reset signal to initialize the FIFO.
    dev->SetWireInValue(0x10, 0xff, 0x01);
    dev->UpdateWireIns();
    dev->SetWireInValue(0x10, 0x00, 0x01);
    dev->UpdateWireIns();
    
    for (i = 0; i < sizeof(dataout); i++) {
        // Load outgoing data buffer.
    }
    */

    unsigned char data_in[2048];
    while (true) {
        written = dev->ReadFromPipeOut(0xA0, sizeof(data_in), data_in);
        uint16_t first = (data_in[2+1] << 8) + data_in[2];
        uint16_t last = (data_in[sizeof(data_in)-2+1] << 8) + data_in[sizeof(data_in)-2];
        //cout << first << " " << last << endl;
        /*
        for (int i = 0; i < sizeof(data_in); i += 2) {
            uint16_t v = (data_in[i+1] << 8) + data_in[i];
            printf("%d: %d, ", i, v);
        }
        cout << endl;
        */
    }
    return 0;

}