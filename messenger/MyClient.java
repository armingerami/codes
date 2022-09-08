import java.net.*;
import java.io.*;
import java.util.Scanner;

class Oprtion extends Thread{
    int a;
    Socket s;
    DataInputStream din;
    DataOutputStream dout;
    BufferedReader br;
    //Scanner sc;
    public Oprtion(int a, Socket s) throws IOException {
        this.a = a;
        this.s = s;
        this.din=new DataInputStream(s.getInputStream());
        this.dout=new DataOutputStream(s.getOutputStream());
        this.br = new BufferedReader(new InputStreamReader(System.in));
        //this.sc=new Scanner(System.in);
    }
    @Override
    public void run(){
        String strout="",strin="";

        if(this.a == 1) {
            while (true) {
                try {
                    strin = din.readUTF();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                System.out.println(strin);
            }
        }
        else{
            while(true){
                //if(sc.hasNextLine())
                //strout=sc.nextLine();
                try {
                    strout = br.readLine();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                try {
                    dout.writeUTF(strout);
                } catch (IOException e) {
                    e.printStackTrace();
                }
                try {
                    dout.flush();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

        }

    }
}
class MyClient{
    public static void main(String args[])throws Exception{
        Socket s=new Socket("localhost",3333);

        Oprtion myread = new Oprtion(1, s);
        Oprtion mywrite = new Oprtion(2, s);
        myread.start();
        mywrite.start();
    }
}

//cd desktop\temporary stuff\src && javac MyClient.java && java MyClient
// cd desktop\temporary stuff\src && javac MyClient.java && java MyClient
// javac MyClient.java
// java MyClient