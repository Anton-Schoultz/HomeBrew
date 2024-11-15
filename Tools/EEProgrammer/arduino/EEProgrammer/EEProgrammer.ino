/*
Simple DIY EEPROM programer for PQ 52B33 8k x 8 EEPROM (Using Arduino Nano)

The 52B33 supports a chip-erase that clears the whole chip in one step. In this event it is not necessary to write FF
to a location before writing data to it.

In this programmer, 'E'rase clears the chip and enables 'fast' writes (skips writting the FF).
As soon as anything other than a write command (either intel hex line or 'W'rite) is used, fast mode is disabled.

Circuit uses 74hc164 shift regisisters connected in series to make a 16 bit shift register which provides the address lines.
(Most significat bit is shifted out first.) Two pins are used to drive this - SHIFT_DATA & SHIFT_CLK

A number of i/o pins are used to connect to the data lines of the eeprom.

This programmer is based on request/response protocol, line by line. (CR is ignored) LF marks end of line.

Java program EEPromProgrammer (with jSerialComm-2.9.2.jar) acts as host on PC side.

Anton Schoultz 2023

?       Help
E       Erase the chip (enables fast write)
R[nn]   Read [nn] rows of data
Wxxxx   Write hex data at current address and move on
Ahhll   Set current address as hhll
:xx..   Intel Hex8 format line (type 00=data record)
Dxxxx[A] Dump as intel hex data records. xxxx=size, A=Ack

*/

/* sets the comunication baud rate - must match the PC program */
// 9600,19200,31250,38400,57600,74880,115200
#define SERIAL_BAUD_RATE 57600

// 8K=$2000 (8192)
#define EEPROM_SIZE 0x2000

/* 
Pins used to drive the shift registers 
for the address lines 
*/
#define SHIFT_DATA 2
#define SHIFT_CLK 3
/*
Pins used to connect directly to the ee data pins
*/
#define EE_D0 4
#define EE_D1 5
#define EE_D2 6
#define EE_D3 7
#define EE_D4 8
#define EE_D5 9
#define EE_D6 10
#define EE_D7 11
#define EE_nOE 12
#define EE_nWE 13
#define EE_nCC A0

/*
Some delay constants
*/
#define DLY_ERASE 20  // spec is 10 mSec
#define DLY_WRITE 15  // spec says 9 mSec
#define DLY_WAIT 1
#define DLY_MODE 2

/*
Programmer mode 
*/
#define MODE_NONE -1
#define MODE_READ 0
#define MODE_WRITE 1

/* no of bytes to write into iHEX record */
#define PG 32

#define CR 13
#define LF 10

int addr = 0;    // current address
int sum = 0;     // check sum while reading/writing iHEX
int maxAdr = 0;  // tracks last address written (default end for 'D'ump)

int mode = MODE_NONE;  // current mode

// controls if we erase each location first or not
// (it is not necessary if the chip has been erased)
// 'E'rase truns this on, any non-write command turns it off
boolean fastWrite = false;

/* buffers are shared between subroutines */
char strBuf[80];  // string buffer

// input
String input;  // input string
int ix;        // index into input

byte dataBuf[40];  // data buffer

/* --------------------------------------------- setup
Sets up the pin modes and safe state for control
lines. Display help and stat off in READ mode.
*/
void setup() {
  // pins that drive the address shift registers
  pinMode(SHIFT_DATA, OUTPUT);
  pinMode(SHIFT_CLK, OUTPUT);
  // output enable (!RD)
  digitalWrite(EE_nOE, 1);
  pinMode(EE_nOE, OUTPUT);
  // write enable (!WR)
  digitalWrite(EE_nWE, 1);
  pinMode(EE_nWE, OUTPUT);
  // chip clear / erase chip (!CC)
  digitalWrite(EE_nCC, 1);
  pinMode(EE_nCC, OUTPUT);
  // start up serial port
  Serial.begin(SERIAL_BAUD_RATE);
  // greeting
  help();
  // initial mode
  mode = MODE_NONE;
  readyToRead();
}

