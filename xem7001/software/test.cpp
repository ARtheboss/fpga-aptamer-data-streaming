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

    std::cout << "entry" << endl;

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
    std::cout << "dev gotten" << endl;

    long written;
    
    error = dev->ConfigureFPGA("640kHz2.bit");

    std::cout << "Error code: " + error << endl;

    bool ready = false;
    while (!ready) {
        dev->UpdateTriggerOuts();
        ready = dev->IsTriggered(0x6a, (short)1);
    }

    vector<vector<uint16_t>> data(8, vector<uint16_t>());
    
    uint16_t raw[1010000];
    
    unsigned char data_in[4096];
    
    int data_count = 0;
    uint16_t v;
    int not_found_count = 0;
    while (data_count < 1e5) {
        // Read to buffer from PipeOut endpoint with address 0xA0
        written = dev->ReadFromPipeOut(0xA0, sizeof(data_in), data_in);
        bool found_data = false;
        for (int i = 0; i < sizeof(data_in); i += 2) {
            v = (data_in[i+1] << 8) + data_in[i];
            if (v == 0xffff) continue;
            raw[data_count] = v;
            data_count++;
            found_data = true;
        }
        // if (found_data) not_found_count = 0;
        // else not_found_count++;
        // if (not_found_count > 100) {
        //     for(int j = data_count - 1000; j < data_count; j++) std::cout << j << ": " << raw[j] << endl;
        //     break;
        // }
        std::cout << written << " " << data_count << " " << found_data << endl;
        //printf("%d: 0x%x%x\n", written, datain[1], datain[0]);*/
    }
    std::cout << data_count << endl;
    uint16_t index = 0;
    int error_count = 0;
    for(int i = 0; i < data_count; i++){
        if (index == 0 || index > 8) {
            if (raw[i] != 0xfffe) {
                error_count++;
                continue;
            } else {
                index = 0;
            }
        }
        if (index > 0) {
            data[index-1].push_back(raw[i]);
        }
        index++;
    }
    std::cout << "Invalid Index Count: " << error_count << endl;
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