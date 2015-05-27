module logsink;
import std.stdio;
import routes;
import vibe.core.core;
import vibe.core.concurrency;
import std.concurrency : OwnerTerminated, Variant;
import vibe.http.client;

__gshared Task gs_logsink;

struct ShutdownMsg
{
}

Log[ulong] logstore;

static void logSink()
{
    gs_logsink = Task.getThis();

    bool isRunning = true;
    while (isRunning)
    {
        receive(

          (Log l)
          { 
            writeln("received log!", l); 
            logstore[l.id] = l;
          }, 

          (Ack a) 
          {
            writeln("removed log!", a); 
            logstore.remove(a.id);
            
            
            //lets simulate a "few" call to a backend
            runTask( { 
              int i = 0;
              while( i < 1000){
                  auto resp = requestHTTP("http://localhost:9090/c", (scope req) { });
                  resp.dropBody();
                  i++;
              }
            });
              
          }, 
          
          (Variant v) 
          { 
            writeln("unhandled message"); 
            throw new Error("unhandled message"); 
          }
        );
    }

    writeln("logsink task terminated"); //how can i make this happen

}
