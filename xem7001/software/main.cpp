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
    
    error = dev->ConfigureFPGA("toplevel.bit");
    // It’s a good idea to check for errors here!

    cout << error << endl;
    
    /*
    // Send brief reset signal to initialize the FIFO.
    dev->SetWireInValue(0x10, 0xff, 0x01);
    dev->UpdateWireIns();
    dev->SetWireInValue(0x10, 0x00, 0x01);
    dev->UpdateWireIns();
    */

    vector<vector<uint16_t>> data(8, vector<uint16_t>());

    vector<uint16_t> raw;
    
   unsigned char data_in[512];

   bool expecting_index = true;
    
    while (raw.size() < 1e6) {
        // Read to buffer from PipeOut endpoint with address 0xA0
        written = dev->ReadFromPipeOut(0xA0, sizeof(data_in), data_in);
        for (int i = 0; i < sizeof(data_in); i += 2) {
            uint16_t v = (data_in[i+1] << 8) + data_in[i];
            if (expecting_index && v == 0) continue;
            raw.push_back(v);
            expecting_index = !expecting_index;
        }
        //printf("%d: 0x%x%x\n", written, datain[1], datain[0]);*/
    }
    cout << raw.size() << endl;
    uint16_t index = 0;
    for(int i = 0; i < raw.size(); i++){
        if (i % 2) {
            if (index < 1 || index > 8) {
                printf("Invalid index %d at data %d\n", index, i);
                continue;
            }
            data[index-1].push_back(raw[i]);
        } else {
            index = raw[i];
        }
    }
    for (int i = 0; i < 8; i++) {
	    printf("Channel %d had %d values before terminating\n", i+1, data[i].size());
    }
    for (int c = 0; c < 8; c++) {
        for(int i = 1; i < data[c].size(); i++){
            if (data[c][i] != data[c][i-1] + 1) printf("Invalid data found for channel %d, index %d: %d, should be %d\n", c, i, data[c][i], data[c][i-1] + 1);
        }
    }
    return 0;

}