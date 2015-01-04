#include "mbed.h"
#include <string>
#include <sstream>
#include <vector>
#include "FXOS8700Q.h"
#include "MbedJSONValue.h"

#define CR              0xD
#define EXPECT          "mDot: "
#define M2X_DEVICE_ID   "a7bee74cd9a58ceeec3fcc38fa65193c"
#define M2X_API_KEY     "5a5c04fa6201f9695b97b176020c4907"
#define STARTUPTIME 5
#define SENSITIVITY 0.025
#define RESETTIME 1.0
#define ALIAS           "bigmeatsweats"
#define BULLSEYE        "bullseye"
#define INTERVAL        10

FXOS8700Q_acc acc( PTE25, PTE24, FXOS8700CQ_SLAVE_ADDR1); // Proper Ports and I2C Address for K64F Freedom board

void unsubscribeAllTriggers();
void soft_radio_reset();
void getSubscriptions();
void configureMdot();
void getConfiguration();
void subscribeTriggers(const char*);
string getDeviceId();

DigitalOut ledr(PTB22);
DigitalOut ledg(PTE26);
DigitalOut ledb(PTB21);

MotionSensorDataUnits mag_data;
MotionSensorDataUnits acc_data;

Serial dot(D1, D0);
Serial pc(USBTX, USBRX);

vector<string> triggers;

static bool send_command(Serial* ser, const string& tx, string& rx);
static int raw_send_command(Serial* ser, const string& tx, string& rx);
static bool rx_done(const string& rx, const string& expect);
MbedJSONValue parse_rx_messages(const string& messages);

int main()
{   
    acc.enable();
    
    float faY = 0;
    float fmY = 0;
    int calibration = 0;
    
    ledr = 0;
    ledg = 1;
    ledb = 1;
    
    dot.baud(9600);
    pc.baud(9600);

    printf("\r\n\r\nSTARTING NEW GAME...\r\n\r\n");

    stringstream cmd;
    string res;
    string id = getDeviceId();
    printf("Device Id: %s\r\n", id.c_str());
    
#ifdef ALIAS
    id = ALIAS;
    printf("Device Alias: %s\r\n", id.c_str());
#endif
    getConfiguration();
    
    ledr = 0;
    ledg = 0;
    ledb = 1;
    

    printf("Entering Calibration mode....\r\n");
    int counter = 1;
    
    Timer report_timer;
    report_timer.start();
    while (true) {
        
        if (report_timer.read() > INTERVAL) {
            ledr = 1;
            ledg = 0;
            ledb = 1;
            
            calibration = 1;
            report_timer.reset();
            report_timer.stop();
        }
            
        if(calibration != 0){
            acc.getAxis(acc_data);
            
            if(calibration == 1){
                faY =   acc_data.y;                
                printf("\rCalibrated at: Y=%1.4f\n", faY);
                calibration = 2;
            }    
            
            fmY = acc_data.y;

            if( abs(fmY - faY) > SENSITIVITY){
                printf("\r\nDIRECT HIT!!\r\n");
                ledr = 1;
                ledg = 1;
                ledb = 0;
                cmd.str("");
                cmd.clear();
                cmd << "ATSEND " << BULLSEYE << ":" << counter;
                printf("sending %s [%s]\r\n", BULLSEYE, cmd.str().c_str());
                if (! send_command(&dot, cmd.str(), res)) {
                    printf("failed to send %s\r\n", BULLSEYE);
                }
                else{
                    counter++;
                }     
                wait(RESETTIME);
                ledr = 1;
                ledg = 0;
                ledb = 1;
            } 
            

            printf("\r\n Acceleration Profile: X=%1.4f Y=%1.4f Z=%1.4f  ", acc_data.x, acc_data.y, acc_data.z);
        }
        wait(0.25);
    }

    return 0;
}

/** Parse ATRECV output for json messages
 */
MbedJSONValue parse_rx_messages(const string& messages)
{
    MbedJSONValue msgs;

    // find start of first json object
    int beg_pos = messages.find("{");
    int end_pos = 0;
    int count = 0;

    while (beg_pos != string::npos) {
        // find end of line
        end_pos = messages.find("\r", beg_pos);

        // pull json string from messages
        string json = messages.substr(beg_pos, end_pos-beg_pos);

        // parse json string
        string ret = parse(msgs[count], json.c_str());

        if (ret != "") {
            printf("invalid json: '%s'\r\n", json.c_str());
        } else {
            count++;
        }

        // find start of next json object
        beg_pos = messages.find("{", end_pos);
    }

    return msgs;
}

/** Send a command to the mDot radio expecting an OK response
 *
 */
static bool send_command(Serial* ser, const string& tx, string& rx)
{
    int ret;

    rx.clear();

    if ((ret = raw_send_command(ser, tx, rx)) < 0) {
        printf("raw_send_command failed %d\r\n", ret);
        return false;
    }
    if (rx.find("OK") == string::npos) {
        printf("no OK in response\r\n");
        return false;
    }

    return true;
}

/** Check response for expected string value
 */
