import java.net.*;
import java.io.*;
import java.util.ArrayList;

class Users{
    public ArrayList<User> users = new ArrayList<User>();
    public Users (){}
    public void add(User a){
        users.add(a);
    }
}
class User{
    public String name;
    public Socket s;
    public boolean online;
    public DataInputStream din;
    public DataOutputStream dout;
    public int called;
    public int accepted;
    public User caller = null;
    public User(String name){
        this.name = name;
        this.online = false;
        this.called = 0;
        this.accepted = 0;
    }
    public void login(Socket s,DataInputStream din, DataOutputStream dout) throws IOException {
        this.s = s;
        this.din = din;
        this.dout = dout;
        this.online = true;
    }
    public void logout(){
        this.online = false;
    }
    public void call(User caller){
        this.caller = caller;
        this.called = 1;
    }
    public void answer(int a){
        this.accepted = a;
    }
}



class ClientHandler extends Thread {
    Users clients;
    DataInputStream din;
    DataOutputStream dout;
    final Socket s;

    public ClientHandler(Socket s, DataInputStream din, DataOutputStream dout, Users clients) throws IOException {
        this.s = s;
        this.din = din;
        this.dout = dout;
        this.clients = clients;
    }

    @Override
    public void run() {
        String strin = "", strout = "";

        try {
            dout.writeUTF("to login type \"login\" and to sign up type \"sign up\"");
        } catch (IOException e) {
            e.printStackTrace();
        }
        try {
            dout.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }

        User current = null;
        User recipient = null;

        while (true) {
            try {
                strin = din.readUTF();
            } catch (IOException e) {
                e.printStackTrace();
            }
            System.out.println(strin);
            //sign up
            if (strin.equals("sign up")) {
                int is_new = 0;
                int first = 0;
                while (is_new == 0) {
                    is_new = 1;

                    if(first == 0) {
                        try {
                            dout.writeUTF("select username");
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                        try {
                            dout.flush();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                    first = 1;

                    try {
                        strin = din.readUTF();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                    for (User temp : clients.users) {
                        if (temp.name.equals(strin)) {
                            is_new = 0;
                        }
                    }
                    if (is_new == 0) {
                        try {
                            dout.writeUTF("username taken; pleas type another username");
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
                User newuser = null;
                newuser = new User(strin);
                clients.add(newuser);
                try {
                    dout.writeUTF("user " + newuser.name + " was successfully signed up; " +
                            "to login type \"login\" and to sign up type \"sign up\"");
                } catch (IOException e) {
                    e.printStackTrace();
                }
                try {
                    dout.flush();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            //login
            else if (strin.equals("login")) {
                int exists = 0;
                int first = 0;
                while (exists == 0) {
                    if (first == 0) {
                        try {
                            dout.writeUTF("type your username");
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                        try {
                            dout.flush();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                    first = 1;
                    try {
                        strin = din.readUTF();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }


                    for (User temp : clients.users) {
                        if (temp.name.equals(strin)) {
                            try {
                                temp.login(s, din, dout);
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            current = temp;
                            din = current.din;
                            dout = current.dout;
                            try {
                                dout.writeUTF("you are successfully logged in, to send a message type \"send message\"" +
                                        " and to logout type \"logout\"");
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            try {
                                dout.flush();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            exists = 1;
                        }
                    }
                    if (exists == 0) {
                        try {
                            dout.writeUTF("no such username exists; type another username");
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
                try {
                    strin = din.readUTF();
                } catch (IOException e) {
                    e.printStackTrace();
                }

                int exit = 0;
                while (exit == 0) {
                    //answer call
                    if(current.called == 1){
                        System.out.println(current.name + " called");

                        System.out.println(strin);
                        if(strin.equals("accept")) {
                            exit = 1;
                            try {
                                current.caller.dout.writeUTF("user " + current.name + " has accepted your offer");
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            try {
                                current.caller.dout.flush();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            try {
                                current.caller.dout.writeUTF("you are now talking with " + current.name + "; you can type \"log out\" to log out");

                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            try {
                                current.caller.dout.flush();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            try {
                                current.dout.writeUTF("you are now talking with " + current.caller.name + "; you can type \"log out\" to log out");

                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            try {
                                current.dout.flush();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            current.caller.answer(1);
                            //msngr msngr1 = new msngr(current.din, current.caller.din, current.dout, current.caller.dout, current, current.caller);
                            msngr msngr2 = new msngr(current, current.caller);
                            msngr2.start();
                            //msngr1.start();
                            exit = 1;
                            break;
                        }
                        else{
                            try {
                                current.caller.dout.writeUTF("user " + current.name + " has rejected your offer");
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            try {
                                current.caller.dout.flush();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            current.caller.answer(-1);
                        }
                    }
                    //logout
                    else if (strin.equals("log out")) {
                        System.out.println(strin);
                        try {
                            dout.writeUTF("you have successfully logged out");
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                        try {
                            dout.flush();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                        current.logout();
                        exit = 0;
                        this.start();
                    }

                    //send message
                    else if (strin.equals("send message")) {
                        System.out.println(strin);
                        int userexists = 0;
                        first = 0;
                        while (userexists == 0) {
                            if (first == 0) {
                                try {
                                    dout.writeUTF("type the username of the recipient or log out by typing \"log out\"");
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                                try {
                                    dout.flush();
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            }
                            first = 1;
                            try {
                                strin = din.readUTF();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }

                            if (!strin.equals("log out")) {
                                for (User temp : clients.users) {
                                    if (temp.name.equals(strin)) {
                                        if (!temp.online) {
                                            try {
                                                dout.writeUTF("user is offline; type the username of another recipient or " +
                                                        "log out by typing \"log out\"");
                                            } catch (IOException e) {
                                                e.printStackTrace();
                                            }
                                            try {
                                                dout.flush();
                                            } catch (IOException e) {
                                                e.printStackTrace();
                                            }
                                        } else {
                                            try {
                                                dout.writeUTF("request sent; awaiting response");
                                            } catch (IOException e) {
                                                e.printStackTrace();
                                            }
                                            try {
                                                dout.flush();
                                            } catch (IOException e) {
                                                e.printStackTrace();
                                            }
                                            userexists = 1;
                                            recipient = temp;
                                        }
                                    }
                                }
                                if (userexists == 0) {
                                    try {
                                        dout.writeUTF("user not found; type the username of another recipient or " +
                                                "log out by typing \"log out\"");
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
                            else if (strin.equals("log out")) {
                                System.out.println(strin);
                                current.logout();
                                try {
                                    dout.writeUTF("you have successfully logged out");
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                                try {
                                    dout.flush();
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                                this.start();
                            }
                        }
                        try {
                            this.Sendrequest(current, recipient);
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
            else{
                try {
                    dout.writeUTF("invalid command");
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

    public void Sendrequest(User sender, User receiver) throws IOException {

        DataInputStream dins = sender.din;
        DataOutputStream douts = sender.dout;
        DataInputStream dinr = receiver.din;
        DataOutputStream doutr = receiver.dout;
        receiver.call(sender);
        doutr.writeUTF("user " + sender.name + " wants to chat with you; type \"accept\" or type anything else to reject");
        doutr.flush();
        int done = 0;
        //System.out.println(sender.accepted);
        while(done == 0) {
            System.out.print("");
            if (sender.accepted == 1) {
                sender.accepted = 0;
                msngr msngr1 = new msngr(sender, receiver);
                msngr1.start();
                done = 1;
            }
            if (sender.accepted == -1) {
                sender.accepted = 0;
                done = 1;
            }
        }
    }

}

class msngr{
    DataInputStream dins;
    DataInputStream dinr;
    DataOutputStream douts;
    DataOutputStream doutr;
    User sender;
    User receiver;
    public msngr(User sender, User receiver){
        this.douts = sender.dout;
        this.doutr = receiver.dout;
        this.dins = sender.din;
        this.dinr = receiver.din;
        this.sender = sender;
        this.receiver = receiver;
    }


    public void start(){
        System.out.println(sender.name);
        String strs = " ";
        int bye = 0;
        while(bye == 0) {
            try {
                strs = dins.readUTF();
                System.out.println(sender.name + ":" + strs);
            } catch (IOException e) {
                e.printStackTrace();
            }
            if(strs.equals("log out")){
                try {
                    doutr.writeUTF("you have successfully logged out");
                } catch (IOException e) {
                    e.printStackTrace();
                }
                try {
                    doutr.flush();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                sender.logout();
                bye = 1;
                break;
            }
            if (receiver.online) {
                if (strs.equals("bye")) {
                    try {
                        doutr.writeUTF(sender.name + " : " + strs + "\nconversation with " + sender.name + " has ended");
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    try {
                        doutr.flush();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    try {
                        douts.writeUTF("conversation with " + receiver.name + " has ended");
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    try {
                        douts.flush();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    bye = 1;
                    break;
                }
                try {
                    doutr.writeUTF(sender.name + " : " + strs);
                } catch (IOException e) {
                    e.printStackTrace();
                }
                try {
                    doutr.flush();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            else {
                try {
                    douts.writeUTF("user " + sender.name + " is now offline and you cant message them anymore");
                } catch (IOException e) {
                    e.printStackTrace();
                }
                try {
                    douts.flush();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                bye = 1;
                break;
            }
        }
    }
}
class MyServer{
    public static void main(String args[])throws Exception{
        Users clients = new Users();
        ServerSocket ss=new ServerSocket(3333);

        while(true) {
            Socket s = ss.accept();
            DataInputStream din = new DataInputStream(s.getInputStream());
            DataOutputStream dout = new DataOutputStream(s.getOutputStream());
            BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
            ClientHandler t = new ClientHandler(s, din, dout, clients);
            t.start();
        }
        //din.close();
        //s.close();
        //ss.close();
        //System.out.println("system shut down");
    }}

//cd desktop\temporary stuff\src && javac MyServer.java && java MyServer