/* --------------------------------------------- help 
Dispalys the help screen 
*/
void help() {
  Serial.println(F("EEPROM programer - by Anton Schoultz 2024/11/15"));
  Serial.println(F("?       Help"));
  Serial.println(F("E       Erase the chip (enables fast write)"));
  Serial.println(F("R[nn]   Read [nn] rows of data"));
  Serial.println(F("Wxxxx   Write hex data at current address and move on"));
  Serial.println(F("Ahhll   Set current address as hhll"));
  Serial.println(F(":xx..   Intel Hex8 format line (type 00=data record)"));
  Serial.println(F("Dxxxx[A] Dump as intel hex data records. xxxx=size, A=Ack"));
}

/* --------------------------------------------- inputLine
Read a line fo text from the Serial Port into input.
Sends "READY" to serial, gets the inpout line.
Returns the first character of the line.
*/
char inputLine() {
  Serial.println("READY");
  while (Serial.available() == 0) {}  //wait for data available
  input = Serial.readString();        //read until timeout
  input.trim();
  input.toUpperCase();
  if (input.length() == 0) return 0;  // empty line
  ix = 1;
  return input.charAt(0);
}

/* --------------------------------------------- nextChar
returns the next character from the input string.
null if no more.
*/
char nextChar() {
  if (ix >= input.length()) return 0;
  return input.charAt(ix++);
}


/* --------------------------------------------- getHex
Read hex value from the input string.
(Tally check sum as we go)
*/
int getHex() {
  int val = 0;
  char h = nextChar();
  char l = nextChar();
  if (h == 0 || l == 0) return -1;  // no more hex digits
  if (h >= '0' && h <= '9') val = (h - '0') * 16;
  if (h >= 'A' && h <= 'F') val = (h - 'A' + 10) * 16;
  if (l >= '0' && l <= '9') val = val + (l - '0');
  if (l >= 'A' && l <= 'F') val = val + (l - 'A' + 10);
  if (val >= 0) {
    sum += val;  // track check sum
  }
  return val;
}

/* --------------------------------------------- setAddress
shifts the address out to the two cascaded shift registers 
*/
void setAddress(int adr) {
  shiftOut(SHIFT_DATA, SHIFT_CLK, MSBFIRST, (adr >> 8));
  shiftOut(SHIFT_DATA, SHIFT_CLK, MSBFIRST, adr);
}

/* --------------------------------------------- inactive
make all control lines inacctive (high)
*/
void inactive() {
  digitalWrite(EE_nOE, 1);
  digitalWrite(EE_nWE, 1);
  digitalWrite(EE_nCC, 1);
}

/* --------------------------------------------- readyToRead
prepare to read from the port, change to READ mode
*/
void readyToRead() {
  // keep control lines inactive
  inactive();
  // set up the data pins for input
  if (mode != MODE_READ) {
    for (int p = EE_D0; p <= EE_D7; p++) {
      pinMode(p, INPUT);
    }
    mode = MODE_READ;
    delay(DLY_MODE);
  }
}

/* --------------------------------------------- read
Read data from eeprom at the given address 
*/
int read(int adr) {
  setAddress(adr);
  digitalWrite(EE_nOE, LOW);  // read low to enable output
  delay(DLY_WAIT);            // let it settle
  // read pins one-by-one and shift into data
  int data = 0;
  for (int p = EE_D7; p >= EE_D0; p--) {
    data = (data << 1) | digitalRead(p);
  }
  digitalWrite(EE_nOE, HIGH);  // read back high
  delay(DLY_WAIT);             // delay for OE
  return data;
}

/* --------------------------------------------- readyForWrite
prepare to write to the data port, change to WRITE mode
*/
void readyToWrite() {
  // keep controls inactive
  inactive();
  // set the data port pins to output (high)
  if (mode != MODE_WRITE) {
    for (int p = EE_D0; p <= EE_D7; p += 1) {
      digitalWrite(p, HIGH);
      pinMode(p, OUTPUT);
    }
    mode = MODE_WRITE;
    delay(DLY_WAIT);
  }
}

/* --------------------------------------------- writeData
Set as output, then write a byte */
/* set as input, then fetch a byte of data */
void writeData(int data) {
  // place the data bits on the port
  for (int p = EE_D0; p <= EE_D7; p += 1) {
    digitalWrite(p, data & 1);  // write bit
    data = data >> 1;           // shift right to next higher bit
  }
  // settle, pulse write
  delay(DLY_WAIT);             // let it settle
  digitalWrite(EE_nWE, LOW);   // Write pulsed low
  delay(DLY_WRITE);            // Spec say 9mSec write pulse
  digitalWrite(EE_nWE, HIGH);  // and back to inactive state
  delay(DLY_WAIT);
}

