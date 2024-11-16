import com.fazecast.jSerialComm.*;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Quick & dirty code to communicate with the programmer from the command line
 * Anton Schoultz Oct 2023
 *
 *
 */
public class EEPromProgrammer {
    // default baud rate
    static final int BAUD_RATE = 115200;

    static final int MODE_READ = 0;
    static final int MODE_WRITE = 1;
    static final int MODE_ERASE = 2;
    static final int MODE_LOAD = 3;
    static final int MODE_DUMP = 4;
    static final int MODE_VERIFY = 5 ;

    static final int NEW_READ_TIMEOUT = 5000;
    static final int NEW_WRITE_TIMEOUT = 5000;
    static final int K = 1024;

    // input parameters
    private String portName;
    private String fileSpec;
    private int baudRate = BAUD_RATE;
    private int mode = -1;
    private int romSize =8 * K;

    // I/O via com port
    private SerialPort comPort;
    private InputStream comInputStream;
    private InputStreamReader comInputStreamReader;
    private OutputStream comPortOutputStream;
    private BufferedOutputStream comPortOutputBuffer;
    private PrintWriter comOutputWriter;
    private BufferedReader comInputReader;

    // Intel hex8 format
    //          0 1 2 3 4 5 6 7 8 9 0 a b c d e f 0 1 2 3 4 5 6 7 8 9 0 a b c d e f
    // :aaBBBBccDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdDdSs
    // aa     = length of data (no od data bytes)
    // BBBB   = start address of this line
    // cc     = record type 00=Data, 01=End-Of-File
    // Dd..Dd = data bytes
    // Ss     = check sum = 2's compliment of the sum of all bytes up to there
    //          receiver can just sum all bytes (including the check sum) - the result should have a zero LSB

    // end of intel hex file
    static final String EOF = ":00000001FF";

    // byte array for an intel hax line (32 data bytes)
    private byte[] buf = new byte[1+2+1+32+1];

    /** Main method - entry point */
    public static void main(String[] args) {

        EEPromProgrammer m = new EEPromProgrammer();
        m.execute(args);
    }


    private static void showHelp() {
        println("?               Display this help");
        println("-B:####         Set the baud rate eg -B:9600 (default is "+BAUD_RATE+" )");
        println("-C:# / COMx     Specify comport for programmer - eg -C:5 or -C:COM5");
        println("-W:filename     Write iHex file to eeprom. eg -W:MyData.hex");
        println("-R:filename     Read eeprom to iHex file.  eg -R:ChipData.hex");
        println("-D:filename     Dump eeprom to text based hex file.  eg -D:ChipData.txt");
        println("-L:filename     Load binary file into the eeprom");
        println("-S:#            Size of eeprom in K (default is 8)");
        println("-E              erase the chip");
    }

