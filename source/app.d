module x;
import vibe.d;
import std.format : format;
import core.atomic : atomicOp;
import std.stdio;
import logsink;
import routes;

static void main()
{
 
	// returns false if a help screen has been requested and displayed (--help)
	if (!finalizeCommandLineOptions())
		return;
  
  runWorkerTask(&logSink); 
  
  auto router = new URLRouter;
  router.get("/a", &routea);
  router.get("/b", &routeb);
  router.get("/c", &routec);
  
  auto settings = new HTTPServerSettings;
  settings.port = 9090;
  settings.bindAddresses = ["0.0.0.0"];
  settings.options = settings.options 
      | HTTPServerOption.parseCookies
      | HTTPServerOption.parseQueryString;
//  settings.options = settings.options  | HTTPServerOption.distribute  ;
    
  listenHTTP(settings, router);
  
  lowerPrivileges();
  runEventLoop();
  

}