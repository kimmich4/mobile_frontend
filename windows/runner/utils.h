#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>
#include <vector>

// creates a console for the process, and redirects stdout and stderr to
// it for both the runner and the flutter library.
void CreateAndAttachConsole();

// takes a null-terminated wchart encoded in utf-16 and returns a std::string
// encoded in utf-8. returns an empty std::string on failure.
std::string Utf8FromUtf16(const wchar_t* utf16_string);

// gets the command line arguments passed in as a std::vector<std::string,
// encoded in utf-8. returns an empty std::vector<std::string on failure.
std::vector<std::string> GetCommandLineArguments();

#endif  // runnerutilsh