    public void execute(String[] args) {
        if(args.length==0){
            showHelp();
            return;
        }
        for (String s : args) {
            if (s.equalsIgnoreCase("?")) {
                showHelp();
                return;
            } else {
                if (s.startsWith("-")) {
                    int num = -1;
                    int hex = -1;
                    String value="";
                    char ch = Character.toUpperCase(s.charAt(1));
                    if(ch=='H' || ch=='?'){
                        showHelp();
                        return;
                    }
                    if(ch!='E' && ch!='V') {
                        if (s.charAt(2) != ':') {
                            println("args should be formated like '-X:xxxxx'");
                            return;
                        }
                        value = s.substring(3).trim();
                        try {
                            num = Integer.parseInt(value);
                        } catch (NumberFormatException e) {
                        }
                        try {
                            hex = Integer.parseInt(value, 16);
                        } catch (NumberFormatException e) {
                        }
                    }
                    switch (ch) {
                        case 'B':
                            baudRate = num;
                            break;
                        case 'C':
                            if(num>=0) {
                                portName = "COM" + num;
                            }else{
                                portName = value;
                            }
                            break;
                        case 'W':
                            mode = MODE_WRITE;
                            fileSpec = value;
                            break;
                        case 'L':
                            mode = MODE_LOAD;
                            fileSpec = value;
                            break;
                        case 'R':
                            mode = MODE_READ;
                            fileSpec = value;
                            break;
                        case 'D':
                            mode = MODE_DUMP;
                            fileSpec = value;
                            break;
                        case 'S':
                            if(num>0 & num<64) {
                                romSize = num * K;
                            }
                            break;
                        case 'E':
                            mode = MODE_ERASE;
                            break;
                        case 'V':
                            mode = MODE_VERIFY;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        System.out.printf("Comport:%s %d, Filename:%s Size:0x%04x %n", portName, baudRate, fileSpec,romSize);
        findComPort();
        if (comPort != null) {
            openComPort();
            System.out.println("Found port " + portDetails(comPort));
            try {
                waitForReady();
                if(mode==MODE_ERASE) {
                    sendAndGet("E");
                }
                if(mode==MODE_VERIFY) {
                    sendAndGet("V");
                }
                if(mode==MODE_READ){
                    File f = new File(fileSpec);
                    readEE(f);
                }
                if(mode==MODE_DUMP){
                    File f = new File(fileSpec);
                    dumpEE(f);
                }
                if(mode==MODE_WRITE) {
                    writeEE();
                    File f = new File(fileSpec);
                    f = genOutFile(f);
                    readEE(f);
                }
                if(mode==MODE_LOAD) {
                    loadBinaryToROM();
                    File f = new File(fileSpec);
                    f = genOutFile(f);
                    readEE(f);
                }

            } catch (Exception e) {
                e.printStackTrace();
            }

            comPort.closePort();
        }

    }

    /* load a binary file, convert to intel hex lines and send to programmer */
    private boolean loadBinaryToROM() {
        try {
            File fBin = new File(fileSpec);
            if (!fBin.exists()) {
                System.out.println("File not found.");
                return true;
            }
            try ( InputStream inputStream = new FileInputStream(fBin); ) {
                int address = 0;
                byte[] buffer = new byte[32];
                int bytesRead = -1;
                 while ((bytesRead = inputStream.read(buffer)) != -1) {
                    StringBuilder sb = new StringBuilder();
                    sb.append(":");
                    sb.append( String.format("%02X%04X00",bytesRead,address));
                    int sum = bytesRead + (address&0xFF) + ((address>>8)&0xFF);
                    for(int n=0;n<bytesRead;n++){
                        int b = buffer[n] & 0xFF;
                        sum += b;
                        sb.append( String.format("%02X",(int)b));
                    }
                    int check = (0 - sum) &0xFF;
                    sb.append( String.format("%02X",check));
                    address += bytesRead;
                    String iHex = sb.toString();
                    sendAndGet(iHex);
                }
                sendAndGet(":00000001FF");// end of file
            } catch (IOException ex) {
                ex.printStackTrace();
            }
            println("\r\nDone.");
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return false;
    }


    /**
     *  write an intel hex file to the programmer
     */
    private boolean writeEE() {
        File fHex = new File(fileSpec);
        if (!fHex.exists()) {
            System.out.println("File not found.");
            return true;
        }
        List<String> lines = fileReadLines(fHex);
        for (String s : lines) {
            sendAndGet(s);
        }
        return false;
    }

    /**
     * Read the eeprom and write the result as iHex file
     */
    private ArrayList<String> readEE(File f) {
        String cmd = String.format("D%04X", romSize );
        sendCommand(cmd);
        ArrayList<String> result = new ArrayList<>();
        String input;
        try {
            while (true) {
                input = comInputReader.readLine();
                println("<" + input);
                // received end of file marker
                if (input.trim().startsWith(EOF)) {
                    result.add(EOF);
                    break;
                }
                if (!input.endsWith("READY")) {
                    result.add(input);
                }
                //if (ack) sendCommand(".");// send the ack
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        fileWrite(result, f);
        println("----------------------------------- " + f.getAbsolutePath());
        for (String s : result) {
            println(s);
        }
        println("---");

        return result;
    }

    /**
     * Read the eeprom and write the result as simple hex dump text
     */
    private ArrayList<String> dumpEE(File f) {
        String cmd = String.format("R", romSize/16 );
        sendCommand(cmd);
        ArrayList<String> result = new ArrayList<>();
        String input;
        try {
            while (true) {
                input = comInputReader.readLine();
                println("<" + input);
                // received end of file marker
                if (input.trim().startsWith(EOF)) {
                    result.add(EOF);
                    break;
                }
                if (!input.endsWith("READY")) {
                    result.add(input);
                }
                //if (ack) sendCommand(".");// send the ack
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        fileWrite(result, f);
        println("----------------------------------- " + f.getAbsolutePath());
        for (String s : result) {
            println(s);
        }
        println("---");

        return result;
    }

    /**
     * create a .res output file based on the input file path and name.
     */
    private File genOutFile(File fIn){
        File p = fIn.getParentFile();
        String name = fIn.getName();
        int ix = name.lastIndexOf('.');
        if (ix <= 0) {
            name = name + ".res";
        } else {
            name = name.substring(0, ix) + ".res";
        }
        File f = new File(p, name);
        return f;
    }


    /**
     * open the com port (resets Arduino)
     */
    private void openComPort() {
        comPort.setBaudRate(baudRate);
        comPort.openPort();
        comPort.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, NEW_READ_TIMEOUT, NEW_WRITE_TIMEOUT);
        comInputStream = comPort.getInputStream();
        comInputStreamReader = new InputStreamReader(comInputStream);
        comInputReader = new BufferedReader(comInputStreamReader);
        comPortOutputStream = comPort.getOutputStream();
        comPortOutputBuffer = new BufferedOutputStream(comPortOutputStream);
        comOutputWriter = new PrintWriter(comPortOutputBuffer);
    }

    /**
     * Close the com port
     */
    private void closeComPort() {
        try {
            comOutputWriter.close();
            comPortOutputBuffer.close();
            comPortOutputStream.close();

            comInputReader.close();
            comInputStreamReader.close();
            comInputStream.close();
        } catch (IOException e) {
            println("Error closing com port streams. " + e.toString());
        }
    }

    /**
     * seach for the specified com port in the enumerated list
     */
    private void findComPort() {
        comPort = null;
        SerialPort[] serialPorts = SerialPort.getCommPorts();
        for (SerialPort sp : serialPorts) {
            if (sp.getSystemPortName().equalsIgnoreCase(portName)) {
                comPort = sp;
            }
        }
    }


    private static void print(String str) {
        System.out.print(str);
    }

    private static void println(String str) {
        System.out.println(str);
    }

    /**
     * Send the command line to the com prt, then get returns until 'READY'
     */
    private ArrayList<String> sendAndGet(String cmd) {
        sendCommand(cmd);
        return waitForReady();
    }

    /** Sends the provided string to the programmer */
    private void sendCommand(String cmd) {
        println(">" + cmd);
        comOutputWriter.println(cmd);
        comOutputWriter.flush();
    }

    /**
     * read lines form the com port until we get one that ends with 'READY'
     */
    private ArrayList<String> waitForReady() {
        ArrayList<String> result = new ArrayList<>();
        String input;
        try {
            while (true) {
                input = comInputReader.readLine();
                println("<" + input);
                if (input.endsWith("READY")) break;
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        println("");
        return result;
    }

    /** Returns a String with the details of the com port */
    private String portDetails(SerialPort sp) {
        return sp.getSystemPortName() + ":" + sp.getPortDescription() + " " +
                sp.getBaudRate() + " " + sp.getNumDataBits() + (sp.getParity() == NEW_WRITE_TIMEOUT ? " N " : " Y ") + sp.getNumStopBits()
                + (sp.getCTS() ? " CTS" : " cts") + (sp.getRTS() ? " RTS" : " rts")
                + (sp.getDTR() ? " DTR" : " dtr") + (sp.getDSR() ? " DSR" : " dsr");
    }


    /** Reads the file and returns its contents as a List of lines */
    public static List<String> fileReadLines(File fin)
    {
        ArrayList<String> lst = new ArrayList<String>();
        try
        {
            FileReader fr = new FileReader(fin);
            BufferedReader br = new BufferedReader(fr);
            String str;
            while ((str = br.readLine()) != null)
            {
                lst.add(str);
            }
            br.close();
            fr.close();
        }
        catch (FileNotFoundException e)
        {
            lst.add("*** File not found " + fin.getAbsolutePath());
        }
        catch (IOException e)
        {
            lst.add("*** File i/o error reading " + fin.getAbsolutePath());
        }
        return lst;
    }
    /** Writes the supplied string list to the specified file. */
    public static void fileWrite(List<String> lines, File target) {
        StringBuilder sb = new StringBuilder();
        for(String s:lines){
            sb.append(s).append("\r\n");
        }
        fileWrite(sb.toString(),target);
    }

    /** Writes the supplied string to the specified file. */
    public static void fileWrite(String text, File target)
    {
        File fParent = target.getParentFile();
        if ( fParent != null )
        {
            fParent.mkdirs();
        }
        FileOutputStream fos = null;
        PrintWriter pw = null;
        try
        {
            fos = new FileOutputStream(target);
            pw = new PrintWriter(fos);
            pw.println(text);
            pw.flush();
            fos.flush();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        finally
        {
            if ( pw != null )
            {
                try
                {
                    pw.close();
                }
                catch (Exception e)
                {
                    e.printStackTrace();
                }
            }
            if ( fos != null )
            {
                try
                {
                    fos.close();
                }
                catch (IOException e)
                {
                    e.printStackTrace();
                }
            }
        }
    }

}