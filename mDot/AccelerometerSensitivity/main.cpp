#include "mbed.h"
#include "FXOS8700Q.h"

#define STARTUPTIME 5
#define SENSITIVITY 0.030
#define RESETTIME 1.0


FXOS8700Q_acc acc( PTE25, PTE24, FXOS8700CQ_SLAVE_ADDR1); // Proper Ports and I2C Address for K64F Freedom board
FXOS8700Q_mag mag( PTE25, PTE24, FXOS8700CQ_SLAVE_ADDR1); // Proper Ports and I2C Address for K64F Freedom board

Serial pc(USBTX, USBRX);

MotionSensorDataUnits mag_data;
MotionSensorDataUnits acc_data;

MotionSensorDataCounts mag_raw;
MotionSensorDataCounts acc_raw;

DigitalOut ledr(PTB22);
DigitalOut ledg(PTE26);
DigitalOut ledb(PTB21);



int main() {
float faY, fmY;


acc.enable();

Timer report_timer;
report_timer.start();
int calibrated = 0;

ledr = 0;
ledg = 1;
ledb = 1;

printf("\r\n\nEntering Calibration Phase .... %X\r\n", acc.whoAmI());
    while (true) {

        
        if (report_timer.read() > STARTUPTIME) {
            ledr = !ledr;
            ledg = !ledg;
            report_timer.reset();
            report_timer.stop();
            printf("\r\nCalibrated! Now gathering sensor data...\r\n\n");
            calibrated = 1;
        }
        
        
        if(calibrated != 0){
            acc.getAxis(acc_data);
            mag.getAxis(mag_data);
            
            if(calibrated == 1){
                //faX =   acc_data.x;
                faY =   acc_data.y;
                //faZ =   acc_data.z;
                
                printf("\rCalibrated at: Y=%1.4f\n", faY);
                calibrated = 2;
            }    
            
            //fmX = acc_data.x;
            fmY = acc_data.y;
            //fmZ = acc_data.z;
            
            if( abs(fmY - faY) > SENSITIVITY){
                printf("\r\nDIRECT HIT!!\r\n");
                ledr = 1;
                ledg = 1;
                ledb = 0;
                wait(RESETTIME);
                ledr = 1;
                ledg = 0;
                ledb = 1;
            } 
            
            printf("\r\n Acceleration Profile: X=%1.4f Y=%1.4f Z=%1.4f  ", acc_data.x, acc_data.y, acc_data.z);
        }          
        wait(0.2);
    }
}