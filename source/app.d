import std.stdio;
import std.file;
import std.conv : to;
import std.algorithm.searching : startsWith;
import std.getopt;
import kut.parser;
import kut.interpreter;
import kut.console_screen;

void printHelp(string[] args) {
   writefln(
      "Usage: %s [filename] [OPTIONS]\n" ~
      "\tOPTIONS:\n" ~
      "\t\t--help | -h: Shows this help.\n" ~
      "\t\t--file | -f [=] filename: Uses filename as the file to be read to interpret.\n" ~
      "\t\t--expression | --expr | -e [=] expression: Interprets the expression.\n",
      args[0]
   );
}

void main(string[] args) {
   string filename = null;
   bool help = args.length == 1;
   string expression = null;
   if(args.length > 1 && !args[1].startsWith("-")) {
      filename = args[1];
   }
   args.getopt(
      "file|f", &filename,
      "help|h", &help,
      "expression|expr|e", &expression
   );
   if(help) {
      printHelp(args);
      return;
   }
   if(filename) {
      string data = read(filename).to!string;
      Token[] tokens = data.to!dstring.parseKut();
      KutObject[dstring] immutableVariables = [
         "ekran": KutObject.externalObject(new KutScreen()),
      ];
      KutObject[dstring] variables;
      tokens.evaluate(immutableVariables, variables);
   } else if(expression) {
      Token[] tokens = expression.to!dstring.parseKut();
      KutObject[dstring] immutableVariables = [
         "ekran": KutObject.externalObject(new KutScreen()),
      ];
      KutObject[dstring] variables;
      tokens.evaluate(immutableVariables, variables);
   } else {
      printHelp(args);
      return;
   }
}