import std.stdio;
import kut.parser;
import kut.interpreter;
import kut.console_screen;

void main() {
   Token[] tokens = parseKut(`(ekran "aa" yazsın)`);
   KutObject[dstring] immutableVariables = [
      "ekran": KutObject.externalObject(new KutScreen()),
   ];
   KutObject[dstring] variables;
   auto ctx = new KutContext(immutableVariables, variables);
   //writeln(ctx.variables);
   ctx.evaluate(tokens);
   //writeln(ctx.variables["ananza"]);
}