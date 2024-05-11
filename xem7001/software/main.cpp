#include <ostream>
#include <iostream>
#include <bitset>
#include <unordered_set>
#include <vector>

#include "okFrontPanel.h"

using namespace std;

void showSurroundings(vector<uint16_t>& raw, int i) {
    for(int j = max(0, i-20); j < i + 20; j++) {
        printf("Index: %d, Data: %d\n", j, raw[j]);
    }
}

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
    */

    vector<vector<uint16_t>> data(8, vector<uint16_t>());

    uint16_t raw[1010000];
    
   unsigned char data_in[4096];

   bool expecting_index = true;
    
    int data_count = 0;
    while (data_count < 1e6) {
        // Read to buffer from PipeOut endpoint with address 0xA0
        written = dev->ReadFromPipeOut(0xA0, sizeof(data_in), data_in);
        for (int i = 0; i < sizeof(data_in); i += 2) {
            uint16_t v = (data_in[i+1] << 8) + data_in[i];
            if (expecting_index && v == 0) continue;
            raw[data_count] = v;
            data_count++;
            expecting_index = !expecting_index;
        }
        //printf("%d: 0x%x%x\n", written, datain[1], datain[0]);*/
    }
    cout << data_count << endl;
    uint16_t index = 0;
    bool expecting_channel = true;
    int error_count = 0;
    for(int i = 0; i < data_count; i++){
        if (!expecting_channel) {
            data[index-1].push_back(raw[i]);
        } else {
            if (raw[i] < 1 || raw[i] > 8) {
                // printf("Invalid channel %d at index %d\n", index, i);
                // showSurroundings(raw, i);
                error_count += 1;
                continue;
            }
            index = raw[i];
        }
        expecting_channel = !expecting_channel;
    }
    cout << "Invalid Index Count: " << error_count << endl;
    for (int i = 0; i < 8; i++) {
	    printf("Channel %d had %d values before terminating\n", i+1, data[i].size());
    }
    vector<int> channel_error_count(8, 0);
    for (int c = 0; c < 8; c++) {
        for(int i = 1; i < data[c].size(); i++){
            if (data[c][i] != data[c][i-1] + 1) {
                //printf("Invalid data found for channel %d, index %d: %d, should be %d\n", c, i, data[c][i], data[c][i-1] + 1);
                //showSurroundings(data[c], i);
                channel_error_count[c]++;
            }
        }
    }
    for (int i = 0; i < 8; i++) {
	    printf("Channel %d had %d incorrect values. Error rate: %.2f\n", i+1, channel_error_count[i], (float)channel_error_count[i]/(float)data[i].size());
    }
    return 0;

}