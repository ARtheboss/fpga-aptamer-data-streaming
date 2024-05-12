#include <ostream>
#include <iostream>
#include <fstream>
#include <bitset>
#include <unordered_set>
#include <vector>
#include <list>

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

    long written;
    
    error = dev->ConfigureFPGA("./bitfiles/640kHz_counter.bit");
    if (error > 0) {
        printf("Error when configuring with bitfile: %d\n", error);
        return 2;
    }
    printf ("Device Configuration Success.\n");

    vector<vector<uint16_t>> data(8, vector<uint16_t>());
    
    std::list<uint16_t> raw;
    
    unsigned char data_in[4096];

    bool ready = false;
    while (!ready) {
        dev->UpdateTriggerOuts();
        ready = dev->IsTriggered(0x6a, (short)1);
    }

    printf("Trigger received, fetching data.\n");
    
    int data_count = 0;
    uint16_t v;
    while (ready) {
        dev->UpdateTriggerOuts();
        written = dev->ReadFromPipeOut(0xA0, sizeof(data_in), data_in);
        for (int i = 0; i < sizeof(data_in); i += 2) {
            v = (data_in[i+1] << 8) + data_in[i];
            if (v == 0xffff) continue; // fifo empty
            raw.push_back(v);
            data_count++;
        }
        ready = dev->IsTriggered(0x6a, (short)1);
    }
    printf("Received %d words.\n");
    uint16_t index = 0;
    int error_count = 0;
    auto it = raw.begin();
    for (; it != raw.end(); ++it){
        if (index == 0 || index > 8) {
            if (*it != 0xfffe) {
                error_count++;
                continue;
            } else {
                index = 0;
            }
        }
        if (index > 0) {
            data[index-1].push_back(*it);
        }
        index++;
    }
    std::cout << "Invalid Index Count: " << error_count << endl;
    for (int i = 0; i < 8; i++) {
	    printf("Channel %d had %d values before terminating\n", i+1, data[i].size());
    }
    std::ofstream data_file;
    data_file.open("data.csv");
    for (int i = 0; i < data[0].size(); i++) {
        string s = "";
        for (int j = 0; j < 8; j++) {
            s += to_string(data[j][i]) + ",";
        }
        data_file << s << "\n";
    }
    data_file.close();
    return 0;
}