/* --------------------------------------------- write
Write the provided data byte to the given address.
(Tracks the highest address written to for 'D'ump) 
*/
void write(int adr, int data) {
  // ensure that we are in WRITE mode
  readyToWrite();  // includes in-active
  // set the address
  setAddress(adr);
  // erase the location (inless already erased)
  if (!fastWrite) {
    writeData(0xFF);
  }
  // program the byte into the location
  writeData(data);
  // track max memory written for 'D'ump
  if (adr > maxAdr) { maxAdr = adr; }
}

/* --------------------------------------------- eraseChip
Erase the chip and rest the highest address used.
*/
void eraseChip() {
  digitalWrite(EE_nCC, LOW);
  delay(DLY_WAIT);
  digitalWrite(EE_nWE, LOW);
  delay(DLY_ERASE);  // delay for chip erase
  digitalWrite(EE_nWE, HIGH);
  delay(DLY_WAIT);
  digitalWrite(EE_nCC, HIGH);
  delay(DLY_WAIT);
  maxAdr = 0;  //reset max memory address
  Serial.print(F("Chip has been errased. "));
}

/* --------------------------------------------- showData
Display 16 bytes of data at the provided address
*/
void showData(int base) {
  readyToRead();
  // Read data from chip into data buffer
  for (int i = 0; i < 16; i++) {
    dataBuf[i] = read(base + i);
  }
  // display the data
  sprintf(strBuf, "%04x: %02x %02x %02x %02x %02x %02x %02x %02x   %02x %02x %02x %02x %02x %02x %02x %02x",
          base, dataBuf[0], dataBuf[1], dataBuf[2], dataBuf[3], dataBuf[4], dataBuf[5], dataBuf[6], dataBuf[7],
          dataBuf[8], dataBuf[9], dataBuf[10], dataBuf[11], dataBuf[12], dataBuf[13], dataBuf[14], dataBuf[15]);
  Serial.println(strBuf);
}

/* --------------------------------------------- intelHex
Parse Intel Hex record and write data to the eeprom 
*/
void intelHex() {
  //          0 1 2 3 4 5 6 7 8 9 0 a b c d e f 0 1 2 3 4 5 6 7 8 9 0 a b c d e f
  // :aaBBBBccDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdSs
  // aa     = length of data (no od data bytes)
  // BBBB   = start address of this line
  // cc     = record type 00=Data, 01=End-Of-File
  // Dd..Dd = data bytes
  // Ss     = check sum = 2's compliment of the sum of all bytes up to there
  //          reciever can just sum all bytes (including the check sum) - the result should have a zero LSB
  fillDataBuf(0xFF);
  sum = 0;  // reset checksum
  /* read the intel hex 8 record */
  int len = getHex();
  int loc = getHex();
  loc = (loc << 8) + getHex();
  int rec = getHex();
  if (rec != 0) {
    Serial.println(F("Record type is not 00 (only data records accepted)"));
    return;
  }  // end of file (or invalid record) done.
  // rec type is 01 so data
  for (int i = 0; i < len; i += 1) {
    dataBuf[i] = getHex();
  }
  int chk = getHex();
  /* verify check sum */
  if ((sum & 0xFF) != 0) {
    Serial.print(F("Check sum error - nothing written"));
    return;
  }
  sprintf(strBuf, "%s Writing to 0x%04X ", fastWrite?"Fast":"Std ", loc);
  Serial.print(strBuf);
  // write to the eeprom
  readyToWrite();
  for (int i = 0; i < len; i += 1) {
    int tmp = loc + i;
    write(tmp, dataBuf[i]);
    Serial.print(".");
  }
  if(loc>maxAdr){
    maxAdr = loc;
  }
  Serial.println(F(" Done"));
  delay(DLY_MODE);
  readyToRead();
}

/* --------------------------------------------- fillDataBuf
Fill the data buffer with provided value 
*/
void fillDataBuf(int val) {
  for (int i = 0; i < 32; i += 1) {
    dataBuf[i] = val;
  }
}

