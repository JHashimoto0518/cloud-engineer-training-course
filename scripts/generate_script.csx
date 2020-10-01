// TODO: all files

// read md
private const string MdPath = @"c:/rep/github/jhashimoto0518/cloud-engineer-training-course/contents/day-02/build_vpc.md";
var lines = File.ReadAllLines(MdPath);
Debug.Assert(lines[0] == "");

// select command lines (starting "$ ")
//var commandLines = lines.Where(l => l.StartsWith("$") || l.StartsWith("#") || l.StartsWith("--")).Select(l => l.Trim('$').Trim('#').Trim());
var commandLines = lines.Where(l => l.StartsWith("$") || l.StartsWith("--")).Select(l => l.Trim('$').Trim());
Debug.Assert(commandLines.FirstOrDefault() == "");

// to script file
// TODO:consider newline 
const string ScriptPath = @"c:/rep/github/jhashimoto0518/cloud-engineer-training-course/scripts/day-02/create_resources.sh";
File.Delete(ScriptPath);
File.AppendAllLines(ScriptPath, commandLines);