static bool rx_done(const string& rx, const string& expect)
{
    return (rx.find(expect) == string::npos) ? false : true;
}

/** Send command to mDot radio without checking response
 */
static int raw_send_command(Serial* ser, const string& tx, string& rx)
{
    if (! ser)
        return -1;

    int to_send = tx.size();
    int sent = 0;
    Timer tmr;
    string junk;

    // send a CR and read any leftover/garbage data
    ser->putc(CR);
    tmr.start();
    while (tmr.read_ms() < 500 && !rx_done(junk, EXPECT))
        if (ser->readable())
            junk += ser->getc();

    tmr.reset();
    tmr.start();
    while (sent < to_send && tmr.read_ms() <= 1000)
        if (ser->writeable())
            ser->putc(tx[sent++]);

    if (sent < to_send)
        return -1;

    // send newline after command
    ser->putc(CR);

    tmr.reset();
    tmr.start();
    while (tmr.read_ms() < 10000 && !rx_done(rx, EXPECT))
        if (ser->readable())
            rx += ser->getc();

    return rx.size();
}

/** Send M2X configuration data to Condit Server
 *
 */
void configureMdot()
{
    stringstream cmd;
    string res;

    printf("Configuring mDot...\r\n");

    // using stringstreams is an easy to way to get non-string data into a string
    // don't forget to reset them between uses, though
    // call .str("") and .clear() on them to reset
    
    cmd.str("");
    cmd.clear();
    cmd << "ATSEND feed-id:" << M2X_DEVICE_ID;
    printf("setting feed-id [%s]\r\n", cmd.str().c_str());
    if (! send_command(&dot, cmd.str(), res))
        printf("failed to set feed-id\r\n");

    cmd.str("");
    cmd.clear();
    cmd << "ATSEND m2x-key:" << M2X_API_KEY;
    printf("setting m2x-key [%s]\r\n", cmd.str().c_str());
    if (! send_command(&dot, cmd.str(), res))
        printf("failed to set m2x-key\r\n");
    
#ifdef ALIAS
    cmd.str("");
    cmd.clear();
    cmd << "ATSEND alias:" << ALIAS;
    printf("setting alias [%s]\r\n", cmd.str().c_str());
    if (! send_command(&dot, cmd.str(), res))
        printf("failed to set alias\r\n");
#endif

}

/** Subscribe to triggers expected to be received from M2X
 *  
 *  Triggers must be configured in M2X account before any will be received
 *
 *  See https://m2x.att.com/developer/tutorials/triggers
 */
void subscribeTriggers(const char* id)
{
    printf("subscribing to triggers\r\n");
    
    stringstream cmd;
    string res;
    
    for (int i = 0; i < triggers.size(); i++) {
        cmd.str("");
        cmd.clear();
        cmd << "ATSEND subscribe:" << id << "-" << triggers[i];
        printf("subscribing [%s]\r\n", cmd.str().c_str());
        if (! send_command(&dot, cmd.str(), res))
            printf("failed to subscribe\r\n");
    }
}

/** Read device Id from mDot card
 *
 */
string getDeviceId() {
    string cmd = "ATID";
    string res;
    string id = "";
    
    // loop here till we get response
    // if we can't get the id the radio isn't working
    while (id == "") {
        if (! send_command(&dot, cmd, res)) {
            printf("failed to get device id\r\n");
        } else {
            int id_beg = res.find("Id: ");
            int id_end = res.find("\r", id_beg);
            
            if (id_beg != string::npos && id_end != string::npos) {
                id_beg += 4;                
                id = res.substr(id_beg, id_end-id_beg);
                if (id.size() == 1)
                    id = "0" + id;
            }
        }
    }
    
    return id;
}

/** Request config from Conduit server
 */
void getConfiguration()
{
    string cmd = "ATSEND config:";
    string res;
    printf("asking for config [%s]\r\n", cmd.c_str());
    if (! send_command(&dot, cmd, res))
        printf("failed to ask for config\r\n");
}

/** Request subscriptions from Conduit server
 */
void getSubscriptions()
{
    string cmd = "ATSEND subs:";
    string res;
    printf("asking for subscriptions [%s]\r\n", cmd.c_str());
    if (! send_command(&dot, cmd, res))
        printf("failed to ask for subscriptions\r\n");
}

/** Reset mDot radio
 */
void soft_radio_reset() {
    string cmd = "RESET";
    string res;
    bool done = false;
    while(!done) {
        printf("send reset radio command\r\n");
        raw_send_command(&dot, cmd, res);
        if (res.find("MultiTech Systems LoRa XBee Module") != string::npos && res.find("mDot:") != string::npos) {
            done = true;
        } else {
            printf("strings not found in reset response, [%s]\r\n", res.c_str());
        }
        wait(1);
    }
    printf("radio reset complete\r\n");
}

/** Unsubscribe from all triggers
 */
void unsubscribeAllTriggers()
{
    string cmd = "ATSEND unsubscribe:all";
    string res;
    printf("canceling all subscriptions [%s]\r\n", cmd.c_str());
    if (! send_command(&dot, cmd, res))
        printf("failed to cancel subscriptions\r\n");
}
