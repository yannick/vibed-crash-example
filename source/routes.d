module routes;
import vibe.http.server;
import vibe.core.core;
import vibe.core.concurrency;
import vibe.http.client;
import logsink;
import core.atomic;
import std.string;
import std.stdio;
import std.conv;

shared ulong serial;

struct Log
{
    ulong id;
    string data;
}

struct Ack {
  ulong id;
}


void routea(HTTPServerRequest req, HTTPServerResponse res)
{

    auto s = atomicOp!"+="(serial, 1);
    auto log = Log(s, "test");
    
    gs_logsink.send(log);
    auto redirectUrl = format("/b?s=%s", s);
    res.redirect(redirectUrl);
}

void routeb(HTTPServerRequest req, HTTPServerResponse res)
{
      
    auto s_str = req.query.get("s", "0");
    ulong id = to!ulong(s_str);
    gs_logsink.send(Ack(id));
    res.writeBody(s_str ~ "\n");
}

__gshared int cnt;

void routec(HTTPServerRequest req, HTTPServerResponse res)
{
  cnt++;
  if ((cnt % 1000 ) == 0 ){
    writeln(cnt);
  }
  res.render!("lore.dt", req);
}