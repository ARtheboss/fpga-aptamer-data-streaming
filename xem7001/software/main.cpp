int main() {

    okCFrontPanel dev;
    okCFrontPanel::ErrorCode error;
    unsigned char dataout[128];
    unsigned char datain[128];
    int i;
    long written;
    
    dev.OpenBySerial();
    error = dev.ConfigureFPGA("example.bit");
    // It’s a good idea to check for errors here!
    
    // Send brief reset signal to initialize the FIFO.
    dev.SetWireInValue(0x10, 0xff, 0x01);
    dev.UpdateWireIns();
    dev.SetWireInValue(0x10, 0x00, 0x01);
    dev.UpdateWireIns();
    
    for (i = 0; i < sizeof(dataout); i++) {
        // Load outgoing data buffer.
    }
    
    while (1) {
        // Read to buffer from PipeOut endpoint with address 0xA0
        written = dev.ReadFromPipeOut(0xA0, sizeof(datain), datain);
        cout << written << endl;
    }
    return 0;

}