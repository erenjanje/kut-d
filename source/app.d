import std.stdio;
import std.file;
import std.conv : to;
import kut.parser;
import kut.interpreter;
import kut.console_screen;

void main(string[] args) {
   if(args.length < 2) {
      throw new Error("Not enough arguments!");
   }
   string filename = args[1];
   //File file = File(filename, "r");
   string data = read(filename).to!string;
   Token[] tokens = data.to!dstring.parseKut;
   KutObject[dstring] immutableVariables = [
      "ekran": KutObject.externalObject(new KutScreen()),
   ];
   KutObject[dstring] variables;
   auto ctx = new KutContext(immutableVariables, variables);
   ctx.evaluate(tokens);
}