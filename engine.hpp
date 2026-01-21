#pragma once

#include <string>
#include <vector>

class SpiceEngine {
public:
    SpiceEngine();
    void initNgspice();
    void say_hello();
    std::string getOutput();
    int runCommand(const char*);
    std::string runAnalysis(const char*, const char*);
    std::vector<double> takeSamples();
    int getComplexStride();
    std::vector<const char*> getVecNames();
    static void setSpiceScriptsPath(const char*);
    static bool analysisRequiresComplex(const std::string&);
private:
    struct Impl;
    Impl* impl;          // opaque pointer
};