/* --------------------------------------------- printDataBufAsHex
Print 32 bytes from dataBuf to serial port as hex digits 
*/
void printDataBufAsHex() {
  //               0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
  sprintf(strBuf, "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
          dataBuf[0], dataBuf[1], dataBuf[2], dataBuf[3], dataBuf[4], dataBuf[5], dataBuf[6], dataBuf[7],
          dataBuf[8], dataBuf[9], dataBuf[10], dataBuf[11], dataBuf[12], dataBuf[13], dataBuf[14], dataBuf[15]);
  Serial.print(strBuf);
  sprintf(strBuf, "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
          dataBuf[16], dataBuf[17], dataBuf[18], dataBuf[19], dataBuf[20], dataBuf[21], dataBuf[22], dataBuf[23],
          dataBuf[24], dataBuf[25], dataBuf[26], dataBuf[27], dataBuf[28], dataBuf[29], dataBuf[30], dataBuf[31]);
  Serial.print(strBuf);
}

/* --------------------------------------------- toIntelHex
Print 32 bytes from addr as an intel hex line 
*/
void toIntelHex(int base) {
  int len = 32;
  sum = len;
  int h = base >> 8;
  int l = base & 0xFF;
  sum = sum + h + l;
  //                len adr 00
  sprintf(strBuf, ":%02X%04X00", len, base);
  Serial.print(strBuf);
  // read data from the eeprom into the data buffer
  for (int i = 0; i < len; i += 1) {
    int ix = base + i;
    int n = read(ix);
    dataBuf[i] = n;
    sum += n;
  }
  // output the data buffer as hex digit pairs
  printDataBufAsHex();
  // calculate the check sum and output that too
  sum = (0 - sum) & 0xFF;  // 2's complement
  sprintf(strBuf, "%02X", sum);
  Serial.println(strBuf);
}

/*---------------------------------------------- doAddr
Handle 'A'ddress command
*/
void doAddr(){
  addr = getHex();
  addr = (addr << 8) + getHex();
  showData(addr);
}

/*---------------------------------------------- doWrite
Handle 'W'rite command
*/
void doWrite() {
  readyToWrite();
  int base = addr;
  int v = getHex();
  while (v >= 0) {
    write(addr++, v);
    v = getHex();
  }
  readyToRead();
  showData(base);
}

/*---------------------------------------------- doRead
Handle 'R'ead command
*/
void doRead() {
  readyToRead();
  int r = getHex();
  if (r <= 0) r = 1;
  readyToRead();
  for (int n = 0; n < r; n += 1) {
    showData(addr + n * PG);
  }
}

/*---------------------------------------------- doDump
Write intel hex records for the data in the eeprom.
*/
void doDump() {
  maxAdr = EEPROM_SIZE - 1;// default to 8k size
  // check if size is given then over-ride
  int h = getHex();
  if (h >= 0){
    byte l = getHex();
    maxAdr = h<<8 + l;
  }
  boolean ack = false;
  char ch = nextChar();
  while (ch > 0) {
    switch (ch) {
      case '*':   // check for '*' meaning the whole chip
        maxAdr = EEPROM_SIZE - 1;
        break;
      case 'A':   // check is 'A'ck should be required
        ack = true;
        break;
      default:
        break;
    }
    ch = nextChar();
  }
  readyToRead();
  // loop and generate the hex dump
  for (int p = 0; p < maxAdr; p += PG) {
    toIntelHex(p);
    if(ack){
      if (inputLine() <= 0) break;  // host should send ack
    }
  }
  Serial.println(F(":00000001FF"));// end of file record
}

/*---------------------------------------------- loop
Main command loop, gets a line, responds to it.
*/
void loop() {
  char cmd = inputLine();
  switch (cmd) {
    case '?':
    case 'H':  //'H'elp
      help();
      break;
    case 'E':  // 'E'rase
      eraseChip();
      break;
    case ':':  // Intel hex data line
      intelHex();
      break;
    case 'A':  // Address hhll
      doAddr();
      break;
    case 'R':  // Read
      doRead();
      break;
    case 'W':  // Write
      doWrite();
      break;
    case 'D':  // Dump
      doDump();
      break;
    default:  // Error
      Serial.println(F("Unknown command."));
      break;
  }
}
