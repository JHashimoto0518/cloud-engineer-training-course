// read md
private const string MdPath = @"../contents/day-02/create_vpc.md";
var lines = File.ReadAllLines(MdPath);
Debug.Assert(lines[0] == "");

// select command lines (starting "$ ")
var commandLines = lines.Where(l => l.StartsWith("$")).Select(l => l.Trim('$').Trim());
Debug.Assert(commandLines.FirstOrDefault() == "");

// to script file
// TODO:consider newline 
const string ScriptPath = "./day-02/create_resources.sh";
File.Delete(ScriptPath);
File.AppendAllLines(ScriptPath, commandLines);
